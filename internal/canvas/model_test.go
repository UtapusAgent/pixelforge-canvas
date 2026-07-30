package canvas

import "testing"

func TestAlignLeft(t *testing.T) {
	objects := []Object{
		{ID: "a", X: 40, Y: 10, Width: 50, Height: 50, Visible: true},
		{ID: "b", X: 140, Y: 80, Width: 30, Height: 50, Visible: true},
		{ID: "c", X: 10, Y: 5, Width: 20, Height: 20, Visible: true},
	}

	next := Align(objects, []string{"a", "b"}, AlignLeft)

	if next[0].X != 40 || next[1].X != 40 {
		t.Fatalf("selected objects were not left-aligned: %#v", next)
	}
	if next[2].X != 10 {
		t.Fatalf("unselected object moved: %#v", next[2])
	}
}

func TestAlignSkipsLockedObjects(t *testing.T) {
	objects := []Object{
		{ID: "a", X: 40, Width: 50, Height: 50, Visible: true},
		{ID: "b", X: 140, Width: 30, Height: 50, Locked: true, Visible: true},
	}

	next := Align(objects, []string{"a", "b"}, AlignRight)

	if next[1].X != 140 {
		t.Fatalf("locked object moved: %#v", next[1])
	}
}

func TestDistributeHorizontally(t *testing.T) {
	objects := []Object{
		{ID: "a", X: 0, Width: 10, Height: 10, Visible: true},
		{ID: "b", X: 40, Width: 10, Height: 10, Visible: true},
		{ID: "c", X: 100, Width: 10, Height: 10, Visible: true},
	}

	next := Align(objects, []string{"a", "b", "c"}, DistributeHorizontally)

	if next[1].X != 50 {
		t.Fatalf("middle object was not distributed, got x=%v", next[1].X)
	}
}
