// The Swift Programming Language
// https://docs.swift.org/swift-book

import SDL
import Foundation

guard SDL_Init(SDL_INIT_VIDEO) == 0 else {
    fatalError("SDL could not initialize! SDL_Error: \(String(cString: SDL_GetError()))")
}

let window = SDL_CreateWindow(
    "Snake Game",
    Int32(SDL_WINDOWPOS_CENTERED_MASK), Int32(SDL_WINDOWPOS_CENTERED_MASK),
    Int32(32.0 * 10.0), Int32(32.0 * 10.0),
    SDL_WINDOW_SHOWN.rawValue)

let canvas = SDL_CreateRenderer(window, -1, SDL_RENDERER_PRESENTVSYNC.rawValue)

SDL_RenderSetScale(canvas, 10.0, 10.0)

var texture = SDL_CreateTexture(canvas, SDL_PIXELFORMAT_RGB24.rawValue, Int32(SDL_TEXTUREACCESS_TARGET.rawValue), 32, 32)

var event = SDL_Event()
var quit = false

func handleUserInput(_ cpu: CPU, event: inout SDL_Event) {
    while SDL_PollEvent(&event) > 0 {
        if event.type == SDL_QUIT.rawValue {
            SDL_DestroyWindow(window)
            SDL_Quit()
            exit(0)
        }
        if event.type == SDL_KEYDOWN.rawValue {
            switch SDL_KeyCode(UInt32(event.key.keysym.sym)) {
            case SDLK_ESCAPE:
                SDL_DestroyWindow(window)
                SDL_Quit()
                exit(0)
            case SDLK_w:
                cpu.memWrite(0xff, data: 0x77)
            case SDLK_a:
                cpu.memWrite(0xff, data: 0x61)
            case SDLK_s:
                cpu.memWrite(0xff, data: 0x73)
            case SDLK_d:
                cpu.memWrite(0xff, data: 0x64)
            default:
                continue
            }
        }
    }
}

func color(_ byte: UInt8) -> SDL_Color {
    switch byte{
    case 0:
        return SDL_Color(r: 0, g: 0, b: 0, a: 255)
    case 1:
        return SDL_Color(r: 255, g: 255, b: 255, a: 255)
    case 2, 9:
        return SDL_Color(r: 128, g: 128, b: 128, a: 255)
    case 3, 10:
        return SDL_Color(r: 255, g: 0, b: 0, a: 255)
    case 4, 11:
        return SDL_Color(r: 0, g: 255, b: 0, a: 255)
    case 5, 12:
        return SDL_Color(r: 0, g: 0, b: 255, a: 255)
    case 6, 13:
        return SDL_Color(r: 255, g: 0, b: 255, a: 255)
    case 7, 14:
        return SDL_Color(r: 255, g: 255, b: 0, a: 255)
    default:
        return SDL_Color(r: 0, g: 255, b: 255, a: 255)

    }
}

func readScreenState(_ cpu: CPU, frame: inout [UInt8]) -> Bool {

    var frame_idx = 0
    var update = false
    for i in 0x0200..<0x600 {
        let color_idx = cpu.memRead(UInt16(i))
        let color = color(color_idx)
        let (b1, b2, b3) = (color.r, color.b, color.g)
        if frame[frame_idx] != b1 || frame[frame_idx + 1] != b2 || frame[frame_idx + 2] != b3 {
           frame[frame_idx] = b1;
           frame[frame_idx + 1] = b2;
           frame[frame_idx + 2] = b3;
           update = true;
       }
        frame_idx += 3
    }
    return update
}

guard let rom = NSData(contentsOfFile: "snake.nes") else { fatalError("Rom not found") }
var gameCode = [UInt8](repeating: 0, count: rom.length)
rom.getBytes(&gameCode, length: rom.length)


var cpu = CPU()
cpu.load(gameCode)
cpu.reset()

var screenState = [UInt8](repeating: 0, count: 32 * 3 * 32)
var rng = SystemRandomNumberGenerator()

cpu.run(onCycle: {
    handleUserInput(cpu, event: &event)
    cpu.memWrite(0xfe, data: UInt8.random(in: 1...16, using: &rng))

    if readScreenState(cpu, frame: &screenState) {
        SDL_UpdateTexture(texture, nil, screenState, 32 * 3)
        SDL_RenderCopy(canvas, texture, nil, nil)
        SDL_RenderPresent(canvas)
    }
}, onComplete: {
    SDL_DestroyWindow(window)
    SDL_Quit()
    exit(0)
})

// Infinite loop otherwise the program will exit prematurely
RunLoop.main.run()
