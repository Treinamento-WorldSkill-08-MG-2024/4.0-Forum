package models

import (
	"context"
	"database/sql"
	"fmt"
	"os"
)

type User struct {
	ID       int    `json:"-" query:"id"`
	Name     string `json:"name" query:"name"`
	Email    string `json:"email" query:"email"`
	Password string `json:"password" query:"password"`
}

func (user *User) QueryUserByName(db *sql.DB, name string) (bool, error) {
	rows, err := db.Query("SELECT * FROM users WHERE name=?", name)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to query user by name: %s\n", err)

		return false, err
	}

	defer rows.Close()

	if rows.Next() {
		if err := rows.Scan(&user.ID, &user.Name, &user.Password, &user.Email); err != nil {
			fmt.Fprintf(os.Stderr, "Error scanning row: %s\n", err)

			return false, err
		}

		return true, nil
	}

	return false, nil
}

func (user User) InsertNewUser(db *sql.DB) (int64, error) {
	insertResult, err := db.ExecContext(context.Background(), `INSERT INTO users VALUES (NULL, ?, ?, ?)`, user.Name, user.Password, user.Email)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to insert user: %s\n", err)

		return -1, err
	}

	id, err := insertResult.LastInsertId()
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to retrieve last inserted id: %s\n", err)

		return -1, err
	}

	return id, err
}

func QueryUsers(db *sql.DB) ([]User, error) {
	var users []User

	rows, err := db.Query("SELECT * FROM users")
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to execue query: %v\n", err)
		return nil, err
	}

	defer rows.Close()

	for rows.Next() {
		var user User

		if err := rows.Scan(&user.ID, &user.Name, &user.Password, &user.Email); err != nil {
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
