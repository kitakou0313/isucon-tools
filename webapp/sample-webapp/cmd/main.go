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
}

// for profile
	e.GET("/api/bench/start", benchStartHandler)
	e.GET("/api/bench/stop", benchStopHandler)

*/

/*
Requestをファイルにダンプするmiddlewareを追加するコード
reqDumpPath := "/etc/req-dump"
	err = os.MkdirAll(reqDumpPath, 0777)
	if err != nil {
		e.Logger.Fatalf("failed to create req dump file: %v", err)
		return
	}

	fn := filepath.Join(reqDumpPath, "req-dump")
	f, err := os.Create(fn)
	if err != nil {
		e.Logger.Fatalf("failed to create req dump file: %v", err)
		return
	}

	e.Use(middleware.BodyDump(func(c echo.Context, reqBody, resBody []byte) {
		fmt.Fprintf(f, "ReqPath:%v ReqHeader:%v\n", c.Request().RequestURI, c.Request().Header)
	}))

*/

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
