package main

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/felixge/fgprof"
)

// echoでのサンプル
/*
var stopProfile func() error

// for bench start
func benchStartHandler(c echo.Context) error {
	profilePath := "/etc/pprof"

	err := os.MkdirAll(profilePath, 0777)
	if err != nil {
		c.Logger().Errorf("error bench start: %s", err)
		return c.String(
			http.StatusInternalServerError, "Fail to create bench dir",
		)
	}

	fn := filepath.Join(profilePath, "fgprof.pprof")
	f, err := os.Create(fn)
	if err != nil {
		c.Logger().Errorf("error bench start: %s", err)
		return c.String(
			http.StatusInternalServerError, "Fail to create profile file",
		)
	}

	stopProfile = fgprof.Start(f, fgprof.FormatPprof)
	return c.String(
		http.StatusOK, "Bench start",
	)
}

func benchStopHandler(c echo.Context) error {
	stopProfile()
	return c.String(
		http.StatusOK, "Bench stop",
	)
}*/

var stopProfile func() error

// for bench start
func startProfile() error {
	profilePath := "/etc/pprof"

	err := os.MkdirAll(profilePath, 0777)
	if err != nil {
		return fmt.Errorf("Fail to create dir %w", err)
	}

	fn := filepath.Join(profilePath, "fgprof.pprof")
	f, err := os.Create(fn)
	if err != nil {
		return fmt.Errorf("Fail to create profile file: %w", err)
	}

	stopProfile = fgprof.Start(f, fgprof.FormatPprof)
	return nil
}

func main() {
	err := startProfile()
	if err != nil {
		panic(err)
	}
	fmt.Println("Hello, isucon!")
	stopProfile()
}
