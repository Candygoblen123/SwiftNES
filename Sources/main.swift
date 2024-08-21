// The Swift Programming Language
// https://docs.swift.org/swift-book

import SDL
import Foundation

guard SDL_Init(SDL_INIT_VIDEO) == 0 else {
    fatalError("SDL could not initialize! SDL_Error: \(String(cString: SDL_GetError()))")
}

let window = SDL_CreateWindow(
    "SwiftNES",
    Int32(SDL_WINDOWPOS_CENTERED_MASK), Int32(SDL_WINDOWPOS_CENTERED_MASK),
    Int32(256.0 * 3.0), Int32(240.0 * 3.0),
    SDL_WINDOW_SHOWN.rawValue)

let canvas = SDL_CreateRenderer(window, -1, SDL_RENDERER_PRESENTVSYNC.rawValue)

SDL_RenderSetScale(canvas, 3.0, 3.0)

var texture = SDL_CreateTexture(canvas, SDL_PIXELFORMAT_RGB24.rawValue, Int32(SDL_TEXTUREACCESS_TARGET.rawValue), 256, 240)

var event = SDL_Event()

guard let bytes = NSData(contentsOfFile: "pacman.nes") else { fatalError("Rom not found") }
var gameCode = [UInt8](repeating: 0, count: bytes.length)
bytes.getBytes(&gameCode, length: bytes.length)

let rom = try Rom(gameCode)
let joypad1 = Joypad()

let keyMap = [
  SDLK_DOWN : JoypadButton.DOWN,
  SDLK_UP : JoypadButton.UP,
  SDLK_LEFT : JoypadButton.LEFT,
  SDLK_RIGHT : JoypadButton.RIGHT,
  SDLK_SPACE : JoypadButton.SELECT,
  SDLK_RETURN : JoypadButton.START,
  SDLK_a : JoypadButton.BUTTON_A,
  SDLK_s : JoypadButton.BUTTON_B
]

var frame = Frame()
let bus = Bus(rom: rom, joypad1: joypad1) { ppu in
    Render.render(ppu, frame: frame)
    SDL_UpdateTexture(texture, nil, frame.data, 256 * 3)
    SDL_RenderCopy(canvas, texture, nil, nil)
    SDL_RenderPresent(canvas)

    while SDL_PollEvent(&event) > 0 {
        if event.type == SDL_QUIT.rawValue {
             SDL_DestroyWindow(window)
             SDL_Quit()
             exit(0)
         }
        if event.type == SDL_KEYDOWN.rawValue {
            let keyCode = SDL_KeyCode(UInt32(event.key.keysym.sym))
            switch keyCode {
            case SDLK_ESCAPE:
                SDL_DestroyWindow(window)
                SDL_Quit()
                exit(0)
            default:
                guard let key = keyMap[keyCode] else { continue }
                joypad1.setButton(key, pressed: true)
            }
        }
        if event.type == SDL_KEYUP.rawValue {
            guard let key = keyMap[SDL_KeyCode(UInt32(event.key.keysym.sym))] else { continue }
            joypad1.setButton(key, pressed: false)
        }
    }
}

let cpu = CPU(bus: bus)
cpu.reset()
cpu.run()
