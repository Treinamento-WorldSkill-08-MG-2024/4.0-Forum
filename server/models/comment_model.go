package models

import (
	"database/sql"
	"fmt"
	"os"

	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/lib"
)

type Comment struct {
	ID            int    `json:"id" query:"ID"`
	Content       string `json:"content" query:"content"`
	Published     bool   `json:"published" query:"publication"`
	AuthorID      int    `json:"author-id" query:"authorID"`
	CreatedAt     string `json:"-" query:"createdAt"`
	PostID        *int   `json:"post-id" query:"postID"`
	CommentID     *int   `json:"comment-id" query:"commentID"`
	LikesCount    int64  `json:"likes-count"`
	CommentsCount int64  `json:"comments-count"`
}

func (comment Comment) Query(db *sql.DB, page int) ([]Comment, error) {
	postID := lib.SafeDerefComparable(comment.PostID)
	commentID := lib.SafeDerefComparable(comment.CommentID)

	query := `SELECT * FROM comment WHERE (postID=? AND commentID IS NULL) OR (postID IS NULL AND commentID=?)`
	return queryFactory(db, query, func(c *Comment, rows *sql.Rows) error {
		if err := rows.Scan(&c.ID, &c.Content, &c.Published, &c.CreatedAt, &c.AuthorID, &c.PostID, &c.CommentID); err != nil {
			fmt.Fprintf(os.Stderr, "Failed scann: %s\n", err)
			return err
		}

		likesCount, err := c.countLikes(db)
		if err != nil {
			fmt.Fprintf(os.Stderr, "failed o count likes in comment")

			return err
		}

		c.LikesCount = likesCount
		fmt.Println(c)
		return nil
	}, postID, commentID)
}

func (comment Comment) Insert(db *sql.DB) (int64, error) {
	query := `INSERT INTO comment VALUES (NULL, ?, ?, ?, ?, ?, ?)`
	return insertFactory(db, query, comment.Content, comment.Published, "", comment.AuthorID, comment.PostID, comment.CommentID)
}

func (comment Comment) Delete(db *sql.DB) (int64, error) {
	return deleteFactory(db, `DELETE FROM comment WHERE ID=?`, comment.ID)
}

func (comment Comment) countLikes(db *sql.DB) (int64, error) {
	var count int64
	row := db.QueryRow("SELECT COUNT(*) FROM `like` WHERE commentID=?", comment.ID)

	err := row.Scan(&count)
	if err != nil {
		fmt.Fprint(os.Stderr, "failed to count")
		return -1, err
	}

	return count, nil
}

func (comment Comment) IsLiked(db *sql.DB, authorID int) (int64, error) {
	var id *int64
	row, err := db.Query("SELECT `ID` FROM `like` WHERE commentID=? AND userID=?", comment.ID, authorID)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to query id from like %s\n", err)

		return -1, err
	}

	if err := row.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "failed to check if comment is liked %s\n", err)

		return -1, nil
	}

	if row.Next() {
		err := row.Scan(&id)
		if err != nil {
			fmt.Fprintf(os.Stderr, "failed to check if comment is liked %s\n", err)
			return -1, err
		}
	}

	if id == nil {
		return -1, nil
	}

	return *id, nil
}
