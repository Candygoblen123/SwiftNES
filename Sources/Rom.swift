struct Rom {
    fileprivate let PRG_ROM_PAGE_SIZE = 16384
    fileprivate let CHR_ROM_PAGE_SIZE = 8192

    var program: [UInt8]
    var character: [UInt8]
    var mapper: UInt8
    var screenMirror: Mirroring

    init(_ raw: [UInt8]) throws {
        guard raw[0..<4] == [0x4E, 0x45, 0x53, 0x1A] else { throw HeaderParseError.notINES("File is not in iNES file format.") }
        mapper = (raw[7] & 0b1111_0000) | (raw[6] >> 4)

        let inesVer = (raw[7] >> 2) & 0b11
        guard inesVer == 0 else { throw HeaderParseError.iNes2("iNES2.0 format not supported.") }

        let fourScreen = raw[6] & 0b1000 != 0
        let vertMirroring = raw[6] & 0b1 != 0
        screenMirror = switch (fourScreen, vertMirroring) {
        case (true, _):
            Mirroring.fourScreen
        case (false, true):
            Mirroring.vertical
        case (false, false):
            Mirroring.horizontal
        }

        let programSize = Int(raw[4]) * PRG_ROM_PAGE_SIZE
        let characterSize = Int(raw[5]) * CHR_ROM_PAGE_SIZE

        let skipTrainer = raw[6] & 0b100 != 0

        let programStart = 16 + (skipTrainer ? 512 : 0)
        let characterStart = programStart + programSize

        program = Array(raw[programStart..<(programStart + programSize)])
        character = Array(raw[characterStart..<(characterStart + characterSize)])
    }
}

enum Mirroring {
    case vertical
    case horizontal
    case fourScreen
}

enum HeaderParseError: Error {
    case notINES(String)
    case iNes2(String)
}
