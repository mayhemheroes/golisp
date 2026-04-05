package golisp

import (
	"bytes"
	"embed"
	"io/fs"
	"sync"
)

//go:embed lib/*.lisp
var libFS embed.FS

var (
	loadLibOnce  sync.Once
	loadLibNodes []*Node
	loadLibErr   error
)

func cachedLibNodes() ([]*Node, error) {
	loadLibOnce.Do(func() {
		var entries []fs.DirEntry
		entries, loadLibErr = fs.ReadDir(libFS, "lib")
		if loadLibErr != nil {
			return
		}
		loadLibNodes = make([]*Node, 0, len(entries))
		for _, entry := range entries {
			var b []byte
			b, loadLibErr = libFS.ReadFile("lib/" + entry.Name())
			if loadLibErr != nil {
				return
			}
			var node *Node
			node, loadLibErr = NewParser(bytes.NewReader(b)).Parse()
			if loadLibErr != nil {
				return
			}
			loadLibNodes = append(loadLibNodes, node)
		}
	})
	return loadLibNodes, loadLibErr
}

func LoadLib(env *Env) error {
	nodes, err := cachedLibNodes()
	if err != nil {
		return err
	}
	for _, node := range nodes {
		_, err = env.Eval(node)
		if err != nil {
			return err
		}
	}
	return nil
}
