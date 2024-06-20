package models

import (
	"database/sql"
	"fmt"
	"os"
)

type Post struct {
	ID            int       `json:"id" query:"ID"`
	Title         string    `json:"title" query:"title"`
	Content       *string   `json:"-" query:"content"`
	Images        []*string `json:"-" query:"-"`
	Published     bool      `json:"published" query:"published"`
	CreatedAt     string    `json:"created-at" query:"createdAt"`
	AuthorID      int       `json:"author-id" query:"authorID"`
	CommentsCount int64     `json:"comments-count" query:"authorID"`
}

func (Post) Query(db *sql.DB, page int) ([]Post, error) {
	const itemsCount int = 4
	var offset int = page * itemsCount

	query := `SELECT * FROM post LIMIT ? OFFSET ?`
	return queryFactory(db, query, func(post *Post, rows *sql.Rows) error {
		if err := rows.Scan(&post.ID, &post.Title, &post.Published, &post.CreatedAt, &post.AuthorID, &post.Content); err != nil {
			return err
		}

		commentsCount, err := post.CountCommentsInPost(db, post.ID)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Failed")

			return err
		}

		post.CommentsCount = commentsCount
		return nil
	}, itemsCount, offset)
}

func (Post) CountCommentsInPost(db *sql.DB, postID int) (int64, error) {
	var count int64

	row := db.QueryRow(`SELECT COUNT(*) FROM comment WHERE postID=?`, postID)
	err := row.Scan(&count)

	if err != nil {
		fmt.Fprint(os.Stderr, "failed to count")
		return -1, err
	}

	return count, nil
}

func (post Post) Insert(db *sql.DB) (int64, error) {
	query := `INSERT INTO post VALUES (NULL, ?, ?, ?, ?)`
	return insertFactory(db, query, post.Title, post.Published, post.CreatedAt, post.AuthorID)
}

func (post Post) Delete(db *sql.DB) (int64, error) {
	return deleteFactory(db, `DELETE FROM post WHERE ID=?`, post.ID)
}
