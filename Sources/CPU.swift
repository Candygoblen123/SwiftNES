import Foundation
import SDL

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

struct CPUFlags: OptionSet {
    var rawValue: UInt8

    static let carry = CPUFlags(rawValue: 0b00000001)
    static let zero = CPUFlags(rawValue: 0b00000010)
    static let interruptDisable = CPUFlags(rawValue: 0b00000100)
    static let decimalMode = CPUFlags(rawValue: 0b00001000)
    static let break1 = CPUFlags(rawValue: 0b00010000)
    static let break2 = CPUFlags(rawValue: 0b00100000)
    static let overflow = CPUFlags(rawValue: 0b01000000)
    static let negative = CPUFlags(rawValue: 0b10000000)
}

let STACK: UInt16 = 0x0100
let STACK_RESET: UInt8 = 0xfd

class CPU {
    var register_a: UInt8 = 0
    var register_x: UInt8 = 0
    var register_y: UInt8 = 0
    var stackPointer: UInt8 = STACK_RESET
    var status: CPUFlags = [.interruptDisable, .break2]
    var programCounter: UInt16 = 0
    var bus = Bus()


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

    func reset() {
        register_a = 0
        register_x = 0
        register_y = 0
        stackPointer = STACK_RESET
        status = [.interruptDisable, .break2]

        programCounter = self.memReadU16(0xFFFC)
    }

    func loadAndRun(_ program: [UInt8]) {
        load(program)
        reset()
        run()
    }

    func load(_ program: [UInt8]) {
        //memory[0x0600 ..< (0x0600 + program.count)] = program[0..<program.count]
        memWriteU16(0xFFFC, data: 0x0600)
    }

    func run() {
        run(onCycle: {}, onComplete: {})
    }

    func run(onCycle: @escaping () -> (), onComplete: @escaping () -> ())  {
        let opcodes = OPCODES_MAP
        _ = Timer.scheduledTimer(withTimeInterval: 0.00007, repeats: true) { [self] timer in
            processOpcodes(onCycle: onCycle, opcodes: opcodes, timer: timer) {
                onComplete()
            }
        }
    }

