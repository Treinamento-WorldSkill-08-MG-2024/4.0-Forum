package models

import (
	"database/sql"
)

type Comment struct {
	ID        int    `json:"id" query:"ID"`
	Content   string `json:"content" query:"content"`
	Published bool   `json:"published" query:"publication"`
	AuthorID  int    `json:"author-id" query:"authorID"`
	CreatedAt string `json:"-" query:"createdAt"`
	PostID    *int   `json:"post-id" query:"postID"`
	CommentID *int   `json:"-" query:"-"`
}

func (Comment) Query(db *sql.DB, postID int, page int) ([]Comment, error) {
	query := `SELECT * FROM comment WHERE postID=?`
	return queryFactory(db, query, func(c *Comment, rows *sql.Rows) error {
		return rows.Scan(&c.ID, &c.Content, &c.Published, &c.CreatedAt, &c.AuthorID, &c.PostID, &c.CommentID)
	}, postID)
}

func (comment Comment) Insert(db *sql.DB) (int64, error) {
	query := `INSERT INTO comment VALUES (NULL, ?, ?, ?, ?, NULL)`
	return insertFactory(db, query, comment.Content, comment.Published, comment.AuthorID, comment.PostID)
}

func (comment Comment) Delete(db *sql.DB) (int64, error) {
	return deleteFactory(db, `DELETE FROM comment WHERE ID=?`, comment.ID)
}
