package models

import (
	"database/sql"
	"errors"
)

type User struct {
	ID       int    `json:"id" query:"ID"`
	Name     string `json:"name" query:"name"`
	Email    string `json:"email" query:"email"`
	Password string `json:"password" query:"password"`
}

func (User) Query(db *sql.DB) ([]User, error) {
	return queryFactory(db, "SELECT * FROM users", func(user *User, rows *sql.Rows) error {
		return rows.Scan(&user.ID, &user.Name, &user.Password, &user.Email)
	})
}

func (user *User) QueryUserByName(db *sql.DB, name string) (bool, error) {
	users, err := queryFactory(db, "SELECT * FROM users WHERE name=?", func(_ *User, r *sql.Rows) error {
		return r.Scan(&user.ID, &user.Name, &user.Password, &user.Email)
	}, name)

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
		return r.Scan(&user.ID, &user.Name, &user.Password, &user.Email)
	}, id)

	if err != nil {
		return false, nil
	}

	if len(users) > 1 {
		return true, errors.New("more than one user found when it should be only one")
	}

	return true, nil
}

func (user User) Insert(db *sql.DB) (int64, error) {
	return insertFactory(db, `INSERT INTO users VALUES (NULL, ?, ?, ?)`, user.Name, user.Password, user.Email)
}

func (user User) Delete(db *sql.DB) (int64, error) {
	return deleteFactory(db, `DELETE FROM users WHERE ID=?`, user.ID)
}
