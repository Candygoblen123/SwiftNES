import XCTest
@testable import SwiftNES

class CPUTests: XCTestCase {
    func test_0xa9_lda_immediate_load_data() {
        let cpu = CPU()
        cpu.loadAndRun([0xa9, 0x05, 0x00])

        XCTAssertEqual(cpu.register_a, 0x05)
        XCTAssert(cpu.status & 0b0000_0010 == 0b00)
        XCTAssert(cpu.status & 0b1000_0000 == 0)
    }

    func test_lda_from_memory() {
        let cpu = CPU()
        cpu.memWrite(addr: 0x10, data: 0x55)

        cpu.loadAndRun([0xa5, 0x10, 0x00])

        XCTAssertEqual(cpu.register_a, 0x55)
    }

    func test_0xa9_lda_zero_flag() {
        let cpu = CPU()
        cpu.loadAndRun([0xa9, 0x00, 0x00])
        XCTAssert(cpu.status & 0b0000_0010 == 0b10)
    }

    func test_0xa9_lda_neg_flag() {
        let cpu = CPU()
        cpu.loadAndRun([0xa9, 0xFF, 0x00])
        XCTAssert(cpu.status & 0b1000_0000 == 0b1000_0000)
    }

    func test_0xaa_tax_move_a_to_x() {
        let cpu = CPU()

        cpu.load([0xaa, 0x00])
        cpu.reset()
        cpu.register_a = 10
        cpu.run()
        XCTAssertEqual(cpu.register_x, 10)
    }

    func test_0xe8_inx_incriment_x() {
        let cpu = CPU()

        cpu.load([0xe8, 0x00])
        cpu.reset()
        cpu.register_x = 10
        cpu.run()

        XCTAssertEqual(cpu.register_x, 11)
    }

    func test_5_ops_working_together() {
        let cpu = CPU()
        cpu.loadAndRun([0xa9, 0xc0, 0xaa, 0xe8, 0x00])

        XCTAssertEqual(cpu.register_x, 0xc1)
   }

    func test_inx_overflow() {
        let cpu = CPU()

        cpu.load([0xe8, 0xe8, 0x00])
        cpu.reset()
        cpu.register_x = 0xff
        cpu.run()
        XCTAssertEqual(cpu.register_x, 1)
    }
}
