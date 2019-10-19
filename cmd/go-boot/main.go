package main

import (
	"fmt"

	"github.com/ppanyukov/go-boot/pkg/version"
)

func main() {
	v := version.Print("go-boot")
	fmt.Println(v)
}
