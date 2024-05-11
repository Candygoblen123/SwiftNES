// The Swift Programming Language
// https://docs.swift.org/swift-book

let cpu = CPU()
let program: [UInt8] = [0xa9, 0xc0, 0xaa, 0xe8, 0x00]
cpu.loadAndRun(program)
print(cpu.status)
