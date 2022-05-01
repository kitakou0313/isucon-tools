package main

import (
	"fmt"

	"github.com/pkg/profile"
)

func main() {
	p := profile.Start(profile.ProfilePath("./"))
	fmt.Println("Hello, isucon!")
	p.Stop()
}
