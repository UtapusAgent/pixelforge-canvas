package canvas

import "errors"

type Layer struct {
	ID      string
	Name    string
	Visible bool
	Locked  bool
}

func MoveLayer(layers []Layer, layerID string, delta int) []Layer {
	next := make([]Layer, len(layers))
	copy(next, layers)
	from := -1
	for i, layer := range next {
		if layer.ID == layerID {
			from = i
			break
		}
	}
	if from < 0 {
		return next
	}
	to := from + delta
	if to < 0 || to >= len(next) {
		return next
	}
	next[from], next[to] = next[to], next[from]
	return next
}

func DeleteLayer(layers []Layer, objects []Object, layerID string) ([]Layer, []Object, error) {
	if len(layers) <= 1 {
		return layers, objects, errors.New("cannot delete the last layer")
	}

	nextLayers := make([]Layer, 0, len(layers)-1)
	found := false
	for _, layer := range layers {
		if layer.ID == layerID {
			found = true
			continue
		}
		nextLayers = append(nextLayers, layer)
	}
	if !found {
		return layers, objects, nil
	}

	nextObjects := make([]Object, 0, len(objects))
	for _, object := range objects {
		if object.LayerID != layerID {
			nextObjects = append(nextObjects, object)
		}
	}
	return nextLayers, nextObjects, nil
}
