package database

import (
	"database/sql"
	"fmt"
	"os"
	"strings"

	"github.com/gofor-little/env"
)

func InitDatabase() *sql.DB {
	databaseURL := env.Get("TURSO_DATABASE_URL", "-1")
	if strings.Compare(databaseURL, "-1") == 0 {
		panic("failed to load database url from .env")
	}

	databaseToken := env.Get("TURSO_AUTH_TOKEN", "-1")
	if strings.Compare(databaseToken, "-1") == 0 {
		panic("failed to load database token from .env")
	}

	databaseAccessURL := fmt.Sprintf("%s?authToken=%s", databaseURL, databaseToken)

	db, err := sql.Open("libsql", databaseAccessURL)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to open db %s: %s", databaseAccessURL, err)
		os.Exit(1)
	}

	return db
}
