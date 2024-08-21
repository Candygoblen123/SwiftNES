class Bus {
    var cpuVram: [UInt8] = .init(repeating: 0, count: 2048)
    var prgRom: [UInt8]
    var ppu: NesPPU
    var cycles: Int = 0
    var gameloopCallback: (NesPPU) -> ()

    fileprivate let RAM : UInt16 = 0x0000
    fileprivate let RAM_MIRRORS_END: UInt16 = 0x1FFF
    fileprivate let PPU_REGISTERS: UInt16 = 0x2000
    fileprivate let PPU_REGISTERS_MIRRORS_END: UInt16 = 0x3FFF
    fileprivate let ROM_ADDRESS_START: UInt16 = 0x8000
    fileprivate let ROM_ADDRESS_END: UInt16 = 0xFFFF

    init(_ rom: Rom, gameloopCallback: @escaping (NesPPU) -> ()) {
        ppu = NesPPU(rom.character, rom.screenMirror)
        self.prgRom = rom.program
        self.gameloopCallback = gameloopCallback
    }

    func tick(_ cycles: UInt8) {
        self.cycles += Int(cycles)
        let nmiBefore = ppu.nmiInterrupt != nil
        //print(nmiBefore)
        self.ppu.tick(cycles * 3)
        let nmiAfter = ppu.nmiInterrupt != nil
        //print(nmiAfter)
        if !nmiBefore && nmiAfter {
            gameloopCallback(ppu)
        }

    }

    func pollNMI() -> UInt8? {
        ppu.pollNMI()
    }
}


extension Bus: Memory {
    func memRead(_ addr: UInt16) -> UInt8 {
        switch addr {
        case RAM...RAM_MIRRORS_END:
            let mirrorDownAddr = addr & 0b00000111_11111111
            return self.cpuVram[Int(mirrorDownAddr)]
        case 0x2000, 0x2001, 0x2003, 0x2005, 0x2006, 0x4014:
            //fatalError("Attempt to read from write-only PPU address \(addr)")
            return 0
        case 0x2002:
            return ppu.readStatus()
        case 0x2004:
            return ppu.readOamData()
        case 0x2007:
            return ppu.readData()
        case 0x4000...0x4015:
            return 0 // Ignore APU
        case 0x4016:
            return 0 // Ignore Joy 1
        case 0x4017:
            return 0 // Ignore Joy 2
        case 0x2008...PPU_REGISTERS_MIRRORS_END:
            let mirrorDownAddr = addr & 0b00100000_00000111;
            return self.memRead(mirrorDownAddr)
        case ROM_ADDRESS_START...ROM_ADDRESS_END:
            return readProgramRom(addr)
        default:
            print("Ignoring mem access at \(addr)")
            return 0
        }
    }

    func memWrite(_ addr: UInt16, data: UInt8) {
        switch addr {
        case RAM...RAM_MIRRORS_END:
            let mirrorDownAddr = addr & 0b11111111111
            self.cpuVram[Int(mirrorDownAddr)] = data
        case 0x2000:
            ppu.writeToCtrl(data)
        case 0x2001:
            ppu.writeToMask(data)
        case 0x2002:
            fatalError("Attempt to write to PPU status register")
        case 0x2003:
            ppu.writeToOamAddr(data)
        case 0x2004:
            ppu.writeToOamData(data)
        case 0x2005:
            ppu.writeToScroll(data)
        case 0x2006:
            ppu.writeToPPUAddr(data)
        case 0x2007:
            ppu.writeToData(data)
        case 0x2008...PPU_REGISTERS_MIRRORS_END:
            let mirrorDownAddr = addr & 0b00100000_00000111
            memWrite(mirrorDownAddr, data: data)
        case 0x4000...0x4013, 0x4015:
            return // Ignore APU
        case 0x4016:
            return // ignore Joy 1
        case 0x4017:
            return // Ignore Joy 2
        case 0x4014:
            var buffer = [UInt8](repeating: 0, count: 256)
            let hi = UInt16(data) << 8
            for i in 0..<256 {
                buffer[i] = memRead(hi + UInt16(i))
            }

            ppu.writeOamDma(buffer)
        case ROM_ADDRESS_START...ROM_ADDRESS_END:
            fatalError("Attempt to write to Cartridge ROM space: \(addr)")
        default:
            print("Ignorming mem-write at \(addr)")
        }
    }

    func readProgramRom(_ addr: UInt16) -> UInt8 {
        var addr = addr - 0x8000
        if prgRom.count == 0x4000 && addr >= 0x4000 {
            // rom mirroring
            addr = addr % 0x4000
        }
        return prgRom[Int(addr)]
    }
}
