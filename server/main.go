package main

import (
	"database/sql"
	"fmt"
	"os"
	"strings"

	"github.com/gofor-little/env"

	_ "github.com/tursodatabase/libsql-client-go/libsql"
)

type User struct {
	ID       int
	name     string
	password string
}

func queryUsers(db *sql.DB) ([]User, error) {
	var users []User

	rows, err := db.Query("SELECT * FROM users")
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to execue query: %v\n", err)
		os.Exit(1)
	}

	defer rows.Close()

	for rows.Next() {
		var user User

		if err := rows.Scan(&user.ID, &user.name, &user.password); err != nil {
			fmt.Println("Error scanning row: ")

			return []User{}, err
		}

		users = append(users, user)
	}

	if err := rows.Err(); err != nil {
		return []User{}, err
	}

	return users, nil
}

func main() {
	if err := env.Load(".env"); err != nil {
		panic("failed to load environment file")
	}

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

	fmt.Println("Database is ready to go")
	users, err := queryUsers(db)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to open db %s: %s", databaseAccessURL, err)
	}

	for _, v := range users {
		fmt.Println(v)
	}

	defer db.Close()
}
