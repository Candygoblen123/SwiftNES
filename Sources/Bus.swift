class Bus {
    var cpuVram: [UInt8] = .init(repeating: 0, count: 2048)
    var rom: Rom

    fileprivate let RAM : UInt16 = 0x0000
    fileprivate let RAM_MIRRORS_END: UInt16 = 0x1FFF
    fileprivate let PPU_REGISTERS: UInt16 = 0x2000
    fileprivate let PPU_REGISTERS_MIRRORS_END: UInt16 = 0x3FFF
    fileprivate let ROM_ADDRESS_START: UInt16 = 0x8000
    fileprivate let ROM_ADDRESS_END: UInt16 = 0xFFFF

    init(_ rom: Rom) {
        self.rom = rom
    }
}


extension Bus: Memory {
    func memRead(_ addr: UInt16) -> UInt8 {
        switch addr {
        case RAM...RAM_MIRRORS_END:
            let mirrorDownAddr = addr & 0b00000111_11111111
            return self.cpuVram[Int(mirrorDownAddr)]
        case PPU_REGISTERS...PPU_REGISTERS_MIRRORS_END:
            let mirrorDownAddr = addr & 0b00100000_00000111;
            fatalError("PPU not implemented yet")
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
        case PPU_REGISTERS...PPU_REGISTERS_MIRRORS_END:
            let mirrorDownAddr = addr & 0b00100000_00000111
            fatalError("PPU is not implemented yet!")
        default:
            print("Ignorming mem-write at \(addr)")
        }
    }

    func readProgramRom(_ addr: UInt16) -> UInt8 {
        var addr = addr - 0x8000
        if rom.program.count == 0x4000 && addr >= 0x4000 {
            // rom mirroring
            addr = addr % 0x4000
        }
        return rom.program[Int(addr)]
    }
}
