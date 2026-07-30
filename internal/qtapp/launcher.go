package qtapp

import (
	"embed"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
)

var qmlLaunchers = []string{"qml6", "qml", "qmlscene6", "qmlscene"}

// Run materializes the embedded Qt Quick UI and starts it with an available Qt
// QML launcher. Keeping this bridge small lets the Go core stay testable.
func Run(qmlFS embed.FS) error {
	launcher, err := findLauncher()
	if err != nil {
		return err
	}

	dir, err := os.MkdirTemp("", "pixelforge-qml-*")
	if err != nil {
		return fmt.Errorf("create qml runtime dir: %w", err)
	}
	defer os.RemoveAll(dir)

	if err := materialize(qmlFS, "qml", dir); err != nil {
		return err
	}

	mainQML := filepath.Join(dir, "Main.qml")
	cmd := exec.Command(launcher, mainQML)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	return cmd.Run()
}

func findLauncher() (string, error) {
	for _, name := range qmlLaunchers {
		if path, err := exec.LookPath(name); err == nil {
			return path, nil
		}
	}
	return "", errors.New("Qt QML launcher not found; install Qt 6 runtime and make qml6 or qmlscene available")
}

func materialize(source embed.FS, root, dest string) error {
	return fs.WalkDir(source, root, func(path string, entry fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		rel, err := filepath.Rel(root, path)
		if err != nil {
			return err
		}
		if rel == "." {
			return nil
		}
		target := filepath.Join(dest, rel)
		if entry.IsDir() {
			return os.MkdirAll(target, 0o755)
		}
		data, err := source.ReadFile(path)
		if err != nil {
			return err
		}
		if err := os.MkdirAll(filepath.Dir(target), 0o755); err != nil {
			return err
		}
		return os.WriteFile(target, data, 0o644)
	})
}
