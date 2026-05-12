package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"slices"
	"strings"

	"github.com/roodletoof/dotfiles/raymenu/picker"
)


func main() {
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
	)
	if ok {
		fmt.Println(choices[choice])
	}
}


