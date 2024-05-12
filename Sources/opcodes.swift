struct OpCode {
    let code: UInt8
    let mnemonic: String
    let len: UInt8
    let cycles: UInt8
    let mode: AddressingMode
}

let CPU_OP_CODES: [OpCode] = [
    OpCode(code: 0x00, mnemonic: "BRK", len: 1, cycles: 7, mode: .NoneAddressing),
    OpCode(code: 0xea, mnemonic: "NOP", len: 1, cycles: 2, mode: .NoneAddressing),

    /// Arithmetic
    OpCode(code: 0x69, mnemonic: "ADC", len: 2, cycles: 2, mode: .Immediate),
    OpCode(code: 0x65, mnemonic: "ADC", len: 2, cycles: 3, mode: .ZeroPage),
    OpCode(code: 0x75, mnemonic: "ADC", len: 2, cycles: 4, mode: .ZeroPage_X),
    OpCode(code: 0x6d, mnemonic: "ADC", len: 3, cycles: 4, mode: .Absolute),
    OpCode(code: 0x7d, mnemonic: "ADC", len: 3, cycles: 4 /* +1 if page crossed */, mode: .Absolute_X),
    OpCode(code: 0x79, mnemonic: "ADC", len: 2, cycles: 5 /* +1 if page crossed */, mode: .Absolute_Y),
    OpCode(code: 0x61, mnemonic: "ADC", len: 2, cycles: 5, mode: .Indirect_X),
    OpCode(code: 0x71, mnemonic: "ADC", len: 2, cycles: 5 /* +1 if page crossed */, mode: .Indirect_Y),

    OpCode(code: 0xe9, mnemonic: "SBC", len: 2, cycles: 2, mode: .Immediate),
    OpCode(code: 0xe5, mnemonic: "SBC", len: 2, cycles: 3, mode: .ZeroPage),
    OpCode(code: 0xf5, mnemonic: "SBC", len: 2, cycles: 4, mode: .ZeroPage_X),
    OpCode(code: 0xed, mnemonic: "SBC", len: 3, cycles: 4, mode: .Absolute),
    OpCode(code: 0xfd, mnemonic: "SBC", len: 3, cycles: 4 /* +1 if page crossed */, mode: .Absolute_X),
    OpCode(code: 0xf9, mnemonic: "SBC", len: 3, cycles: 4 /* +1 if page crossed */, mode: .Absolute_Y),
    OpCode(code: 0xe1, mnemonic: "SBC", len: 2, cycles: 6, mode: .Indirect_X),
    OpCode(code: 0xf1, mnemonic: "SBC", len: 2, cycles: 5 /* +1 if page crossed */, mode: .Indirect_Y),

    OpCode(code: 0x29, mnemonic: "AND", len: 2, cycles: 2, mode: .Immediate),
    OpCode(code: 0x25, mnemonic: "AND", len: 2, cycles: 3, mode: .ZeroPage),
    OpCode(code: 0x35, mnemonic: "AND", len: 2, cycles: 4, mode: .ZeroPage_X),
    OpCode(code: 0x2d, mnemonic: "AND", len: 3, cycles: 4, mode: .Absolute),
    OpCode(code: 0x3d, mnemonic: "AND", len: 3, cycles: 4 /* +1 if page crossed */, mode: .Absolute_X),
    OpCode(code: 0x39, mnemonic: "AND", len: 3, cycles: 4 /* +1 if page crossed */, mode: .Absolute_Y),
    OpCode(code: 0x21, mnemonic: "AND", len: 2, cycles: 6, mode: .Indirect_X),
    OpCode(code: 0x31, mnemonic: "AND", len: 2, cycles: 5 /* +1 if page crossed */, mode: .Indirect_Y),

    OpCode(code: 0x49, mnemonic: "EOR", len: 2, cycles: 2, mode: .Immediate),
    OpCode(code: 0x45, mnemonic: "EOR", len: 2, cycles: 3, mode: .ZeroPage),
    OpCode(code: 0x55, mnemonic: "EOR", len: 2, cycles: 4, mode: .ZeroPage_X),
    OpCode(code: 0x4d, mnemonic: "EOR", len: 3, cycles: 4, mode: .Absolute),
    OpCode(code: 0x5d, mnemonic: "EOR", len: 3, cycles: 4 /* +1 if page crossed */, mode: .Absolute_X),
    OpCode(code: 0x59, mnemonic: "EOR", len: 3, cycles: 4 /* +1 if page crossed */, mode: .Absolute_Y),
    OpCode(code: 0x41, mnemonic: "EOR", len: 2, cycles: 6, mode: .Indirect_X),
    OpCode(code: 0x51, mnemonic: "EOR", len: 2, cycles: 5 /* +1 if page crossed */, mode: .Indirect_Y),

    OpCode(code: 0x09, mnemonic: "ORA", len: 2, cycles: 2, mode: .Immediate),
    OpCode(code: 0x05, mnemonic: "ORA", len: 2, cycles: 3, mode: .ZeroPage),
    OpCode(code: 0x15, mnemonic: "ORA", len: 2, cycles: 4, mode: .ZeroPage_X),
    OpCode(code: 0x0d, mnemonic: "ORA", len: 3, cycles: 4, mode: .Absolute),
    OpCode(code: 0x1d, mnemonic: "ORA", len: 3, cycles: 4 /* +1 if page crossed */, mode: .Absolute_X),
    OpCode(code: 0x19, mnemonic: "ORA", len: 3, cycles: 4 /* +1 if page crossed */, mode: .Absolute_Y),
    OpCode(code: 0x01, mnemonic: "ORA", len: 2, cycles: 6, mode: .Indirect_X),
    OpCode(code: 0x11, mnemonic: "ORA", len: 2, cycles: 5 /* +1 if page crossed */, mode: .Indirect_Y),

    /// Shifts
    OpCode(code: 0x0a, mnemonic: "ASL", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0x06, mnemonic: "ASL", len: 2, cycles: 5, mode: .ZeroPage),
    OpCode(code: 0x16, mnemonic: "ASL", len: 2, cycles: 6, mode: .ZeroPage_X),
    OpCode(code: 0x0e, mnemonic: "ASL", len: 3, cycles: 6, mode: .Absolute),
    OpCode(code: 0x1e, mnemonic: "ASL", len: 3, cycles: 7, mode: .Absolute_X),

    OpCode(code: 0x4a, mnemonic: "LSR", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0x46, mnemonic: "LSR", len: 2, cycles: 5, mode: .ZeroPage),
    OpCode(code: 0x56, mnemonic: "LSR", len: 2, cycles: 6, mode: .ZeroPage_X),
    OpCode(code: 0x4e, mnemonic: "LSR", len: 3, cycles: 6, mode: .Absolute),
    OpCode(code: 0x5e, mnemonic: "LSR", len: 3, cycles: 7, mode: .Absolute_X),

    OpCode(code: 0x2a, mnemonic: "ROL", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0x26, mnemonic: "ROL", len: 2, cycles: 5, mode: .ZeroPage),
    OpCode(code: 0x36, mnemonic: "ROL", len: 2, cycles: 6, mode: .ZeroPage_X),
    OpCode(code: 0x2e, mnemonic: "ROL", len: 3, cycles: 6, mode: .Absolute),
    OpCode(code: 0x3e, mnemonic: "ROL", len: 3, cycles: 7, mode: .Absolute_X),

    OpCode(code: 0x6a, mnemonic: "ROR", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0x66, mnemonic: "ROR", len: 2, cycles: 5, mode: .ZeroPage),
    OpCode(code: 0x76, mnemonic: "ROR", len: 2, cycles: 6, mode: .ZeroPage_X),
    OpCode(code: 0x6e, mnemonic: "ROR", len: 3, cycles: 6, mode: .Absolute),
    OpCode(code: 0x7e, mnemonic: "ROR", len: 3, cycles: 7, mode: .Absolute_X),

    OpCode(code: 0xe6, mnemonic: "INC", len: 2, cycles: 5, mode: .ZeroPage),
    OpCode(code: 0xf6, mnemonic: "INC", len: 2, cycles: 6, mode: .ZeroPage_X),
    OpCode(code: 0xee, mnemonic: "INC", len: 3, cycles: 6, mode: .Absolute),
    OpCode(code: 0xfe, mnemonic: "INC", len: 3, cycles: 7, mode: .Absolute_X),

    OpCode(code: 0xe8, mnemonic: "INX", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0xc8, mnemonic: "INY", len: 1, cycles: 2, mode: .NoneAddressing),

    OpCode(code: 0xc6, mnemonic: "DEC", len: 2, cycles: 5, mode: .ZeroPage),
    OpCode(code: 0xd6, mnemonic: "DEC", len: 2, cycles: 6, mode: .ZeroPage_X),
    OpCode(code: 0xce, mnemonic: "DEC", len: 3, cycles: 6, mode: .Absolute),
    OpCode(code: 0xde, mnemonic: "DEC", len: 3, cycles: 7, mode: .Absolute_X),

    OpCode(code: 0xca, mnemonic: "DEX", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0x88, mnemonic: "DEY", len: 1, cycles: 2, mode: .NoneAddressing),

    OpCode(code: 0xc9, mnemonic: "CMP", len: 2, cycles: 2, mode: .Immediate),
    OpCode(code: 0xc5, mnemonic: "CMP", len: 2, cycles: 3, mode: .ZeroPage),
    OpCode(code: 0xd5, mnemonic: "CMP", len: 2, cycles: 4, mode: .ZeroPage_X),
    OpCode(code: 0xcd, mnemonic: "CMP", len: 3, cycles: 4, mode: .Absolute),
    OpCode(code: 0xdd, mnemonic: "CMP", len: 3, cycles: 4 /* +1 if page crossed */, mode: .Absolute_X),
    OpCode(code: 0xd9, mnemonic: "CMP", len: 3, cycles: 4 /* +1 if page crossed */, mode: .Absolute_Y),
    OpCode(code: 0xc1, mnemonic: "CMP", len: 2, cycles: 6, mode: .Indirect_X),
    OpCode(code: 0xd1, mnemonic: "CMP", len: 2, cycles: 5 /* +1 if page crossed */, mode: .Indirect_Y),

    OpCode(code: 0xc0, mnemonic: "CPY", len: 2, cycles: 2, mode: .Immediate),
    OpCode(code: 0xc4, mnemonic: "CPY", len: 2, cycles: 3, mode: .ZeroPage),
    OpCode(code: 0xcc, mnemonic: "CPY", len: 3, cycles: 4, mode: .Absolute),

    OpCode(code: 0xe0, mnemonic: "CPX", len: 2, cycles: 2, mode: .Immediate),
    OpCode(code: 0xe4, mnemonic: "CPX", len: 2, cycles: 3, mode: .ZeroPage),
    OpCode(code: 0xec, mnemonic: "CPX", len: 3, cycles: 4, mode: .Absolute),

    /// Branching
    OpCode(code: 0x4c, mnemonic: "JMP", len: 3, cycles: 3, mode: .NoneAddressing), // AddressingMode that acts as Immidiate
    OpCode(code: 0x6c, mnemonic: "JMP", len: 3, cycles: 5, mode: .NoneAddressing), // AddressingMode.Indirect with 6502 bug

    OpCode(code: 0x20, mnemonic: "JSR", len: 3, cycles: 6, mode: .NoneAddressing),
    OpCode(code: 0x60, mnemonic: "RTS", len: 1, cycles: 6, mode: .NoneAddressing),
    OpCode(code: 0x40, mnemonic: "RTI", len: 1, cycles: 6, mode: .NoneAddressing),

    OpCode(code: 0xd0, mnemonic: "BNE", len: 2, cycles: 2 /* +1 if branch succeeds +2 of to a new page */ , mode: .NoneAddressing),
    OpCode(code: 0x70, mnemonic: "BVS", len: 2, cycles: 2 /* +1 if branch succeeds +2 of to a new page */ , mode: .NoneAddressing),
    OpCode(code: 0x50, mnemonic: "BVC", len: 2, cycles: 2 /* +1 if branch succeeds +2 of to a new page */ , mode: .NoneAddressing),
    OpCode(code: 0x30, mnemonic: "BMI", len: 2, cycles: 2 /* +1 if branch succeeds +2 of to a new page */ , mode: .NoneAddressing),
    OpCode(code: 0xf0, mnemonic: "BEQ", len: 2, cycles: 2 /* +1 if branch succeeds +2 of to a new page */ , mode: .NoneAddressing),
    OpCode(code: 0xb0, mnemonic: "BCS", len: 2, cycles: 2 /* +1 if branch succeeds +2 of to a new page */ , mode: .NoneAddressing),
    OpCode(code: 0x90, mnemonic: "BCC", len: 2, cycles: 2 /* +1 if branch succeeds +2 of to a new page */ , mode: .NoneAddressing),
    OpCode(code: 0x10, mnemonic: "BPL", len: 2, cycles: 2 /* +1 if branch succeeds +2 of to a new page */ , mode: .NoneAddressing),

    OpCode(code: 0x24, mnemonic: "BIT", len: 2, cycles: 3, mode: .ZeroPage),
    OpCode(code: 0x2c, mnemonic: "BIT", len: 3, cycles: 4, mode: .Absolute),

    /// Stores, Loads
    OpCode(code: 0xa9, mnemonic: "LDA", len: 2, cycles: 2, mode: .Immediate),
    OpCode(code: 0xa5, mnemonic: "LDA", len: 2, cycles: 3, mode: .ZeroPage),
    OpCode(code: 0xb5, mnemonic: "LDA", len: 2, cycles: 4, mode: .ZeroPage_X),
    OpCode(code: 0xad, mnemonic: "LDA", len: 3, cycles: 4, mode: .Absolute),
    OpCode(code: 0xbd, mnemonic: "LDA", len: 3, cycles: 4 /* +1 if page crossed */, mode: .Absolute_X),
    OpCode(code: 0xb9, mnemonic: "LDA", len: 3, cycles: 4 /* +1 if page crossed */, mode: .Absolute_Y),
    OpCode(code: 0xa1, mnemonic: "LDA", len: 2, cycles: 6, mode: .Indirect_X),
    OpCode(code: 0xb1, mnemonic: "LDA", len: 2, cycles: 5 /* +1 if page crossed */, mode: .Indirect_Y),

    OpCode(code: 0xa2, mnemonic: "LDX", len: 2, cycles: 2, mode: .Immediate),
    OpCode(code: 0xa6, mnemonic: "LDX", len: 2, cycles: 3, mode: .ZeroPage),
    OpCode(code: 0xb6, mnemonic: "LDX", len: 2, cycles: 4, mode: .ZeroPage_Y),
    OpCode(code: 0xae, mnemonic: "LDX", len: 3, cycles: 4, mode: .Absolute),
    OpCode(code: 0xbe, mnemonic: "LDX", len: 3, cycles: 4 /* +1 if page crossed */, mode: .Absolute_Y),

    OpCode(code: 0xa0, mnemonic: "LDY", len: 2, cycles: 2, mode: .Immediate),
    OpCode(code: 0xa4, mnemonic: "LDY", len: 2, cycles: 3, mode: .ZeroPage),
    OpCode(code: 0xb4, mnemonic: "LDY", len: 2, cycles: 4, mode: .ZeroPage_X),
    OpCode(code: 0xac, mnemonic: "LDY", len: 3, cycles: 4, mode: .Absolute),
    OpCode(code: 0xbc, mnemonic: "LDY", len: 3, cycles: 4 /* +1 if page crossed */, mode: .Absolute_X),

    OpCode(code: 0x85, mnemonic: "STA", len: 2, cycles: 3, mode: .ZeroPage),
    OpCode(code: 0x95, mnemonic: "STA", len: 2, cycles: 4, mode: .ZeroPage_X),
    OpCode(code: 0x8d, mnemonic: "STA", len: 3, cycles: 4, mode: .Absolute),
    OpCode(code: 0x9d, mnemonic: "STA", len: 3, cycles: 5, mode: .Absolute_X),
    OpCode(code: 0x99, mnemonic: "STA", len: 3, cycles: 5, mode: .Absolute_Y),
    OpCode(code: 0x81, mnemonic: "STA", len: 2, cycles: 6, mode: .Indirect_X),
    OpCode(code: 0x91, mnemonic: "STA", len: 2, cycles: 6, mode: .Indirect_Y),

    OpCode(code: 0x86, mnemonic: "STX", len: 2, cycles: 3, mode: .ZeroPage),
    OpCode(code: 0x96, mnemonic: "STX", len: 2, cycles: 4, mode: .Absolute_Y),
    OpCode(code: 0x8e, mnemonic: "STX", len: 3, cycles: 4, mode: .Absolute),

    OpCode(code: 0x84, mnemonic: "STY", len: 2, cycles: 3, mode: .ZeroPage),
    OpCode(code: 0x94, mnemonic: "STY", len: 2, cycles: 4, mode: .Absolute_X),
    OpCode(code: 0x8c, mnemonic: "STY", len: 3, cycles: 4, mode: .Absolute),

    /// Flag Clears
    OpCode(code: 0xd8, mnemonic: "CLD", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0x58, mnemonic: "CLI", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0xb8, mnemonic: "CLV", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0x18, mnemonic: "CLC", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0x38, mnemonic: "SEC", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0x78, mnemonic: "SEI", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0xf8, mnemonic: "SED", len: 1, cycles: 2, mode: .NoneAddressing),

    OpCode(code: 0xaa, mnemonic: "TAX", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0xa8, mnemonic: "TAY", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0xba, mnemonic: "TSX", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0x8a, mnemonic: "TXA", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0x9a, mnemonic: "TXS", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0x98, mnemonic: "TYA", len: 1, cycles: 2, mode: .NoneAddressing),

    /// Stack
    OpCode(code: 0x48, mnemonic: "PHA", len: 1, cycles: 3, mode: .NoneAddressing),
    OpCode(code: 0x68, mnemonic: "PLA", len: 1, cycles: 4, mode: .NoneAddressing),
    OpCode(code: 0x08, mnemonic: "PHP", len: 1, cycles: 3, mode: .NoneAddressing),
    OpCode(code: 0x28, mnemonic: "PLP", len: 1, cycles: 4, mode: .NoneAddressing),
]

let OPCODES_MAP: [UInt8: OpCode] = {
    var map: [UInt8:OpCode] = [:]
    for cpuop in CPU_OP_CODES {
        guard map[cpuop.code] == nil else {fatalError("Duplicate opcode \(cpuop) and \(map[cpuop.code]!)")}
        map[cpuop.code] = cpuop
    }
    return map
}()
