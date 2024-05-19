import XCTest
@testable import SwiftNES

class CPUTests: XCTestCase {
    func test_lda() {
        let cpu = CPU()
        cpu.load([0xa9, 0x05, 0x00])
        cpu.reset()
        cpu.runExpect(self)

        XCTAssertEqual(cpu.register_a, 0x05)
        XCTAssert(cpu.status.rawValue & 0b0000_0010 == 0b00)
        XCTAssert(cpu.status.rawValue & 0b1000_0000 == 0)
    }

    func test_ldy() {
        let cpu = CPU()
        cpu.load([0xa0, 0x05, 0x00])
        cpu.reset()
        cpu.runExpect(self)

        XCTAssertEqual(cpu.register_y, 0x05)
        XCTAssert(cpu.status.rawValue & 0b0000_0010 == 0b00)
        XCTAssert(cpu.status.rawValue & 0b1000_0000 == 0)
    }

    func test_ldx() {
        let cpu = CPU()
        cpu.load([0xa2, 0x05, 0x00])
        cpu.reset()
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_x, 0x05)
        XCTAssert(cpu.status.rawValue & 0b0000_0010 == 0b00)
        XCTAssert(cpu.status.rawValue & 0b1000_0000 == 0)
    }

    func test_sta() {
        let cpu = CPU()
        cpu.load([0x85, 0x10, 0x00])
        cpu.reset()
        cpu.register_a = 0x55
        cpu.runExpect(self)
        XCTAssertEqual(cpu.memRead(0x10), 0x55)
    }

    func test_and() {
        let cpu = CPU()
        cpu.load([0x29, 0b0000_1001, 0x00])
        cpu.reset()
        cpu.register_a = 0b0000_1010
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_a, 0b0000_1000)
    }

    func test_eor() {
        let cpu = CPU()
        cpu.load([0x49, 0b0000_1001, 0x00])
        cpu.reset()
        cpu.register_a = 0b0000_1110
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_a, 0b0000_0111)
    }

    func test_ora() {
        let cpu = CPU()
        cpu.load([0x09, 0b0000_1001, 0x00])
        cpu.reset()
        cpu.register_a = 0b0000_1110
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_a, 0b0000_1111)
    }

    func test_tax() {
        let cpu = CPU()
        cpu.load([0xaa, 0x00])
        cpu.reset()
        cpu.register_a = 10
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_x, 10)
    }

    func test_inx() {
        let cpu = CPU()
        cpu.load([0xe8, 0x00])
        cpu.reset()
        cpu.register_x = 10
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_x, 11)
    }

    func test_inx_overflow() {
        let cpu = CPU()
        cpu.load([0xe8, 0xe8, 0x00])
        cpu.reset()
        cpu.register_x = 0xff
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_x, 1)
    }

    func test_iny() {
        let cpu = CPU()
        cpu.load([0xc8, 0x00])
        cpu.reset()
        cpu.register_y = 10
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_y, 11)
    }

    func test_iny_overflow() {
        let cpu = CPU()
        cpu.load([0xc8, 0xc8, 0x00])
        cpu.reset()
        cpu.register_y = 0xff
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_y, 1)
    }

    func test_sbc() {
        let cpu = CPU()
        cpu.load([0xe9, 2, 0x00])
        cpu.reset()
        cpu.register_a = 0x10
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_a, 0x0d)
    }

    func test_sbc_underflow() {
        let cpu = CPU()
        cpu.load([0xe9, 2, 0x00])
        cpu.reset()
        cpu.register_a = 0x00
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_a, 0xfd)
    }

    func test_adc() {
        let cpu = CPU()
        cpu.load([0x69, 2, 0x00])
        cpu.reset()
        cpu.register_a = 0x10
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_a, 0x12)
    }

    func test_adc_overflow() {
        let cpu = CPU()
        cpu.load([0x69, 2, 0x00])
        cpu.reset()
        cpu.register_a = 0xff
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_a, 0x01)
    }

    func test_asl_accumulator() {
        let cpu = CPU()
        cpu.load([0x0a, 0x00])
        cpu.reset()
        cpu.register_a = 0b0000_0001
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_a, 0b0000_0010)
    }

    func test_asl() {
        let cpu = CPU()
        cpu.load([0x06, 0x10, 0x00])
        cpu.reset()
        cpu.memWrite(0x10, data: 0b0000_0001)
        cpu.runExpect(self)
        XCTAssertEqual(cpu.memRead(0x10), 0b0000_0010)
    }

    func test_lsr_accumulator() {
        let cpu = CPU()
        cpu.load([0x4a, 0x00])
        cpu.reset()
        cpu.register_a = 0b0001_0000
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_a, 0b0000_1000)
    }

    func test_lsr() {
        let cpu = CPU()
        cpu.load([0x46, 0x10, 0x00])
        cpu.reset()
        cpu.memWrite(0x10, data: 0b0001_0000)
        cpu.runExpect(self)
        XCTAssertEqual(cpu.memRead(0x10), 0b0000_1000)
    }

    func test_rol_accumulator() {
        let cpu = CPU()
        cpu.load([0x2A, 0x00])
        cpu.reset()
        cpu.setRegisterA(0b1001_1001) // 0x99
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_a, 0b0011_0010)
    }

    func test_rol() {
        let cpu = CPU()
        cpu.load([0x26, 0x10, 0x00])
        cpu.reset()
        cpu.memWrite(0x10, data: 0b1001_1001)
        cpu.runExpect(self)
        XCTAssertEqual(cpu.memRead(0x10), 0b0011_0010)
    }

    func test_ror_accumulator() {
        let cpu = CPU()
        cpu.load([0x6a, 0x00])
        cpu.reset()
        cpu.setRegisterA(0b1001_1001)
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_a, 0b0100_1100)
    }

    func test_5_ops_working_together() {
        let cpu = CPU()
        cpu.load([0xa9, 0xc0, 0xaa, 0xe8, 0x00])
        cpu.reset()
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_x, 0xc1)
   }
}


extension XCTestExpectation {
    func wait(_ sender: XCTestCase) {
        sender.wait(for: [self], timeout: 0.1)
    }
}

extension CPU {
    func runExpect(_ sender: XCTestCase) {
        let expect = XCTestExpectation()
        self.run(onCycle: {}, onComplete: { expect.fulfill() })
        expect.wait(sender)
    }
}
