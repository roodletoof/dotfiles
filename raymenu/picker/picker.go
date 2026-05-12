package picker

import (

	rg "github.com/gen2brain/raylib-go/raygui"
	rl "github.com/gen2brain/raylib-go/raylib"
	"github.com/ktr0731/go-fuzzyfinder/matching"

	_ "embed"
)

const fontSize = 20
const textBoxHeight = fontSize + 6


//go:embed gomono-font/Go-Mono.ttf
var font_tff []byte

func style() {
	rg.SetFont(rl.LoadFontFromMemory(".ttf", font_tff, fontSize, nil))
	rg.SetStyle(rg.DEFAULT, rg.TEXT_SIZE, fontSize)
	rg.SetStyle(
		rg.DEFAULT,
		rg.BASE_COLOR_PRESSED,
		rg.NewColorPropertyValue(rl.Black),
	)
	rg.SetStyle(
		rg.DEFAULT,
		rg.BORDER_COLOR_PRESSED,
		rg.NewColorPropertyValue(rl.White),
	)
	rg.SetStyle(
		rg.DEFAULT,
		rg.TEXT_COLOR_PRESSED,
		rg.NewColorPropertyValue(rl.White),
	)

}

type RaylibPickerOptions struct {
	Prompt string
}
var defaultPickerOptions = RaylibPickerOptions{}

type PickerOption func(*RaylibPickerOptions)

func WithPrompt(prompt string) PickerOption {
	return func(opts *RaylibPickerOptions) {
		opts.Prompt = prompt
	}
}

func Picker(options []string, pickerOptions ...PickerOption) (choiceIdx int, ok bool) {
	pickerOpts := defaultPickerOptions
	for _, opt := range pickerOptions {
		opt(&pickerOpts)
	}

	initialize(len(options))
	// TODO kinda dumb with additional initialization here
	originalOrder := make([]matching.Matched, len(options))
	for i := range options {
		originalOrder[i].Idx=i
	}
	cursor := 0
	matched := originalOrder
	var prevInput string
	var input string
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.Black)

		if !rl.IsWindowFocused() {
			return 0, false
		}

		resetBounds()
		bounds := nextBounds()

		isControlDown := rl.IsKeyDown(rl.KeyLeftControl) || rl.IsKeyDown(rl.KeyRightControl)
		alternativeBackspace := isPressedRepeat(rl.KeyH) && isControlDown
		enter := (rl.IsKeyPressed(rl.KeyY) && isControlDown) ||
			rl.IsKeyPressed(rl.KeyEnter)

		if alternativeBackspace && len(input) > 0 {
			input = input[:len(input)-1]
		}

		rg.TextBox(bounds, &input, 1024, true)
		if input == "" {
			promptBounds := bounds
			promptBounds.X += promptBounds.Height
			promptBounds.Width -= promptBounds.Height
			rg.DrawText(
				pickerOpts.Prompt,
				promptBounds,
				int32(rg.TEXT_ALIGN_LEFT),
				rl.Gray,
			)
		}
		if prevInput != input {
			if len(input) > 0 {
				matched = matching.FindAll(input, options)
			} else {
				matched = originalOrder
			}
			cursor = 0
			prevInput = input
		}

		{ // cursor update
			moveCursorUp := isPressedRepeat(rl.KeyP) && isControlDown
			moveCursorDown := isPressedRepeat(rl.KeyN) && isControlDown
			if moveCursorUp {
				cursor -= 1
			}
			if moveCursorDown {
				cursor += 1
			}
			if cursor >= len(matched) {
				cursor = len(matched) - 1
			}
			if cursor < 0 {
				cursor = 0
			}
		}

		if enter {
			rl.CloseWindow()
			if cursor < len(matched) {
				return matched[cursor].Idx, true
			}
			return 0, false
		}

		for i, match := range matched {
			bounds := nextBounds()
			textBounds := bounds
			textBounds.X += textBounds.Height
			textBounds.Width -= textBounds.Height
			rg.DrawText(
				options[match.Idx],
				textBounds,
				int32(rg.TEXT_ALIGN_LEFT),
				rl.White,
			)

			if i == cursor {
				// TODO if cursor is not visible then keep some offset or make
				// 2d camera so you can scroll through all the options if you
				// want
				rl.DrawCircle(
					int32(bounds.X)+int32(bounds.Height)/2,
					int32(bounds.Y)+int32(bounds.Height)/2,
					max(textBoxHeight / 8, 1),
					rl.White,
				)
			}
		}
		rl.EndDrawing()
	}

	return 0, false
}

func initialize(nOptions int) {
	rl.SetTraceLogLevel(rl.LogError)
	rl.InitWindow(0, 0, "raymenu")
	rl.SetWindowState(rl.FlagWindowUndecorated)
	rl.SetTargetFPS(
		int32(
			rl.GetMonitorRefreshRate(
				rl.GetCurrentMonitor(),
			),
		),
	)
	monitor := rl.GetCurrentMonitor()
	monitorWidth := rl.GetMonitorWidth(monitor)
	monitorHeight := rl.GetMonitorHeight(monitor)
	rl.SetWindowSize(
		monitorWidth/2,
		min(monitorHeight/2/textBoxHeight, nOptions+1)*textBoxHeight,
	)
	rl.SetWindowPosition(
		monitorWidth/2-rl.GetScreenWidth()/2,
		monitorHeight/2-rl.GetScreenHeight()/2,
	)
	style()
}

func isPressedRepeat(key int32) bool {
	return rl.IsKeyPressed(key) || rl.IsKeyPressedRepeat(key)
}


var yOffset float32 = 0.0

func resetBounds() {
	yOffset = 0.0
}

func nextBounds() (bounds rl.Rectangle) {
	bounds = rl.Rectangle{X: 0, Y: yOffset, Width: float32(rl.GetScreenWidth()), Height: textBoxHeight}
	yOffset += textBoxHeight
	return
}
