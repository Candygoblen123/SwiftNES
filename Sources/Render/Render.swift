class Render {
    static func render(_ ppu: NesPPU, frame: Frame) {
        let bank = ppu.ctrl.backgroundPatternAddr()

        for i in 0..<0x03c0 { // FIXME: For now, just use first nametable
            let tileAddr = UInt16(ppu.vram[i])
            //print(ppu.vram)
            let tileLoc = (col: i % 32, row: i / 32)
            let tile = ppu.chrRom[(bank + Int(tileAddr) * 16)...(bank + Int(tileAddr) * 16 + 15)]
            let palette = getBgPallete(ppu, tileLoc: tileLoc)

            for y in 0...7 {
                var upper = tile[tile.startIndex + y]
                var lower = tile[tile.startIndex + y + 8]

                for x in (0...7).reversed() {
                    let value = (1 & lower) << 1 | (1 & upper)
                    upper = upper >> 1
                    lower = lower >> 1
                    let rgb = switch value {
                        case 0:
                            NESColor.SYSTEM_PALLETE[Int(ppu.paletteTable[0])]
                        case 1:
                            NESColor.SYSTEM_PALLETE[Int(palette[1])]
                        case 2:
                            NESColor.SYSTEM_PALLETE[Int(palette[2])]
                        case 3:
                            NESColor.SYSTEM_PALLETE[Int(palette[3])]
                        default:
                            fatalError("Invalid Pallete Color type")
                    }
                    frame.setPixel((tileLoc.col * 8 + x, tileLoc.row * 8 + y), rgb)
                }
            }
        }
    }

    static func getBgPallete(_ ppu: NesPPU, tileLoc: (col: Int, row: Int)) -> [UInt8] {
        let attrTableIndex = tileLoc.row / 4 * 8 + tileLoc.col / 4
        let attrByte = ppu.vram[0x3c0 + attrTableIndex] // FIXME: still using hardcoded first nametable

        let palleteIndex = switch (tileLoc.col % 4 / 2, tileLoc.row % 4 / 2) {
        case (0,0):
            attrByte & 0b11
        case (1,0):
            (attrByte >> 2) & 0b11
        case (0,1):
            (attrByte >> 4) & 0b11
        case (1,1):
            (attrByte >> 6) & 0b11
        default:
            fatalError("Invalid titleLoc. This should never happen!")
        }

        let palleteStartIndex = 1 + Int(palleteIndex) * 4
        return [ppu.paletteTable[0], ppu.paletteTable[palleteStartIndex], ppu.paletteTable[palleteStartIndex + 1], ppu.paletteTable[palleteStartIndex + 2]]
    }
}
