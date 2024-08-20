extension CPU {
    func lda(_ mode: AddressingMode) {
        let (addr, pageCross) = getOpperandAddress(mode)
        let value = memRead(addr)

        setRegisterA(value)
        if pageCross {
            bus.tick(1)
        }
    }

    func ldy(_ mode: AddressingMode) {
        let (addr, pageCross) = getOpperandAddress(mode)
        let data = memRead(addr)
        register_y = data
        updateZeroAndNegativeFlags(register_y)
        if pageCross {
            bus.tick(1)
        }
    }

    func ldx(_ mode: AddressingMode) {
        let (addr, pageCross) = getOpperandAddress(mode)
        let data = memRead(addr)
        register_x = data
        updateZeroAndNegativeFlags(register_x)
        if pageCross {
            bus.tick(1)
        }
    }

    func sta(_ mode: AddressingMode) {
        let (addr, _) = getOpperandAddress(mode)
        memWrite(addr, data: register_a)
    }

    func and(_ mode: AddressingMode) {
        let (addr, pageCross) = getOpperandAddress(mode)
        let data = memRead(addr)
        self.setRegisterA(data & register_a)
        if pageCross {
            bus.tick(1)
        }
    }

    func eor(_ mode: AddressingMode) {
        let (addr, pageCross) = getOpperandAddress(mode)
        let data = memRead(addr)
        setRegisterA(data ^ register_a)
        if pageCross {
            bus.tick(1)
        }
    }

    func ora(_ mode: AddressingMode) {
        let (addr, pageCross) = getOpperandAddress(mode)
        let data = memRead(addr)
        setRegisterA(data | register_a)
        if pageCross {
            bus.tick(1)
        }
    }

    func tax() {
        register_x = register_a
        updateZeroAndNegativeFlags(register_x)
    }

    func inx() {
        register_x = register_x &+ 1
        updateZeroAndNegativeFlags(register_x)
    }

    func iny() {
        register_y = register_y &+ 1
        updateZeroAndNegativeFlags(register_y)
    }

    func sbc(_ mode: AddressingMode) {
        let (addr, pageCross) = getOpperandAddress(mode)
        let data = memRead(addr)
        let res = Int8(bitPattern: data) &* -1
        addToRegisterA(UInt8(bitPattern: res &- 1))
        if pageCross {
            bus.tick(1)
        }
    }

    func adc(_ mode: AddressingMode) {
        let (addr, pageCross) = getOpperandAddress(mode)
        let data = memRead(addr)
        addToRegisterA(data)
        if pageCross {
            bus.tick(1)
        }
    }

    func aslAccumulator() {
        var data = register_a
        if data >> 7 == 1 {
            setCarryFlag()
        } else {
            clearCarryFlag()
        }
        data = data << 1
        setRegisterA(data)
    }

    func asl(_ mode: AddressingMode) -> UInt8 {
        let (addr, _) = getOpperandAddress(mode)
        var data = memRead(addr)
        if data >> 7 == 1 {
            setCarryFlag()
        } else {
            clearCarryFlag()
        }
        data = data << 1
        memWrite(addr, data: data)
        updateZeroAndNegativeFlags(data)
        return data
    }

    func lsrAccumulator() {
        var data = register_a
        if data & 1 == 1 {
            setCarryFlag()
        } else {
            clearCarryFlag()
        }
        data = data >> 1
        setRegisterA(data)
    }

    func lsr(_ mode: AddressingMode) -> UInt8 {
        let (addr, _) = getOpperandAddress(mode)
        var data = memRead(addr)
        if data & 1 == 1 {
            setCarryFlag()
        } else {
            clearCarryFlag()
        }
        data = data >> 1
        memWrite(addr, data: data)
        updateZeroAndNegativeFlags(data)
        return data
    }

    func rolAccumulator() {
        var data = register_a
        let oldCarry = status.contains(.carry)

        if data >> 7 == 1 {
            setCarryFlag()
        } else {
            clearCarryFlag()
        }
        data = data << 1
        if oldCarry {
            data = data | 1
        }
        setRegisterA(data)
    }

    func rol(_ mode: AddressingMode) -> UInt8 {
        let (addr, _) = getOpperandAddress(mode)
        var data = memRead(addr)
        let oldCarry = status.contains(.carry)

        if data >> 7 == 1 {
            setCarryFlag()
        } else {
            clearCarryFlag()
        }

        data = data << 1
        if oldCarry {
            data = data | 1
        }
        memWrite(addr, data: data)
        updateZeroAndNegativeFlags(data)
        return data
    }

    func rorAccumulator() {
        var data = register_a
        let oldCarry = status.contains(.carry)

        if data & 1 == 1 {
            setCarryFlag()
        } else {
            clearCarryFlag()
        }
        data = data >> 1
        if oldCarry {
            data = data | 0b10000000
        }
        setRegisterA(data)
    }

    func ror(_ mode: AddressingMode) -> UInt8 {
        let (addr, _) = getOpperandAddress(mode)
        var data = memRead(addr)
        let oldCarry = status.contains(.carry)
        if data & 1 == 1 {
            setCarryFlag()
        } else {
            clearCarryFlag()
        }
        data = data >> 1
        if oldCarry {
            data = data | 0b10000000
        }
        memWrite(addr, data: data)
        updateZeroAndNegativeFlags(data)
        return data
    }

    func inc(_ mode: AddressingMode) -> UInt8 {
        let (addr, _) = getOpperandAddress(mode)
        var data = memRead(addr)
        data = data &+ 1
        memWrite(addr, data: data)
        updateZeroAndNegativeFlags(data)
        return data
    }

    func dey() {
        register_y = register_y &- 1
        updateZeroAndNegativeFlags(register_y)
    }

    func dex() {
        register_x = register_x &- 1
        updateZeroAndNegativeFlags(register_x)
    }

    func dec(_ mode: AddressingMode) -> UInt8 {
        let (addr, _) = getOpperandAddress(mode)
        var data = memRead(addr)
        data = data &- 1
        memWrite(addr, data: data)
        updateZeroAndNegativeFlags(data)
        return data
    }

    func pla() {
        let data = stackPop()
        setRegisterA(data)
    }

    func plp() {
        status.rawValue = stackPop()
        status.remove(.break1)
        status.insert(.break2)
    }

    func php() {
        var flags = status
        flags.insert(.break1)
        flags.insert(.break2)
        stackPush(flags.rawValue)
    }

    func bit(_ mode: AddressingMode) {
        let (addr, _) = getOpperandAddress(mode)
        let data = memRead(addr)
        let and = register_a & data
        if and == 0 {
            status.insert(.zero)
        } else {
            status.remove(.zero)
        }

        if data & 0b10000000 > 0 {
            status.insert(.negative)
        } else {
            status.remove(.negative)
        }

        if data & 0b01000000 > 0 {
            status.insert(.overflow)
        } else {
            status.remove(.overflow)
        }
    }
}
