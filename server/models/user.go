package models

import (
	"database/sql"
	"fmt"
	"os"
)

type User struct {
	ID       int
	Name     string
	Password string
}

func QueryUsers(db *sql.DB) ([]User, error) {
	var users []User

	rows, err := db.Query("SELECT * FROM users")
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to execue query: %v\n", err)
		os.Exit(1)
	}

	defer rows.Close()

	for rows.Next() {
		var user User

		if err := rows.Scan(&user.ID, &user.Name, &user.Password); err != nil {
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