    func processOpcodes(onCycle: () -> (), opcodes: [UInt8: OpCode], timer: Timer, onComplete: () -> ()) {
        onCycle()
        let code = memRead(programCounter)
        programCounter += 1

        let programCounterState = programCounter
        guard let opcode = opcodes[code] else {fatalError("OpCode \(code) not recgonized!")}
        // print(programCounter, opcode.mnemonic)

        switch code {
        /// LDA
        case 0xa9, 0xa5, 0xb5, 0xad, 0xbd, 0xb9, 0xa1, 0xb1:
            lda(opcode.mode)
        /// STA
        case 0x85, 0x95, 0x8d, 0x9d, 0x99, 0x81, 0x91:
            sta(opcode.mode)
        case 0xd8:
            status.remove(.decimalMode)
        case 0x58:
            status.remove(.interruptDisable)
        case 0xb8:
            status.remove(.overflow)
        case 0x18:
            clearCarryFlag()
        case 0x38:
            setCarryFlag()
        case 0x78:
            status.insert(.interruptDisable)
        case 0xf8:
            status.insert(.decimalMode)
        case 0x48:
            stackPush(register_a)
        case 0x68:
            pla()
        case 0x08:
            php()
        case 0x28:
            plp()
        case 0x69, 0x65, 0x75, 0x6d, 0x7d, 0x79, 0x61, 0x71:
            adc(opcode.mode)
        case 0xe9, 0xe5, 0xf5, 0xed, 0xfd, 0xf9, 0xe1, 0xf1:
            sbc(opcode.mode)
        case 0x29, 0x25, 0x35, 0x2d, 0x3d, 0x39, 0x21, 0x31:
            and(opcode.mode)
        case 0x49, 0x45, 0x55, 0x4d, 0x5d, 0x59, 0x41, 0x51:
            eor(opcode.mode)
        case 0x09, 0x05, 0x15, 0x0d, 0x1d, 0x19, 0x01, 0x11:
            ora(opcode.mode)
        case 0x4a:
            lsrAccumulator()
        case 0x46, 0x56, 0x4e, 0x5e:
            _ = lsr(opcode.mode)
        case 0x0a:
            aslAccumulator()
        case 0x06, 0x16, 0x0e, 0x1e:
            _ = asl(opcode.mode)
        case 0x2a:
            rolAccumulator()
        case 0x26, 0x36, 0x2e, 0x3e:
            _ = rol(opcode.mode)
        case 0x6a:
            rorAccumulator()
        case 0x66, 0x76, 0x6e, 0x7e:
            _ = ror(opcode.mode)
        case 0xe6, 0xf6, 0xee, 0xfe:
            _ = inc(opcode.mode)
        case 0xc8:
            iny()
        case 0xc6, 0xd6, 0xce, 0xde:
            _ = dec(opcode.mode)
        case 0xca:
            dex()
        case 0x88:
            dey()
        case 0xc9, 0xc5, 0xd5, 0xcd, 0xdd, 0xd9, 0xc1, 0xd1:
            compare(mode: opcode.mode, compare_with: register_a)
        case 0xc0, 0xc4, 0xcc:
            compare(mode: opcode.mode, compare_with: register_y)
        case 0xe0, 0xe4, 0xec:
            compare(mode: opcode.mode, compare_with: register_x)
        case 0x4c:
            let memAddr = memReadU16(programCounter)
            programCounter = memAddr
        case 0x6c:
            let memAddr = memReadU16(programCounter)
            //6502 bug mode with with page boundary:
            //  if address $3000 contains $40, $30FF contains $80, and $3100 contains $50,
            // the result of JMP ($30FF) will be a transfer of control to $4080 rather than $5080 as you intended
            // i.e. the 6502 took the low byte of the address from $30FF and the high byte from $3000
            let indirectRef: UInt16
            if memAddr & 0x00ff == 0x00ff {
                let lo = memRead(memAddr)
                let hi = memRead(memAddr & 0x00ff)
                indirectRef = UInt16(hi) << 8 | UInt16(lo)
            } else {
                indirectRef = memReadU16(memAddr)
            }

            programCounter = indirectRef

        case 0x20:
            stackPushU16(programCounter + 2 - 1)
            let targetAddr = memReadU16(programCounter)
            programCounter = targetAddr
        case 0x60:
            programCounter = stackPopU16() + 1
        case 0x40:
            status.rawValue = stackPop()
            status.remove(.break1)
            status.remove(.break2)

            programCounter = stackPopU16()
        case 0xd0:
            branch(!status.contains(.zero))
        case 0x70:
            branch(status.contains(.overflow))
        case 0x50:
            branch(!status.contains(.overflow))
        case 0x10:
            branch(!status.contains(.negative))
        case 0x30:
            branch(status.contains(.negative))
        case 0xf0:
            branch(status.contains(.zero))
        case 0xb0:
            branch(status.contains(.carry))
        case 0x90:
            branch(!status.contains(.carry))
        case 0x24, 0x2c:
            bit(opcode.mode)
        case 0x86, 0x96, 0x8e:
            let addr = getOpperandAddress(opcode.mode)
            memWrite(addr, data: register_x)
        case 0x84, 0x94, 0x8c:
            let addr = getOpperandAddress(opcode.mode)
            memWrite(addr, data: register_y)
        case 0xa2, 0xa6, 0xb6, 0xae, 0xbe:
            ldx(opcode.mode)
        case 0xa0, 0xa4, 0xb4, 0xac, 0xbc:
            ldy(opcode.mode)
        case 0xea:
            return
        case 0xa8:
            register_y = register_x
            updateZeroAndNegativeFlags(register_y)
        case 0xba:
            register_x = stackPointer
            updateZeroAndNegativeFlags(register_x)
        case 0x8a:
            register_a = register_x
            updateZeroAndNegativeFlags(register_a)
        case 0x9a:
            stackPointer = register_x
        case 0x98:
            register_a = register_y
            updateZeroAndNegativeFlags(register_a)
        /// TAX
        case 0xaa:
            tax()
        /// INX
        case 0xe8:
            inx()
        /// BRK
        case 0x00:
            timer.invalidate()
            onComplete()
        default: fatalError("TODO!")
        }

        if programCounterState == programCounter {
            programCounter += UInt16(opcode.len - 1)
        }
    }

