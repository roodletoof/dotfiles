package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"slices"
	"strings"

	_ "embed"

	rg "github.com/gen2brain/raylib-go/raygui"
	rl "github.com/gen2brain/raylib-go/raylib"
	"github.com/ktr0731/go-fuzzyfinder/matching"
)

const fontSize = 20
const textBoxHeight = fontSize + 6

// TODO: move the raymenu function to its own package

//go:embed gomono-font/Go-Mono.ttf
var font_tff []byte

type State struct {
	Font rl.Font
}

func main() {
	input, err := io.ReadAll(os.Stdin)
	if err != nil {
		log.Fatalln(err)
	}
	choices := strings.Split(string(input), "\n")
	choices = slices.DeleteFunc(choices, func(l string) bool {
		return l == ""
	})
	choice, ok := raymenu(choices)
	if ok {
		fmt.Println(choice)
	}
}


func isPressedRepeat(key int32) bool {
	return rl.IsKeyPressed(key) || rl.IsKeyPressedRepeat(key)
}


func raymenu(options []string) (choice string, ok bool) {
	state := initialize(len(options))
	rg.SetFont(state.Font)
	rg.SetStyle(rg.DEFAULT, rg.TEXT_SIZE, fontSize)
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
				return options[matched[cursor].Idx], true
			}
			return "", false
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

	return "", false
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

func initialize(nOptions int) State {
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

	return State{
		Font: rl.LoadFontFromMemory(".ttf", font_tff, fontSize, nil),
	}
}
