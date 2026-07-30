package imageio

import (
	"fmt"
	"image"
	"image/jpeg"
	"image/png"
	"os"
	"path/filepath"
	"strings"
)

func Load(path string) (image.Image, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()
	img, _, err := image.Decode(file)
	return img, err
}

func Save(path string, img image.Image, jpegQuality int) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	file, err := os.Create(path)
	if err != nil {
		return err
	}
	defer file.Close()

	switch strings.ToLower(filepath.Ext(path)) {
	case ".png":
		return png.Encode(file, img)
	case ".jpg", ".jpeg":
		if jpegQuality <= 0 {
			jpegQuality = 92
		}
		return jpeg.Encode(file, img, &jpeg.Options{Quality: jpegQuality})
	default:
		return fmt.Errorf("unsupported output format %q", filepath.Ext(path))
	}
}
