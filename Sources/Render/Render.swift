class Render {
    static func render(_ ppu: NesPPU, frame: Frame) {
        let bank = ppu.ctrl.backgroundPatternAddr()

        for i in 0..<0x03c0 { // For now, just use first nametable
            let tileAddr = UInt16(ppu.vram[i])
            //print(ppu.vram)
            let tileX = i % 32
            let tileY = i / 32
            let tile = ppu.chrRom[(bank + Int(tileAddr) * 16)...(bank + Int(tileAddr) * 16 + 15)]

            for y in 0...7 {
                var upper = tile[tile.startIndex + y]
                var lower = tile[tile.startIndex + y + 8]

                for x in (0...7).reversed() {
                    let value = (1 & upper) << 1 | (1 & lower)
                    upper = upper >> 1
                    lower = lower >> 1
                    let rgb = switch value {
                        case 0:
                            NESColor.SYSTEM_PALLETE[0x01]
                        case 1:
                            NESColor.SYSTEM_PALLETE[0x23]
                        case 2:
                            NESColor.SYSTEM_PALLETE[0x28]
                        case 3:
                            NESColor.SYSTEM_PALLETE[0x31]
                        default:
                            fatalError("Invalid Pallete Color type")
                    }
                    frame.setPixel((tileX * 8 + x, tileY * 8 + y), rgb)
                }
            }
        }
    }
}
