package main

import (
	"embed"
	"fmt"
	"os"

	"github.com/UtapusAgent/pixelforge-canvas/internal/qtapp"
)

//go:embed qml/*
var qmlFS embed.FS

func main() {
	if err := qtapp.Run(qmlFS); err != nil {
		fmt.Fprintf(os.Stderr, "pixelforge: %v\n", err)
		os.Exit(1)
	}
}
