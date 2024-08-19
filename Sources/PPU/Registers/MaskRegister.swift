private struct MaskRegisterInternal: OptionSet {
    var rawValue: UInt8

    static let GREYSCALE  = MaskRegisterInternal(rawValue: 0b00000001)
    static let LEFTMOST_8PXL_BACKGROUND = MaskRegisterInternal(rawValue: 0b00000010)
    static let LEFTMOST_8PXL_SPRITE = MaskRegisterInternal(rawValue: 0b00000100)
    static let SHOW_BACKGROUND = MaskRegisterInternal(rawValue: 0b00001000)
    static let SHOW_SPRITES = MaskRegisterInternal(rawValue: 0b00010000)
    static let EMPHASISE_RED = MaskRegisterInternal(rawValue: 0b00100000)
    static let EMPHASISE_GREEN = MaskRegisterInternal(rawValue: 0b01000000)
    static let EMPHASISE_BLUE = MaskRegisterInternal(rawValue: 0b10000000)
}

class MaskRegister {
    private var val = MaskRegisterInternal()

    func isGrayscale() -> Bool {
        val.contains(.GREYSCALE)
    }

    func leftmost8pxlBackground() -> Bool {
        val.contains(.LEFTMOST_8PXL_BACKGROUND)
    }

    func leftmost8pxlSprite() -> Bool {
        val.contains(.LEFTMOST_8PXL_SPRITE)
    }

    func showBackground() -> Bool {
        val.contains(.SHOW_BACKGROUND)
    }

    func showSprites() -> Bool {
        val.contains(.SHOW_SPRITES)
    }

    func emphasise() -> [Color] {
        var res: [Color] = []
        if val.contains(.EMPHASISE_RED) {
            res.append(.Red)
        }
        if val.contains(.EMPHASISE_BLUE) {
            res.append(.Blue)
        }
        if val.contains(.EMPHASISE_GREEN) {
            res.append(.Green)
        }
        return res
    }

    func update(_ data: UInt8) {
        val.rawValue = data
    }
}

public enum Color {
    case Red, Green, Blue
}
