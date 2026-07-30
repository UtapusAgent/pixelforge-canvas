package canvas

import "math"

type Kind string

const (
	KindImage   Kind = "image"
	KindText    Kind = "text"
	KindDrawing Kind = "drawing"
)

type Object struct {
	ID       string
	Kind     Kind
	LayerID  string
	X        float64
	Y        float64
	Width    float64
	Height   float64
	Rotation float64
	Locked   bool
	Visible  bool
}

type AlignMode string

const (
	AlignLeft              AlignMode = "left"
	AlignHorizontalCenter  AlignMode = "horizontal-center"
	AlignRight             AlignMode = "right"
	AlignTop               AlignMode = "top"
	AlignVerticalCenter    AlignMode = "vertical-center"
	AlignBottom            AlignMode = "bottom"
	DistributeHorizontally AlignMode = "distribute-horizontal"
	DistributeVertically   AlignMode = "distribute-vertical"
)

func Align(objects []Object, selectedIDs []string, mode AlignMode) []Object {
	selected := selectedSet(selectedIDs)
	targets := make([]int, 0, len(selectedIDs))
	for i, object := range objects {
		if selected[object.ID] && !object.Locked && object.Visible {
			targets = append(targets, i)
		}
	}
	if len(targets) == 0 {
		return cloneObjects(objects)
	}

	next := cloneObjects(objects)
	bounds := selectionBounds(objects, targets)

	switch mode {
	case AlignLeft:
		for _, i := range targets {
			next[i].X = bounds.Left
		}
	case AlignHorizontalCenter:
		center := bounds.Left + bounds.Width/2
		for _, i := range targets {
			next[i].X = center - next[i].Width/2
		}
	case AlignRight:
		right := bounds.Left + bounds.Width
		for _, i := range targets {
			next[i].X = right - next[i].Width
		}
	case AlignTop:
		for _, i := range targets {
			next[i].Y = bounds.Top
		}
	case AlignVerticalCenter:
		center := bounds.Top + bounds.Height/2
		for _, i := range targets {
			next[i].Y = center - next[i].Height/2
		}
	case AlignBottom:
		bottom := bounds.Top + bounds.Height
		for _, i := range targets {
			next[i].Y = bottom - next[i].Height
		}
	case DistributeHorizontally:
		distribute(next, targets, true)
	case DistributeVertically:
		distribute(next, targets, false)
	}

	return next
}

type Bounds struct {
	Left   float64
	Top    float64
	Width  float64
	Height float64
}

func selectionBounds(objects []Object, indexes []int) Bounds {
	left := math.Inf(1)
	top := math.Inf(1)
	right := math.Inf(-1)
	bottom := math.Inf(-1)
	for _, i := range indexes {
		object := objects[i]
		left = math.Min(left, object.X)
		top = math.Min(top, object.Y)
		right = math.Max(right, object.X+object.Width)
		bottom = math.Max(bottom, object.Y+object.Height)
	}
	return Bounds{Left: left, Top: top, Width: right - left, Height: bottom - top}
}

func distribute(objects []Object, indexes []int, horizontal bool) {
	if len(indexes) < 3 {
		return
	}
	sortIndexes(objects, indexes, horizontal)

	first := objects[indexes[0]]
	last := objects[indexes[len(indexes)-1]]
	var start, end, occupied float64
	for _, i := range indexes {
		if horizontal {
			occupied += objects[i].Width
		} else {
			occupied += objects[i].Height
		}
	}
	if horizontal {
		start = first.X
		end = last.X + last.Width
	} else {
		start = first.Y
		end = last.Y + last.Height
	}
	gap := (end - start - occupied) / float64(len(indexes)-1)
	cursor := start
	for _, i := range indexes {
		if horizontal {
			objects[i].X = cursor
			cursor += objects[i].Width + gap
		} else {
			objects[i].Y = cursor
			cursor += objects[i].Height + gap
		}
	}
}

func sortIndexes(objects []Object, indexes []int, horizontal bool) {
	for i := 1; i < len(indexes); i++ {
		j := i
		for j > 0 && lessObject(objects[indexes[j]], objects[indexes[j-1]], horizontal) {
			indexes[j], indexes[j-1] = indexes[j-1], indexes[j]
			j--
		}
	}
}

func lessObject(left, right Object, horizontal bool) bool {
	if horizontal {
		return left.X < right.X
	}
	return left.Y < right.Y
}

func selectedSet(ids []string) map[string]bool {
	selected := make(map[string]bool, len(ids))
	for _, id := range ids {
		selected[id] = true
	}
	return selected
}

func cloneObjects(objects []Object) []Object {
	next := make([]Object, len(objects))
	copy(next, objects)
	return next
}
