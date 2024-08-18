import XCTest
@testable import SwiftNES

class TestRom: XCTestCase {
    func testFormatTrace() {
        let expect = XCTestExpectation()
        let bus = Bus(try! Rom(getRom()))
        bus.memWrite(100, data: 0xa2)
        bus.memWrite(101, data: 0x01)
        bus.memWrite(102, data: 0xca)
        bus.memWrite(103, data: 0x88)
        bus.memWrite(104, data: 0x00)
        let cpu = CPU(bus: bus)
        cpu.programCounter = 0x64
        cpu.register_a = 1
        cpu.register_x = 2
        cpu.register_y = 3

        var result: [String] = []
        cpu.run(
          onCycle: { result.append(dumpCpuState(cpu)) },
          onComplete: { expect.fulfill() }
        )
        wait(for: [expect], timeout: 0.5)
        XCTAssertEqual(
          "0064  A2 01     LDX #$01                        A:01 X:02 Y:03 P:24 SP:FD",
          result[0]
        )
        XCTAssertEqual(
          "0066  CA        DEX                             A:01 X:01 Y:03 P:24 SP:FD",
          result[1]
        )
        XCTAssertEqual(
          "0067  88        DEY                             A:01 X:00 Y:03 P:26 SP:FD",
          result[2]
       )
    }

    func testFormatMemAccess() {
        let expect = XCTestExpectation()
        let bus = Bus(try! Rom(getRom()))
        bus.memWrite(100, data: 0x11)
        bus.memWrite(101, data: 0x33
        )
        bus.memWrite(0x33, data: 00)
        bus.memWrite(0x34, data: 04)

        bus.memWrite(0x400, data: 0xAA)
        let cpu = CPU(bus: bus)
        cpu.programCounter = 0x64
        cpu.register_y = 0

        var result: [String] = []
        cpu.run(
          onCycle: { result.append(dumpCpuState(cpu)) },
          onComplete: { expect.fulfill() }
        )
        wait(for: [expect], timeout: 0.5)
        XCTAssertEqual(
          "0064  11 33     ORA ($33),Y = 0400 @ 0400 = AA  A:00 X:00 Y:00 P:24 SP:FD",
          result[0]
        )
    }

    func getRom() -> [UInt8] {
        guard let rom = NSData(contentsOfFile: "nestest.nes") else { fatalError("Rom not found") }
        var gameCode = [UInt8](repeating: 0, count: rom.length)
        rom.getBytes(&gameCode, length: rom.length)
        return gameCode;
    }
}
