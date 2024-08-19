// 7  bit  0
// ---- ----
// VSO. ....
// |||| ||||
// |||+-++++- Least significant bits previously written into a PPU register
// |||        (due to register not being updated for this address)
// ||+------- Sprite overflow. The intent was for this flag to be set
// ||         whenever more than eight sprites appear on a scanline, but a
// ||         hardware bug causes the actual behavior to be more complicated
// ||         and generate false positives as well as false negatives; see
// ||         PPU sprite evaluation. This flag is set during sprite
// ||         evaluation and cleared at dot 1 (the second dot) of the
// ||         pre-render line.
// |+-------- Sprite 0 Hit.  Set when a nonzero pixel of sprite 0 overlaps
// |          a nonzero background pixel; cleared at dot 1 of the pre-render
// |          line.  Used for raster timing.
// +--------- Vertical blank has started (0: not in vblank; 1: in vblank).
//            Set at dot 1 of line 241 (the line *after* the post-render
//            line); cleared after reading $2002 and at dot 1 of the
//            pre-render line.

private struct StatusRegisterInternal: OptionSet {
    var rawValue: UInt8

    static let NOTUSED = StatusRegisterInternal(rawValue: 0b00000001)
    static let NOTUSED2 = StatusRegisterInternal(rawValue: 0b00000010)
    static let NOTUSED3 = StatusRegisterInternal(rawValue: 0b00000100)
    static let NOTUSED4 = StatusRegisterInternal(rawValue: 0b00001000)
    static let NOTUSED5 = StatusRegisterInternal(rawValue: 0b00010000)
    static let SPRITE_OVERFLOW = StatusRegisterInternal(rawValue: 0b00100000)
    static let SPRITE_ZERO_HIT = StatusRegisterInternal(rawValue: 0b01000000)
    static let VBLANK_STARTED = StatusRegisterInternal(rawValue: 0b10000000)
}

class StatusRegister {
    fileprivate var val = StatusRegisterInternal()

    func setVblankStatus(_ status: Bool) {
        if status {
            val.insert(.VBLANK_STARTED)
        } else {
            val.remove(.VBLANK_STARTED)
        }
    }

    func setSpriteZeroHit(_ status: Bool) {
        if status {
            val.insert(.SPRITE_ZERO_HIT)
        } else {
            val.remove(.SPRITE_ZERO_HIT)
        }
    }

    func setSpriteOverflow(_ status: Bool) {
        if status {
            val.insert(.SPRITE_OVERFLOW)
        } else {
            val.remove(.SPRITE_OVERFLOW)
        }
    }

    func resetVblankStatus() {
        val.remove(.VBLANK_STARTED)
    }

    func isInVblank() -> Bool {
        val.contains(.VBLANK_STARTED)
    }

    func snapshot() -> UInt8 {
        val.rawValue
    }
}
