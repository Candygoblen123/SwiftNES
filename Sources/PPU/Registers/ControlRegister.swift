// 7  bit  0
// ---- ----
// VPHB SINN
// |||| ||||
// |||| ||++- Base nametable address
// |||| ||    (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
// |||| |+--- VRAM address increment per CPU read/write of PPUDATA
// |||| |     (0: add 1, going across; 1: add 32, going down)
// |||| +---- Sprite pattern table address for 8x8 sprites
// ||||       (0: $0000; 1: $1000; ignored in 8x16 mode)
// |||+------ Background pattern table address (0: $0000; 1: $1000)
// ||+------- Sprite size (0: 8x8 pixels; 1: 8x16 pixels)
// |+-------- PPU master/slave select
// |          (0: read backdrop from EXT pins; 1: output color on EXT pins)
// +--------- Generate an NMI at the start of the
//            vertical blanking interval (0: off; 1: on)

struct ControlRegister: OptionSet {
    var rawValue: UInt8

    static let NAMETABLE1 = ControlRegister(rawValue: 0b00000001)
    static let NAMETABLE2 = ControlRegister(rawValue: 0b00000010)
    static let VRAM_ADD_INCREMENT = ControlRegister(rawValue: 0b00000100)
    static let SPRITE_PATTERN_ADDR = ControlRegister(rawValue: 0b00001000)
    static let BACKROUND_PATTERN_ADDR = ControlRegister(rawValue: 0b00010000)
    static let SPRITE_SIZE = ControlRegister(rawValue: 0b00100000)
    static let MASTER_SLAVE_SELECT = ControlRegister(rawValue: 0b01000000)
    static let GENERATE_NMI = ControlRegister(rawValue: 0b10000000)

    func vramAddrIncrement() -> UInt8 {
        if self.contains(.VRAM_ADD_INCREMENT) {
            1
        } else {
            32
        }
    }

    func generateVblankNMI() -> Bool {
        self.contains(.GENERATE_NMI)
    }

    func backgroundPatternAddr() -> Int {
        if self.contains(.BACKROUND_PATTERN_ADDR) {
            0
        } else {
            0x1000
        }
    }
}
