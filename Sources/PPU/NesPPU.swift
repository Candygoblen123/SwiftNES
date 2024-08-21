class NesPPU {
    public var paletteTable = [UInt8](repeating: 0, count: 32)
    public var vram = [UInt8](repeating: 0, count: 2048)

    public let mirroring: Mirroring
    public var chrRom: [UInt8]

    private let addr: AddrRegister = AddrRegister()
    private var readBuff: UInt8 = 0
    var ctrl = ControlRegister()
    let status = StatusRegister()
    let scroll = ScrollRegister()
    let mask = MaskRegister()

    var oamAddr: UInt8 = 0
    var oamData = [UInt8](repeating: 0, count: 64 * 4)

    var scanline: UInt16 = 0
    var cycles: Int = 0

    var nmiInterrupt: UInt8? = nil

    init(_ chrRom: [UInt8], _ mirroring: Mirroring) {
        self.chrRom = chrRom
        self.mirroring = mirroring
    }

    func tick(_ cycles: UInt8) -> Bool {
        self.cycles += Int(cycles)
        if self.cycles >= 341 {
            //print(self.cycles)
            self.cycles = self.cycles - 341
            self.scanline += 1

            if scanline == 241 {
                self.status.setVblankStatus(true)
                status.setSpriteZeroHit(false)
                if ctrl.generateVblankNMI() {
                    nmiInterrupt = 1
                    print("interrupt")
                }
            }

            if scanline >= 262 {
                scanline = 0
                nmiInterrupt = nil
                status.setSpriteZeroHit(false)
                self.status.resetVblankStatus()
                return true
            }
        }
        return false
    }

    func pollNMI() -> UInt8? {
        let tmp = self.nmiInterrupt
        self.nmiInterrupt = nil
        return tmp
    }

    func writeToPPUAddr(_ value: UInt8) {
        addr.update(value)
    }

    func writeToCtrl(_ value: UInt8) {
        let beforeNmiStatus = ctrl.generateVblankNMI()
        ctrl.rawValue = value
        if !beforeNmiStatus && ctrl.generateVblankNMI() && status.isInVblank() {
            nmiInterrupt = 1
        }
    }

    func incrememtVramAddr() {
        addr.increment(ctrl.vramAddrIncrement())
    }

    func readData() -> UInt8 {
        let addr = addr.get()
        incrememtVramAddr()

        switch addr {
        case 0...0x1fff:
            let res = readBuff
            readBuff = chrRom[Int(addr)]
            return res
        case 0x2000...0x2fff:
            let res = readBuff
            readBuff = vram[Int(mirrorVramAddr(addr))]
            return res
        case 0x3000...0x3eff:
            fatalError("addr space 0x3000..0x3eff is not expected to be used, requested = \(addr)")
        case 0x3f00...0x3fff:
            return self.paletteTable[Int(addr - 0x3f00)]
        default:
            fatalError("Unexpected access to mirrored space \(addr)")
        }
    }

    func mirrorVramAddr(_ addr: UInt16) -> UInt16 {
        let mirroredVram = addr & 0b10111111111111 // mirror down 0x3000-0x3eff to 0x2000 - 0x2eff
        let vramIndex = mirroredVram - 0x2000 // to vram array index
        let nameTable = vramIndex / 0x400 // to the name index table
        return switch (mirroring, nameTable) {
        case (.vertical, 2), (.vertical, 3):
            vramIndex - 0x800
        case (.horizontal, 2):
            vramIndex - 0x400
        case (.horizontal, 1):
            vramIndex - 0x400
        case (.horizontal, 3):
            vramIndex - 0x800
        default:
            vramIndex
        }
    }

    func writeToData(_ data: UInt8) {
        let addr = addr.get()
        print("\(addr): \(data)")
        switch addr {
        case 0...0x1fff:
            print("Attempt to write to chr rom space \(addr)!")
        case 0x2000...0x2fff:
            self.vram[Int(mirrorVramAddr(addr))] = data
        case 0x3000...0x3eff:
            fatalError("addr \(addr) should not be used in reality!")
        //Addresses $3F10/$3F14/$3F18/$3F1C are mirrors of $3F00/$3F04/$3F08/$3F0C
        case 0x3f10, 0x3f14, 0x3f18, 0x3f1c:
            let addrMirror = addr - 0x10
            paletteTable[Int(addrMirror - 0x3f00)] = data
        case 0x3f00...0x3fff:
            paletteTable[Int(addr - 0x3f00)] = data
        default:
            fatalError("Unexpected access to mirrored space \(addr)")
        }
        incrememtVramAddr()
    }

    func writeOamDma(_ buffer: [UInt8]) {
        for x in buffer {
            oamData[Int(oamAddr)] = x
            oamAddr = oamAddr &+ 1
        }
    }

    func readStatus() -> UInt8 {
        let data = status.snapshot()
        status.resetVblankStatus()
        addr.resetLatch()
        scroll.resetLatch()
        return data
    }

    func writeToScroll(_ value: UInt8) {
        scroll.write(value)
    }

    func writeToOamAddr(_ value: UInt8) {
        oamAddr = value
    }

    func writeToOamData(_ value: UInt8) {
        oamData[Int(oamAddr)] = value
        oamAddr = oamAddr &+ 1
    }

    func readOamData() -> UInt8 {
        oamData[Int(oamAddr)]
    }

    func writeToMask(_ value: UInt8) {
        mask.update(value)
    }
}
