package golisp

import (
	"bytes"
	"strings"
	"testing"
)

func BenchmarkFizzBuzz(b *testing.B) {
	src := `(dotimes (i 100)
  (let ((num (+ i 1)))
    (if (= 0 (mod num 3))
      (prin1 "Fizz")
      nil)
    (if (= 0 (mod num 5))
      (prin1 "Buzz")
      nil)
    (if (and (not (= 0 (mod num 5)))
             (not (= 0 (mod num 3))))
      (prin1 num))
    (prin1 "\n")))`
	var buf bytes.Buffer
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		buf.Reset()
		env := NewEnv(nil)
		_ = LoadLib(env)
		env.out = &buf
		node, _ := NewParser(strings.NewReader(src)).Parse()
		env.Eval(node)
	}
}

func BenchmarkArith(b *testing.B) {
	src := `(defun fib (n) (if (<= n 1) n (+ (fib (- n 1)) (fib (- n 2)))))
(fib 20)`
	var buf bytes.Buffer
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		buf.Reset()
		env := NewEnv(nil)
		_ = LoadLib(env)
		env.out = &buf
		node, _ := NewParser(strings.NewReader(src)).Parse()
		env.Eval(node)
	}
}
