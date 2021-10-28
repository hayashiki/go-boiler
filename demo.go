package goboiler

import (
	"fmt"
	"runtime"

	"rsc.io/quote"
)

func Demo() {
	fmt.Printf("Go version: %s\n", runtime.Version())
	fmt.Printf("GOOS: %s\n", runtime.GOOS)
	fmt.Printf("GOARCH: %s\n", runtime.GOARCH)

	fmt.Println(quote.Go())
}
