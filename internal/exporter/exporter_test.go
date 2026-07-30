package exporter

import (
	"image"
	"image/color"
	"testing"
)

func TestFlattenTransparencyUsesMatte(t *testing.T) {
	src := image.NewNRGBA(image.Rect(0, 0, 1, 1))
	src.SetNRGBA(0, 0, color.NRGBA{R: 255, G: 0, B: 0, A: 128})

	out := FlattenTransparency(src, color.NRGBA{R: 255, G: 255, B: 255, A: 255})
	got := color.NRGBAModel.Convert(out.At(0, 0)).(color.NRGBA)

	if got.A != 255 {
		t.Fatalf("flattened alpha = %d, want opaque", got.A)
	}
	if got.R <= got.G {
		t.Fatalf("expected red over white, got %#v", got)
	}
}
