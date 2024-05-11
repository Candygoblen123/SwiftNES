struct OpCode {
    let code: UInt8
    let mnemonic: String
    let len: UInt8
    let cycles: UInt8
    let mode: AddressingMode
}

let CPU_OP_CODES: [OpCode] = [
    OpCode(code: 0x00, mnemonic: "BRK", len: 1, cycles: 7, mode: .NoneAddressing),
    OpCode(code: 0xaa, mnemonic: "TAX", len: 1, cycles: 2, mode: .NoneAddressing),
    OpCode(code: 0xe8, mnemonic: "INX", len: 1, cycles: 2, mode: .NoneAddressing),

    OpCode(code: 0xa9, mnemonic: "LDA", len: 2, cycles: 2, mode: .Immediate),
    OpCode(code: 0xa5, mnemonic: "LDA", len: 2, cycles: 3, mode: .ZeroPage),
    OpCode(code: 0xb5, mnemonic: "LDA", len: 2, cycles: 4, mode: .ZeroPage_X),
    OpCode(code: 0xad, mnemonic: "LDA", len: 3, cycles: 4, mode: .Absolute),
    OpCode(code: 0xbd, mnemonic: "LDA", len: 3, cycles: 4 /* +1 if page crossed */, mode: .Absolute_X),
    OpCode(code: 0xb9, mnemonic: "LDA", len: 3, cycles: 4 /* +1 if page crossed */, mode: .Absolute_Y),
    OpCode(code: 0xa1, mnemonic: "LDA", len: 2, cycles: 6, mode: .Indirect_X),
    OpCode(code: 0xb1, mnemonic: "LDA", len: 2, cycles: 5 /* +1 if page crossed */, mode: .Indirect_Y),

    OpCode(code: 0xa5, mnemonic: "STA", len: 2, cycles: 3, mode: .ZeroPage),
    OpCode(code: 0x95, mnemonic: "STA", len: 2, cycles: 4, mode: .ZeroPage_X),
    OpCode(code: 0x8d, mnemonic: "STA", len: 3, cycles: 4, mode: .Absolute),
    OpCode(code: 0x9d, mnemonic: "STA", len: 3, cycles: 5, mode: .Absolute_X),
    OpCode(code: 0x99, mnemonic: "STA", len: 3, cycles: 5, mode: .Absolute_Y),
    OpCode(code: 0x81, mnemonic: "STA", len: 2, cycles: 6, mode: .Indirect_X),
    OpCode(code: 0x91, mnemonic: "STA", len: 2, cycles: 6, mode: .Indirect_Y),
]

let OPCODES_MAP: [UInt8: OpCode] = {
    var map: [UInt8:OpCode] = [:]
    for cpuop in CPU_OP_CODES {
        map[cpuop.code] = cpuop
    }
    return map
}()
