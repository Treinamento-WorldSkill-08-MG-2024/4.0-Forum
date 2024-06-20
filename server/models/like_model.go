package models

import (
	"database/sql"
)

type Like struct {
	ID        int  `json:"id" query:"ID"`
	UserID    int  `json:"user-id" query:"userID"`
	PostID    *int `json:"post-id" query:"postID"`
	CommentID *int `json:"-" query:"-"`
}

func (like Like) Insert(db *sql.DB) (int64, error) {
	query := "INSERT INTO `like` VALUES (NULL, ?, ?, ?)"
	return insertFactory(db, query, like.UserID, like.PostID, like.CommentID)
}

func (like Like) Delete(db *sql.DB) (int64, error) {
	return deleteFactory(db, "DELETE FROM `like` WHERE ID=?", like.ID)
}
