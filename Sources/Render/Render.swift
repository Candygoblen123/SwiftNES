class Render {
    static func render(_ ppu: NesPPU, frame: Frame) {
        let scroll = (x: Int(ppu.scroll.x), y: Int(ppu.scroll.y))

        let (mainNametable, secondNametable) = switch (ppu.mirroring, ppu.ctrl.nametableAddr()) {
        case (.vertical, 0x2000), (.vertical, 0x2800), (.horizontal, 0x2000), (.horizontal, 0x2400):
            (ppu.vram[0..<0x400], ppu.vram[0x400..<0x800])
        case (.vertical, 0x2400), (.vertical, 0x2c00), (.horizontal, 0x2800), (.horizontal, 0x2c00):
            (ppu.vram[0x400..<0x800], ppu.vram[0..<0x400])
        default:
            fatalError("cringe looking nametable arrangment: \(ppu.mirroring)")
        }

        renderNameTable(
            ppu,
            frame: frame,
            nameTable: Array(mainNametable),
            viewPort: Rect(x1: scroll.x, y1: scroll.y, x2: 256, y2: 240),
            shift: (-scroll.x, -scroll.y)
        )

        if scroll.x > 0 {
            renderNameTable(
                ppu,
                frame: frame,
                nameTable: Array(secondNametable),
                viewPort: Rect(x1: 0, y1: 0, x2: scroll.x, y2: 240),
                shift: (256 - scroll.x, 0)
            )
        } else if scroll.y > 0 {
            renderNameTable(
                ppu,
                frame: frame,
                nameTable: Array(secondNametable),
                viewPort: Rect(x1: 0, y1: 0, x2: 256, y2: scroll.y),
                shift: (0, 240 - scroll.y)
            )
        }

        // MARK: Draw Sprites
        for i in stride(from: 0, to: ppu.oamData.count, by: 4) {
            let tileIndex = UInt16(ppu.oamData[i + 1])
            let tileX = Int(ppu.oamData[i + 3])
            let tileY = Int(ppu.oamData[i])

            let flipVert = ppu.oamData[i + 2] >> 7 & 1 == 1
            let flipHori = ppu.oamData[i + 2] >> 6 & 1 == 1

            let paletteIndex = ppu.oamData[i + 2] & 0b11
            let spritePallete = getSpritePalette(ppu, paletteIndex: paletteIndex)

            let bank = ppu.ctrl.spritePatternAddr()
            let tile = ppu.chrRom[(bank + Int(tileIndex) * 16)...(bank + Int(tileIndex) * 16 + 15)]

            for y in 0...7 {
                var upper = tile[tile.startIndex + y]
                var lower = tile[tile.startIndex + y + 8]

                for x in [7,6,5,4,3,2,1,0] {
                    let value = (1 & lower) << 1 | (1 & upper)
                    upper = upper >> 1
                    lower = lower >> 1
                    if (value == 0) {
                        continue // skip coloring this pixel, it's transparent
                    }
                    let rgb = switch value {
                    case 1:
                        NESColor.SYSTEM_PALLETE[Int(spritePallete[1])]
                    case 2:
                        NESColor.SYSTEM_PALLETE[Int(spritePallete[2])]
                    case 3:
                        NESColor.SYSTEM_PALLETE[Int(spritePallete[3])]
                    default:
                        fatalError("Invalid Pallete Color type")
                    }
                    switch (flipHori, flipVert) {
                    case (false, false):
                        frame.setPixel((tileX + x, tileY + y), rgb)
                    case (true, false):
                        frame.setPixel((tileX + 7 - x, tileY + y), rgb)
                    case (false, true):
                        frame.setPixel((tileX + x, tileY + 7 - y), rgb)
                    case (true, true):
                        frame.setPixel((tileX + 7 - x, tileY + 7 - y), rgb)
                    }
                }
            }
        }
    }

    static func renderNameTable(_ ppu: NesPPU, frame: Frame, nameTable: [UInt8], viewPort: Rect, shift: (x: Int, y: Int)) {
       let bank = ppu.ctrl.backgroundPatternAddr()
       let attributeTable = nameTable[0x3c0..<0x400]

       for i in 0..<0x3c0 {
            let tileAddr = UInt16(nameTable[i])
            let tileLoc = (col: i % 32, row: i / 32)
            let tile = ppu.chrRom[(bank + Int(tileAddr) * 16)...(bank + Int(tileAddr) * 16 + 15)]
            let bgPalette = getBgPalette(ppu, tileLoc: tileLoc, attributeTable: Array(attributeTable))

            // MARK: Draw Background
            for y in 0...7 {
                var upper = tile[tile.startIndex + y]
                var lower = tile[tile.startIndex + y + 8]

                for x in [7,6,5,4,3,2,1,0] {
                    let value = (1 & lower) << 1 | (1 & upper)
                    upper = upper >> 1
                    lower = lower >> 1
                    let rgb = switch value {
                        case 0:
                            NESColor.SYSTEM_PALLETE[Int(ppu.paletteTable[0])]
                        case 1:
                            NESColor.SYSTEM_PALLETE[Int(bgPalette[1])]
                        case 2:
                            NESColor.SYSTEM_PALLETE[Int(bgPalette[2])]
                        case 3:
                            NESColor.SYSTEM_PALLETE[Int(bgPalette[3])]
                        default:
                            fatalError("Invalid Pallete Color type")
                    }

                    let pixelLoc = (x: tileLoc.col * 8 + x, y: tileLoc.row * 8 + y)
                    if pixelLoc.x >= viewPort.x1 && pixelLoc.x < viewPort.x2 && pixelLoc.y >= viewPort.y1 && pixelLoc.y < viewPort.y2 {
                        frame.setPixel((shift.x + pixelLoc.x, shift.y + pixelLoc.y), rgb)
                    }
                }
            }
       }
    }

    static func getBgPalette(_ ppu: NesPPU, tileLoc: (col: Int, row: Int), attributeTable: [UInt8]) -> [UInt8] {
        let attrTableIndex = tileLoc.row / 4 * 8 + tileLoc.col / 4
        let attrByte = attributeTable[attrTableIndex]

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
        return [
            ppu.paletteTable[0],
            ppu.paletteTable[palleteStartIndex],
            ppu.paletteTable[palleteStartIndex + 1],
            ppu.paletteTable[palleteStartIndex + 2],
        ]
    }

    static func getSpritePalette(_ ppu: NesPPU, paletteIndex: UInt8) -> [UInt8] {
        let start = 0x11 + Int(paletteIndex * 4)
        return [
          0,
          ppu.paletteTable[start],
          ppu.paletteTable[start + 1],
          ppu.paletteTable[start + 2]
        ]
    }
}

struct Rect {
    let x1: Int
    let y1: Int
    let x2: Int
    let y2: Int
}
