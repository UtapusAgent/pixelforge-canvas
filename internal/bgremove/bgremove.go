package bgremove

import (
	"image"
	"image/color"
	"image/draw"
	"math"
	"os"
	"os/exec"
)

type DeviceStatus struct {
	GPUAvailable bool
	Provider     string
	Fallback     string
}

func DetectDevice() DeviceStatus {
	if _, err := exec.LookPath("nvidia-smi"); err == nil {
		return DeviceStatus{GPUAvailable: true, Provider: "CUDA", Fallback: "CPU"}
	}
	if _, err := os.Stat("/dev/dri/renderD128"); err == nil {
		return DeviceStatus{GPUAvailable: true, Provider: "Vulkan/OpenCL", Fallback: "CPU"}
	}
	return DeviceStatus{GPUAvailable: false, Provider: "CPU", Fallback: "CPU"}
}

type Options struct {
	Threshold float64
	Feather   uint8
}

func RemoveBackground(src image.Image, options Options) *image.NRGBA {
	if options.Threshold <= 0 {
		options.Threshold = 44
	}
	bounds := src.Bounds()
	out := image.NewNRGBA(bounds)
	draw.Draw(out, bounds, src, bounds.Min, draw.Src)

	bg := estimateBackground(src)
	for y := bounds.Min.Y; y < bounds.Max.Y; y++ {
		for x := bounds.Min.X; x < bounds.Max.X; x++ {
			i := out.PixOffset(x, y)
			px := color.NRGBAModel.Convert(src.At(x, y)).(color.NRGBA)
			dist := colorDistance(px, bg)
			if dist <= options.Threshold {
				out.Pix[i+3] = 0
				continue
			}
			if options.Feather > 0 && dist < options.Threshold+float64(options.Feather) {
				alpha := uint8(math.Min(255, ((dist-options.Threshold)/float64(options.Feather))*255))
				out.Pix[i+3] = alpha
			}
		}
	}
	return out
}

func estimateBackground(src image.Image) color.NRGBA {
	bounds := src.Bounds()
	samples := []color.Color{
		src.At(bounds.Min.X, bounds.Min.Y),
		src.At(bounds.Max.X-1, bounds.Min.Y),
		src.At(bounds.Min.X, bounds.Max.Y-1),
		src.At(bounds.Max.X-1, bounds.Max.Y-1),
	}
	var r, g, b float64
	for _, sample := range samples {
		px := color.NRGBAModel.Convert(sample).(color.NRGBA)
		r += float64(px.R)
		g += float64(px.G)
		b += float64(px.B)
	}
	return color.NRGBA{R: uint8(r / 4), G: uint8(g / 4), B: uint8(b / 4), A: 255}
}

func colorDistance(a, b color.NRGBA) float64 {
	dr := float64(a.R) - float64(b.R)
	dg := float64(a.G) - float64(b.G)
	db := float64(a.B) - float64(b.B)
	return math.Sqrt(dr*dr + dg*dg + db*db)
}
