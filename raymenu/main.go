package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"slices"
	"strings"

	"github.com/roodletoof/dotfiles/raymenu/picker"
	"github.com/alexflint/go-arg"
)

func main() {
	var args struct {
		Prompt string `arg:"-p" help:"ghost text to display in the empty input section"`
	}
	arg.MustParse(&args)

	input, err := io.ReadAll(os.Stdin)
	if err != nil {
		log.Fatalln(err)
	}
	choices := strings.Split(string(input), "\n")
	choices = slices.DeleteFunc(choices, func(l string) bool {
		return l == ""
	})
	choice, ok := picker.Picker(
		choices,
		picker.WithPrompt(args.Prompt),
	)
	if ok {
		fmt.Println(choices[choice])
	}
}


