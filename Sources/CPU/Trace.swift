func dumpCpuState(_ cpu: CPU) -> String {
    guard let opcode = OPCODES_MAP[cpu.memRead(cpu.programCounter)] else { fatalError("Not an opcode: \(cpu.memRead(cpu.programCounter))") }
    var hexOpcode = [String(format: "%02X", cpu.memRead(cpu.programCounter))]

    let (memAddr, storedVal) = switch opcode.mode {
    case .Immediate, .NoneAddressing:
        (UInt16(0), UInt8(0))
    default:
        {
            let addr = cpu.getAbsoluteAddress(opcode.mode, addr: cpu.programCounter + 1)

            return (addr, cpu.memRead(addr))
        }()
    }

    let operand = switch opcode.len {
    case 1:
        {
            return switch opcode.code {
            case 0x0a, 0x4a, 0x2a, 0x6a:
                "A "
            default:
                ""
            }
        }()
    case 2:
        {
            let address = cpu.memRead(cpu.programCounter + 1)
            hexOpcode.append(String(format: "%02X", address))

            return switch opcode.mode {
            case .Immediate:
                String(format: "#$%02X", address)
            case .ZeroPage:
                String(format: "$%02X = %02X", memAddr, storedVal)
            case .ZeroPage_X:
                String(format: "$%02X,X @ %02X = %02X", address, memAddr, storedVal)
            case .ZeroPage_Y:
                String(format: "$%02X,Y @ %02X = %02X", address, memAddr, storedVal)
            case .Indirect_X:
                String(format: "($%02X,X) @ %02X = %04X = %02X", address, address &+ cpu.register_x, memAddr, storedVal)
            case .Indirect_Y:
                String(format: "($%02X),Y = %04X @ %04X = %02X", address, memAddr &- UInt16(cpu.register_y), memAddr, storedVal)
            case .NoneAddressing:
                String(format: "$%04X", Int(cpu.programCounter) + 2 &+ Int(Int8(bitPattern: address)))
            default:
                fatalError("Unexpected addressing mode \(opcode.mode) has ops-length of 2. code: \(opcode.mnemonic)")
            }
        }()
    case 3:
        {
            let addressLo = cpu.memRead(cpu.programCounter + 1)
            let addressHi = cpu.memRead(cpu.programCounter + 2)
            hexOpcode.append(String(format: "%02X", addressLo))
            hexOpcode.append(String(format: "%02X", addressHi))

            let address = cpu.memReadU16(cpu.programCounter + 1)

            return switch opcode.mode {
            case .NoneAddressing:
                {
                    // jmp indirect
                    if (opcode.code == 0x6c) {
                        let jmpAddr = if address & 0x00FF == 0x00FF {
                            {
                                let lo = cpu.memRead(address)
                                let hi = cpu.memRead(address & 0xFF00)
                                return UInt16(hi) << 8 | UInt16(lo)
                            }()
                        } else {
                            cpu.memReadU16(address)
                        }

                        return String(format: "($%04X) = %04X", address, jmpAddr)
                     } else {
                        return String(format: "$%04X", address)
                    }
                }()
            case .Absolute:
                String(format: "$%04X = %02X", memAddr, storedVal)
            case .Absolute_X:
                String(format: "$%04X,X @ %04X = %02X", address, memAddr, storedVal)
            case .Absolute_Y:
                String(format: "$%04X,Y @ %04X = %02X", address, memAddr, storedVal)
            default:
                fatalError("Unexpected addressing mode \(opcode.mode) has ops-length of 3. code: \(opcode.mnemonic)")
            }
        }()
    default:
        ""
    }

    let hexString = hexOpcode.joined(separator: " ").padding(toLength: 8, withPad: " ", startingAt: 0)
    let asm = "\(String(format: "%04X", cpu.programCounter))  \(hexString) \(opcode.mnemonic.leftPadding(toLength: 4, withPad: " ")) \(operand)".padding(toLength: 47, withPad: " ", startingAt: 0)
    return String(format: "\(asm) A:%02X X:%02X Y:%02X P:%02X SP:%02X", cpu.register_a, cpu.register_x, cpu.register_y, cpu.status.rawValue, cpu.stackPointer)
}

extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
}
