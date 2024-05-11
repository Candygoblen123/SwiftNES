

enum AddressingMode {
   case Immediate
   case ZeroPage
   case ZeroPage_X
   case ZeroPage_Y
   case Absolute
   case Absolute_X
   case Absolute_Y
   case Indirect_X
   case Indirect_Y
   case NoneAddressing
}

class CPU {
    var register_a: UInt8 = 0
    var register_x: UInt8 = 0
    var register_y: UInt8 = 0

    var status: UInt8 = 0
    var programCounter: UInt16 = 0
    private var memory = [UInt8](repeating: 0, count: 0xFFFF)


    func getOpperandAddress(_ mode: AddressingMode) -> UInt16 {
        switch mode {
        case .Immediate:
            return programCounter
        case .ZeroPage:
            return UInt16(memRead(programCounter))
        case .Absolute:
            return memReadU16(programCounter)
        case .ZeroPage_X:
            let pos = memRead(programCounter)
            let addr = pos &+ register_x
            return UInt16(addr)
        case .ZeroPage_Y:
            let pos = memRead(programCounter)
            let addr = pos &+ register_y
            return UInt16(addr)
        case .Absolute_X:
            let base = memReadU16(programCounter)
            return base &+ UInt16(register_x)
        case .Absolute_Y:
            let base = memReadU16(programCounter)
            return base &+ UInt16(register_y)
        case .Indirect_X:
            let base = memRead(programCounter)

            let ptr = UInt8(base) &+ register_x
            let lo = memRead(UInt16(ptr))
            let hi = memRead(UInt16(ptr &+ 1))
            return UInt16(hi) << 8 | UInt16(lo)
        case .Indirect_Y:
            let base = memRead(programCounter)

            let lo = memRead(UInt16(base))
            let hi = memRead(UInt16(base &+ 1))
            let deref_base = UInt16(hi) << 8 | UInt16(lo)
            let deref = deref_base &+ UInt16(register_y)
            return deref
        case .NoneAddressing:
            fatalError("mode \(mode) is not implemented")
        }
    }

    func memRead(_ addr: UInt16) -> UInt8 {
        memory[Int(addr)]
    }

    func memReadU16(_ addr: UInt16) -> UInt16 {
        let lo = UInt16(memRead(addr))
        let hi = UInt16(memRead(addr + 1))
        return (hi << 8) | lo
    }

    func memWriteU16(addr: UInt16, data: UInt16) {
        let hi = UInt8(data >> 8)
        let lo = UInt8(data & 0xff)
        self.memWrite(addr: addr, data: lo)
        self.memWrite(addr: addr + 1, data: hi)
    }

    func memWrite(addr: UInt16, data: UInt8) {
        memory[Int(addr)] = data
    }

    func reset() {
        register_a = 0
        register_x = 0
        register_y = 0
        status = 0

        programCounter = self.memReadU16(0xFFFC)
    }

    func loadAndRun(_ program: [UInt8]) {
        load(program)
        reset()
        run()
    }

    func load(_ program: [UInt8]) {
        memory[0x8000 ..< (0x8000 + program.count)] = program[0..<program.count]
        memWriteU16(addr: 0xFFFC, data: 0x8000)
    }

    func run() {
        let opcodes = OPCODES_MAP

        while true {
            let code = memRead(programCounter)
            programCounter += 1

            let programCounterState = programCounter
            guard let opcode = opcodes[code] else {fatalError("OpCode \(code) not recgonized!")}

            switch code {
            /// LDA
            case 0xa9, 0xa5, 0xb5, 0xad, 0xbd, 0xb9, 0xa1, 0xb1:
                lda(opcode.mode)
            /// STA
            case 0x85, 0x95, 0x8d, 0x9d, 0x99, 0x81, 0x91:
                sta(opcode.mode)
            /// TAX
            case 0xAA:
                tax()
            /// INX
            case 0xE8:
                inx()
            /// BRK
            case 0x00:
                return
            default: fatalError("TODO!")
            }

            if programCounterState == programCounter {
                programCounter += UInt16(opcode.len - 1)
            }
        }
    }

    func updateZeroAndNegativeFlags(_ result: UInt8) {
        if result == 0 {
            status = status | 0b0000_0010
        } else {
            status = status & 0b1111_1101
        }

        if result & 0b1000_0000 != 0 {
            status = status | 0b1000_0000
        } else {
            status = status & 0b0111_1111
        }
    }

    func lda(_ mode: AddressingMode) {
        let addr = getOpperandAddress(mode)
        let value = memRead(addr)

        register_a = value
        updateZeroAndNegativeFlags(register_a)
    }

    func tax() {
        register_x = register_a
        updateZeroAndNegativeFlags(register_x)
    }

    func inx() {
        register_x = register_x &+ 1
        updateZeroAndNegativeFlags(register_x)
    }

    func sta(_ mode: AddressingMode) {
        let addr = getOpperandAddress(mode)
        memWrite(addr: addr, data: register_a)
    }


}
