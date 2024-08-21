struct JoypadButton: OptionSet {
    var rawValue: UInt8

    static let RIGHT = JoypadButton(rawValue: 0b10000000)
    static let LEFT = JoypadButton(rawValue: 0b01000000)
    static let DOWN = JoypadButton(rawValue: 0b00100000)
    static let UP = JoypadButton(rawValue: 0b00010000)
    static let START = JoypadButton(rawValue: 0b00001000)
    static let SELECT = JoypadButton(rawValue: 0b00000100)
    static let BUTTON_B = JoypadButton(rawValue: 0b00000010)
    static let BUTTON_A = JoypadButton(rawValue: 0b00000001)
}

class Joypad {
    var strobe = false
    var buttonIndex: UInt8 = 0
    var buttonStatus = JoypadButton()

    func write(_ data: UInt8) {
        strobe = data & 1 == 1
        if strobe {
            buttonIndex = 0
        }
    }

    func read() -> UInt8 {
        if buttonIndex > 7 {
            return 1
        }
        let response = (buttonStatus.rawValue & (1 << buttonIndex)) >> buttonIndex
        if !strobe {
            buttonIndex += 1
        }
        return response
    }

    func setButton(_ button: JoypadButton, pressed: Bool) {
        if pressed {
            buttonStatus.insert(button)
        } else {
            buttonStatus.remove(button)
        }
    }
}
