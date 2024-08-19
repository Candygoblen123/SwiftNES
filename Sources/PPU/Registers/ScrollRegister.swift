class ScrollRegister {
    public var x: UInt8 = 0
    public var y: UInt8 = 0
    public var latch = false

    func write(_ data: UInt8) {
        if !latch {
            x = data
        } else {
            y = data
        }
        latch.toggle()
    }

    func resetLatch() {
        latch = false
    }
}
