package models

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"os"

	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/lib"
)

type User struct {
	ID       int     `json:"id" query:"ID"`
	Name     string  `json:"name" query:"name"`
	Email    string  `json:"email" query:"email"`
	Password string  `json:"password" query:"password"`
	TempCode *string `json:"temp-code" query:"tempCode"`
}

func (User) Query(db *sql.DB) ([]User, error) {
	return queryFactory(db, "SELECT * FROM users", func(user *User, rows *sql.Rows) error {
		return rows.Scan(&user.ID, &user.Name, &user.Password, &user.Email, &user.TempCode)
	})
}

func (user *User) QueryUserByName(db *sql.DB, name string) (bool, error) {
	users, err := queryFactory(db, "SELECT * FROM users WHERE name=?", func(_ *User, r *sql.Rows) error {
		return r.Scan(&user.ID, &user.Name, &user.Password, &user.Email, &user.TempCode)
	}, name)

	if err != nil {
		return false, nil
	}

	if len(users) > 1 {
		return true, errors.New("more than one user found when it should be only one")
	}

	return true, nil
}

func (user *User) QueryUserByEmail(db *sql.DB, email string) (bool, error) {
	users, err := queryFactory(db, "SELECT * FROM users WHERE email=?", func(_ *User, r *sql.Rows) error {
		return r.Scan(&user.ID, &user.Name, &user.Password, &user.Email, &user.TempCode)
	}, email)

	if err != nil {
		return false, nil
	}

	if len(users) > 1 {
		return true, errors.New("more than one user found when it should be only one")
	}

	return true, nil
}

func (user *User) QueryUserByID(db *sql.DB, id int) (bool, error) {
	users, err := queryFactory(db, "SELECT * FROM users WHERE ID=?", func(_ *User, r *sql.Rows) error {
		return r.Scan(&user.ID, &user.Name, &user.Password, &user.Email, &user.TempCode)
	}, id)

	if err != nil {
		return false, nil
	}

	if len(users) > 1 {
		return true, errors.New("more than one user found when it should be only one")
	}

	return true, nil
}

func (user User) UpdateTempCode(db *sql.DB) (int64, error) {
	tempCode := lib.SafeDerefComparable(user.TempCode)
	if tempCode == nil {
		return -1, errors.New("temp code cannot be nil")
	}

	query := `UPDATE users SET tempCode=? WHERE id=?`
	updateResult, err := db.ExecContext(context.Background(), query, tempCode, user.ID)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to insert user: %s\n", err)

		return -1, err
	}

	id, err := updateResult.RowsAffected()
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to retrieve last inserted id: %s\n", err)

		return -1, err
	}

	return id, err
}

func (user User) UpdatePassword(db *sql.DB) (int64, error) {
	query := "UPDATE users SET `password`=? WHERE id=?"
	updateResult, err := db.ExecContext(context.Background(), query, user.Password, user.ID)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to insert user: %s\n", err)

		return -1, err
	}

	id, err := updateResult.RowsAffected()
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to retrieve last inserted id: %s\n", err)

		return -1, err
	}

	return id, err
}

func (user User) Insert(db *sql.DB) (int64, error) {
	return insertFactory(db, `INSERT INTO users VALUES (NULL, ?, ?, ?, ?)`, user.Name, user.Password, user.Email, nil)
}

func (user User) Delete(db *sql.DB) (int64, error) {
	return deleteFactory(db, `DELETE FROM users WHERE ID=?`, user.ID)
}
