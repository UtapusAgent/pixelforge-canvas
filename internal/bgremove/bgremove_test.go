package bgremove

import (
	"image"
	"image/color"
	"testing"
)

func TestRemoveBackgroundMakesCornerColorTransparent(t *testing.T) {
	src := image.NewNRGBA(image.Rect(0, 0, 12, 12))
	for y := 0; y < 12; y++ {
		for x := 0; x < 12; x++ {
			src.SetNRGBA(x, y, color.NRGBA{R: 240, G: 240, B: 240, A: 255})
		}
	}
	for y := 4; y < 8; y++ {
		for x := 4; x < 8; x++ {
			src.SetNRGBA(x, y, color.NRGBA{R: 20, G: 80, B: 180, A: 255})
		}
	}

	out := RemoveBackground(src, Options{Threshold: 20})

	if _, _, _, a := out.At(0, 0).RGBA(); a != 0 {
		t.Fatalf("background alpha = %d, want transparent", a)
	}
	if _, _, _, a := out.At(5, 5).RGBA(); a == 0 {
		t.Fatal("foreground was removed")
	}
}
