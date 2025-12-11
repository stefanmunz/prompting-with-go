package main

import (
	"fmt"
	"runtime"
)

func main() {
	fmt.Printf("I am built with Go %s\n", runtime.Version())
}
