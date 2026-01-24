package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/ktr0731/go-fuzzyfinder"
	"gopkg.in/yaml.v3"
)

type Window struct {
	Path string `yaml:"path"`
	Name string `yaml:"name"`
	Program string `yaml:"program"`
}

func (w Window) ExpandedPath() string {
	expanded, err := expandTilde(w.Path)
	if err != nil {
		log.Fatalln(err)
	}
	return expanded
}

type Config map[string][]Window

const (
	tmux = "tmux"
	mkdir = "mkdir"
)

func main() {
	_, err := exec.LookPath(tmux)
	if err != nil {
		log.Fatalln(err)
	}

	_, err = exec.LookPath(mkdir)
	if err != nil {
		log.Fatalln(err)
	}

	homeDir, err := os.UserHomeDir()
	if err != nil {
		log.Fatalln(err)
	}

	configFilePath := filepath.Join(homeDir, ".sesh.yaml")
	f, err := os.Open(configFilePath)
	if err != nil {
		log.Fatalln(err)
	}

	var config Config
	err = yaml.NewDecoder(f).Decode(&config)
	if err != nil {
		log.Fatalln(err)
	}

	seshNames := make([]string, 0, len(config))
	for seshName := range config {
		seshNames = append(seshNames, seshName)
	}
	i, err := fuzzyfinder.Find(seshNames, func(i int) string {
		return seshNames[i]
	})
	if err != nil {
		return
	}

	seshName := seshNames[i]
	if HasSession(seshName) {
		ActivateSession(seshName)
	} else {
		sesh := config[seshName]
		if len(sesh) == 0 {
			log.Println("no windows in session")
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
		ActivateSession(seshName)
	}
}

var sessionCache = make(map[string]bool)
func HasSession(seshName string) bool {
	has, ok := sessionCache[seshName]
	if ok {
		return has
	}
	res := exec.Command(tmux, "has-session", "-t", seshName).Run()
	has = res == nil
	sessionCache[seshName] = has
	return has
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
		log.Fatalln("missing seshName")
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
	args = append(args, window.Program)
	exec.Command(tmux, args...).Run()
}

func ActivateSession(name string) {
	_, isInTmux := os.LookupEnv("TMUX")
	var err error
	if isInTmux {
		err = exec.Command(tmux, "switch-client", "-t", name).Run()
	} else {
		err = exec.Command(tmux, "attach", "-t", name).Run()
	}
	if err != nil {
		log.Fatalln(err)
	}
}
