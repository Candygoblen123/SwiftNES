struct TileViewer {
    static func showTile(chrRom: [UInt8], bank: Int, tileNum: Int) -> Frame {
        guard bank <= 1 else { fatalError("CHR Rom bank must be >1") }

        let frame = Frame()
        let bank = bank * 0x1000

        let tile = chrRom[(bank + tileNum * 16)...(bank + tileNum * 16 + 15)]

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
                frame.setPixel((x, y), rgb)
            }
        }

        return frame
    }

    static func showTileBank(chrRom: [UInt8], bank: Int) -> Frame {
        let frame = Frame()
        var tileY = 0
        var tileX = 0
        let bank = (bank * 0x1000)

        for tileNum in 0..<255 {
            if tileNum != 0 && tileNum % 20 == 0 {
                tileY += 10;
                tileX = 0;
            }

            let tile = chrRom[(bank + tileNum * 16)...(bank + tileNum * 16 + 15)]

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
                    frame.setPixel((tileX + x, tileY + y), rgb)
                }
            }

            tileX += 10
        }

        return frame
    }
}
