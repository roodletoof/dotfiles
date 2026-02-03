package main

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strings"
	"syscall"

	"github.com/goccy/go-yaml"
	"github.com/ktr0731/go-fuzzyfinder"
)

var _ yaml.InterfaceUnmarshaler = &Programs{}
type Programs struct {
	programs []string
}

// UnmarshalYAML implements [yaml.InterfaceUnmarshaler].
func (p *Programs) UnmarshalYAML(f func(any) error) error {
	var singleStr string
	err1 := f(&singleStr)
	if err1 == nil {
		p.programs = []string{singleStr}
		return nil
	}
	err2 := f(&p.programs)
	if err2 != nil {
		return errors.Join(
			err1,
			err2,
		)
	}
	return nil
}

type Window struct {
	Path    string `yaml:"path"`
	Name    string `yaml:"name"`
	Programs Programs `yaml:"program"`
}

func (w Window) ExpandedPath() string {
	expanded, err := expandTilde(w.Path)
	if err != nil {
		panic(err)
	}
	return expanded
}

type Config map[string][]Window

const (
	tmux  = "tmux"
	mkdir = "mkdir"
)

func main() {
	_, err := exec.LookPath(tmux)
	if err != nil {
		panic(err)
	}

	_, err = exec.LookPath(mkdir)
	if err != nil {
		panic(err)
	}

	homeDir, err := os.UserHomeDir()
	if err != nil {
		panic(err)
	}

	configFilePath := filepath.Join(homeDir, ".sesh.yaml")
	f, err := os.Open(configFilePath)
	if err != nil {
		panic(err)
	}

	var config Config
	err = yaml.NewDecoder(f).Decode(&config)
	if err != nil {
		panic(err)
	}

	seshNames := make([]string, 0, len(config))
	for seshName := range config {
		seshNames = append(seshNames, seshName)
	}
	slices.Sort(seshNames)
	i, err := fuzzyfinder.Find(
		seshNames,
		func(i int) string {
			return seshNames[i]
		},
		fuzzyfinder.WithPreviewWindow(
			func(i, width, height int) string {
				width = width/2 - 4
				if i < 0 {
					return ""
				}
				seshName := seshNames[i]
				windows, _ := config[seshName]
				builder := strings.Builder{}
				for _, window := range windows {
					if window.Name != "" {
						fmt.Fprintln(&builder, window.Name)
					} else {
						fmt.Fprintln(&builder, "[no name]")
					}
					if window.Path != "" {
						fmt.Fprintf(&builder, "    path: %s\n", window.Path)
					}
					if len(window.Programs.programs) != 0 {
						fmt.Fprintf(&builder, "    program:\n")
					}
					for _, prog := range window.Programs.programs {
						fmt.Fprintf(&builder, "        - %s\n", prog)
					}
					fmt.Fprint(&builder, "\n")
				}
				return builder.String()
			},
		),
	)
	if err != nil {
		return
	}

	seshName := seshNames[i]
	if HasSession(seshName) {
		TurnIntoTmux(seshName)
	} else {
		sesh := config[seshName]
		if len(sesh) == 0 {
			fmt.Println("no windows in session")
			return
		}
		for _, window := range sesh {
			// TODO: use go stdandard library instead
			exec.Command(mkdir, "-p", window.ExpandedPath()).Run()
		}
		for _, window := range sesh {
			NewWindowInSession(seshName, window)
		}
		exec.Command(tmux, "select-window", "-t", fmt.Sprintf("%s:^", seshName)).Run()
		TurnIntoTmux(seshName)
	}
}

func HasSession(seshName string) bool {
	res := exec.Command(tmux, "has-session", "-t", seshName).Run()
	return res == nil
}

func expandTilde(path string) (string, error) {
	if !strings.HasPrefix(path, "~") {
		return path, nil
	}
	userHomeDir, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(userHomeDir, path[1:]), nil
}

func NewWindowInSession(seshName string, window Window) {
	if seshName == "" {
		panic("missing seshName")
	}
	var args = []string{}
	if HasSession(seshName) {
		args = append(args, "new-window", "-t", seshName)
	} else {
		args = append(args, "new-session", "-d", "-s", seshName)
	}
	if window.ExpandedPath() != "" {
		args = append(args, "-c", window.ExpandedPath())
	}
	if window.Name != "" {
		args = append(args, "-n", window.Name)
	}
	cmd := exec.Command(tmux, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	err := cmd.Run()
	if err != nil {
		panic(err)
	}
	for _, prog := range window.Programs.programs {
		var carriageReturn = string([]byte{13})
		cmd = exec.Command(tmux, "send-keys", "-t", fmt.Sprintf("%s:$", seshName), prog, carriageReturn)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		cmd.Stdin = os.Stdin
		err := cmd.Run()
		if err != nil {
			panic(err)
		}
	}
}

func TurnIntoTmux(sessionName string) {
	_, isInTmux := os.LookupEnv("TMUX")
	tmuxPath, err := exec.LookPath(tmux)
	if err != nil {
		panic(err)
	}
	if isInTmux {
		err = syscall.Exec(tmuxPath, []string{tmuxPath, "switch-client", "-t", sessionName}, os.Environ())
	} else {
		err = syscall.Exec(tmuxPath, []string{tmuxPath, "attach", "-t", sessionName}, os.Environ())
	}
	if err != nil {
		panic(err)
	}
}
