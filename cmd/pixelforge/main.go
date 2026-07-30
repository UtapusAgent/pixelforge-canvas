package main

import (
	"embed"
	"fmt"
	"os"

	"github.com/UtapusAgent/pixelforge-canvas/internal/bgremove"
	"github.com/UtapusAgent/pixelforge-canvas/internal/imageio"
	"github.com/UtapusAgent/pixelforge-canvas/internal/qtapp"
)

//go:embed qml/*
var qmlFS embed.FS

func main() {
	if len(os.Args) > 1 {
		if err := runCommand(os.Args[1:]); err != nil {
			fmt.Fprintf(os.Stderr, "pixelforge: %v\n", err)
			os.Exit(1)
		}
		return
	}
	if err := qtapp.Run(qmlFS); err != nil {
		fmt.Fprintf(os.Stderr, "pixelforge: %v\n", err)
		os.Exit(1)
	}
}

func runCommand(args []string) error {
	switch args[0] {
	case "device-status":
		status := bgremove.DetectDevice()
		fmt.Printf("provider=%s gpu=%v fallback=%s\n", status.Provider, status.GPUAvailable, status.Fallback)
		return nil
	case "bg-remove":
		if len(args) != 3 {
			return fmt.Errorf("usage: pixelforge bg-remove input output.png")
		}
		img, err := imageio.Load(args[1])
		if err != nil {
			return err
		}
		return imageio.Save(args[2], bgremove.RemoveBackground(img, bgremove.Options{Feather: 24}), 0)
	default:
		return fmt.Errorf("unknown command %q", args[0])
	}
}
