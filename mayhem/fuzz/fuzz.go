package fuzz

import (
	"bytes"
	"io"

	"github.com/mattn/golisp"
)

// Fuzz parses and evaluates the input as golisp source — the same code path
// the golisp CLI runs on a script (parse.go + ops.go + lib.go).
func Fuzz(data []byte) int {
	parser := golisp.NewParser(bytes.NewReader(data))
	node, err := parser.Parse()
	if err != nil {
		return 0
	}
	env := golisp.NewEnv(nil)
	if err := golisp.LoadLib(env); err != nil {
		return 0
	}
	env.SetOut(io.Discard)
	if _, err := env.Eval(node); err != nil {
		return 0
	}
	return 1
}
