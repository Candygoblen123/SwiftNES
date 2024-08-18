import XCTest
@testable import SwiftNES

/*
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

    func test_ror() {
        let cpu = CPU()
        cpu.load([0x66, 0x10, 0x00])
        cpu.reset()
        cpu.memWrite(0x10, data: 0b1001_1001)
        cpu.runExpect(self)
        XCTAssertEqual(cpu.memRead(0x10), 0b0100_1100)
    }

    func test_inc() {
        let cpu = CPU()
        cpu.memWrite(0x10, data: 0x10)
        cpu.load([0xe6, 0x10, 0x00])
        cpu.reset()
        cpu.runExpect(self)
        XCTAssertEqual(cpu.memRead(0x10), 0x11)
    }

    func test_inc_overflow() {
        let cpu = CPU()
        cpu.load([0xe6, 0x10, 0xe6, 0x10, 0x00])
        cpu.memWrite(0x10, data: 0xff)
        cpu.reset()
        cpu.runExpect(self)
        XCTAssertEqual(cpu.memRead(0x10), 0x01)
    }

    func test_dey() {
        let cpu = CPU()
        cpu.load([0x88, 0x00])
        cpu.reset()
        cpu.register_y = 0x10
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_y, 0x0f)
    }

    func test_dey_underflow() {
        let cpu = CPU()
        cpu.load([0x88, 0x88, 0x00])
        cpu.reset()
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_y, 0xfe)

    }

    func test_dex() {
        let cpu = CPU()
        cpu.load([0xca, 0x00])
        cpu.reset()
        cpu.register_x = 0x10
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_x, 0x0f)
    }

    func test_dex_underflow() {
        let cpu = CPU()
        cpu.load([0xca, 0xca, 0x00])
        cpu.reset()
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_x, 0xfe)
    }

    func test_dec() {
        let cpu = CPU()
        cpu.load([0xc6, 0x10, 0x00])
        cpu.memWrite(0x10, data: 0x10)
        cpu.reset()
        cpu.runExpect(self)
        XCTAssertEqual(cpu.memRead(0x10), 0x0f)
    }

    func test_dec_underflow() {
        let cpu = CPU()
        cpu.load([0xc6, 0x10, 0xc6, 0x10, 0x00])
        cpu.memWrite(0x10, data: 0x00)
        cpu.reset()
        cpu.runExpect(self)
        XCTAssertEqual(cpu.memRead(0x10), 0xfe)
    }

    func test_pla() {
        let cpu = CPU()
        cpu.load([0x68, 0x00])
        cpu.reset()
        cpu.stackPush(0x10)
        cpu.runExpect(self)
        XCTAssertEqual(cpu.register_a, 0x10)
    }

    func test_plp() {
        let cpu = CPU()
        cpu.load([0x28, 0x00])
        cpu.reset()
        cpu.stackPush(CPUFlags([.interruptDisable, .carry, .decimalMode, .break1, .break2]).rawValue)
        cpu.runExpect(self)
        XCTAssertEqual(cpu.status, CPUFlags([.interruptDisable, .carry, .decimalMode]))
    }

    func test_php() {
        let cpu = CPU()
        cpu.load([0x08, 0x00])
        cpu.reset()
        cpu.status = CPUFlags(arrayLiteral: [.interruptDisable, .carry, .decimalMode])
        cpu.runExpect(self)
        XCTAssertEqual(cpu.stackPop(), CPUFlags([.interruptDisable, .carry, .decimalMode, .break1, .break2]).rawValue)
    }

    func test_bit_zero() {
        let cpu = CPU()
        cpu.load([0x24, 0x10, 0x00])
        cpu.reset()
        cpu.register_a = 0b0001
        cpu.memWrite(0x10, data: 0b1000)
        cpu.runExpect(self)
        XCTAssert(cpu.status.contains(.zero))
    }

    func test_bit_nonzero() {
        let cpu = CPU()
        cpu.load([0x24, 0x10, 0x00])
        cpu.reset()
        cpu.register_a = 0b1000
        cpu.memWrite(0x10, data: 0b1001)
        cpu.runExpect(self)
        XCTAssert(!cpu.status.contains(.zero))
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
 */
