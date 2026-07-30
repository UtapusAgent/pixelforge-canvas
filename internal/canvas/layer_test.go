package canvas

import "testing"

func TestMoveLayer(t *testing.T) {
	layers := []Layer{
		{ID: "background"},
		{ID: "photo"},
		{ID: "text"},
	}

	next := MoveLayer(layers, "photo", 1)

	if next[2].ID != "photo" {
		t.Fatalf("expected photo layer to move forward, got %#v", next)
	}
	if layers[1].ID != "photo" {
		t.Fatalf("original layer order mutated: %#v", layers)
	}
}

func TestDeleteLayerRemovesObjects(t *testing.T) {
	layers := []Layer{{ID: "base"}, {ID: "text"}}
	objects := []Object{
		{ID: "a", LayerID: "base"},
		{ID: "b", LayerID: "text"},
	}

	nextLayers, nextObjects, err := DeleteLayer(layers, objects, "text")
	if err != nil {
		t.Fatal(err)
	}
	if len(nextLayers) != 1 || len(nextObjects) != 1 {
		t.Fatalf("unexpected delete result: %#v %#v", nextLayers, nextObjects)
	}
	if nextObjects[0].ID != "a" {
		t.Fatalf("wrong object kept: %#v", nextObjects)
	}
}
