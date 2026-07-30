package exporter

import (
	"image"
	"image/color"
	"image/draw"
)

func FlattenTransparency(src image.Image, matte color.NRGBA) *image.NRGBA {
	bounds := src.Bounds()
	out := image.NewNRGBA(bounds)
	draw.Draw(out, bounds, &image.Uniform{C: matte}, image.Point{}, draw.Src)
	draw.Draw(out, bounds, src, bounds.Min, draw.Over)
	return out
}
