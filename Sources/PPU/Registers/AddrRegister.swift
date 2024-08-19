class AddrRegister {
    private var value: (UInt8, UInt8) = (0, 0) // hi byte first, lo byte second
    private var hiPointer = true

    func set(_ data: UInt16) {
        value.0 = UInt8(data >> 8)
        value.1 = UInt8(data & 0xff)
    }

    func update(_ data: UInt8) {
        if hiPointer {
            value.0 = data
        } else {
            value.1 = data
        }

        if get() > 0x3fff {
            set(get() & 0b11111111111111)
        }
        hiPointer.toggle()
    }

    func increment(_ inc: UInt8) {
        let lo = value.1
        value.1 = value.1 &+ inc

        if lo > value.1 {
            value.0 = value.0 &+ 1
        }
        if get() > 0x3fff {
            set(get() & 0b11111111111111)
        }
    }

    func resetLatch() {
        hiPointer = true
    }

    func get() -> UInt16 {
        UInt16(value.0) << 8 | UInt16(value.1)
    }
}