    func updateZeroAndNegativeFlags(_ result: UInt8) {
        if result == 0 {
            status.insert(.zero)
        } else {
            status.remove(.zero)
        }

        if result & 0b1000_0000 != 0 {
            status.insert(.negative)
        } else {
            status.remove(.negative)
        }
    }

    func setRegisterA(_ value: UInt8) {
        register_a = value
        updateZeroAndNegativeFlags(register_a)
    }

    func setCarryFlag() {
        status.insert(.carry)
    }

    func clearCarryFlag() {
        status.remove(.carry)
    }

    /// note: ignoring decimal mode
    /// http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
    func addToRegisterA(_ data: UInt8) {
        let shouldCarry = status.contains(.carry) ? 1 : 0
        let sum = UInt16(register_a) + UInt16(data) + UInt16(shouldCarry)

        let carry = sum > 0xff

        if carry {
            status.insert(.carry)
        } else {
            status.remove(.carry)
        }

        let result = UInt8(truncatingIfNeeded: sum)

        if (data ^ result) & (result ^ register_a) & 0x80 != 0 {
            status.insert(.overflow)
        } else {
            status.remove(.overflow)
        }

        setRegisterA(result)
    }

    func stackPop() -> UInt8 {
        stackPointer = stackPointer &+ 1
        return memRead(STACK + UInt16(stackPointer))
    }

    func stackPush(_ data: UInt8) {
        memWrite(STACK + UInt16(stackPointer), data: data)
        stackPointer = stackPointer &- 1
    }

    func stackPopU16() -> UInt16 {
        let lo = UInt16(stackPop())
        let hi = UInt16(stackPop())

        return hi << 8 | lo
    }

    func stackPushU16(_ data: UInt16) {
        let hi = UInt8(data >> 8)
        let lo = UInt8(data & 0xff)
        stackPush(hi)
        stackPush(lo)
    }

    func compare(mode: AddressingMode, compare_with: UInt8) {
        let addr = getOpperandAddress(mode)
        let data = memRead(addr)
        if data <= compare_with {
            status.insert(.carry)
        } else {
            status.remove(.carry)
        }

        updateZeroAndNegativeFlags(compare_with &- data)
    }

    func branch(_ condition: Bool) {
        if condition {
            let addr = memRead(programCounter)
            let jump: Int8 = Int8(bitPattern: addr)
            let jump_addr = programCounter &+ 1 &+ UInt16(bitPattern: Int16(jump))

            programCounter = jump_addr
        }
    }
}

extension CPU: Memory {
    func memRead(_ addr: UInt16) -> UInt8 {
        return bus.memRead(addr)
    }

    func memWrite(_ addr: UInt16, data: UInt8) {
        bus.memWrite(addr, data: data)
    }

    func memReadU16(_ addr: UInt16) -> UInt16 {
        return bus.memReadU16(addr)
    }

    func memWriteU16(_ addr: UInt16, data: UInt16) {
        bus.memWriteU16(addr, data: data)
    }
}


protocol Memory {
    func memRead(_ addr: UInt16) -> UInt8

    func memWrite(_ addr: UInt16, data: UInt8)

    func memReadU16(_ addr: UInt16) -> UInt16

    func memWriteU16(_ addr: UInt16, data: UInt16)
}

extension Memory {
    func memReadU16(_ addr: UInt16) -> UInt16 {
        let lo = UInt16(memRead(addr))
        let hi = UInt16(memRead(addr + 1))
        return (hi << 8) | lo
    }

    func memWriteU16(_ addr: UInt16, data: UInt16) {
        let hi = UInt8(data >> 8)
        let lo = UInt8(data & 0xff)
        self.memWrite(addr, data: lo)
        self.memWrite(addr + 1, data: hi)
    }
}
