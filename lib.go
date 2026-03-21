package golisp

import (
	"embed"
	"io/fs"
	"strings"
)

//go:embed lib/*.lisp
var libFS embed.FS

func LoadLib(env *Env) error {
	entries, err := fs.ReadDir(libFS, "lib")
	if err != nil {
		return err
	}
	for _, entry := range entries {
		b, err := libFS.ReadFile("lib/" + entry.Name())
		if err != nil {
			return err
		}
		node, err := NewParser(strings.NewReader(string(b))).Parse()
		if err != nil {
			return err
		}
		_, err = env.Eval(node)
		if err != nil {
			return err
		}
	}
	return nil
}
