package models

import (
	"database/sql"
	"fmt"
	"os"
)

type Post struct {
	ID            int      `json:"id" query:"ID"`
	Title         string   `json:"title" query:"title"`
	Images        []string `json:"images" query:"-"`
	Published     bool     `json:"published" query:"published"`
	CreatedAt     string   `json:"created-at" query:"createdAt"`
	Content       string   `json:"content" query:"content"`
	AuthorID      int      `json:"author-id" query:"authorID"`
	CommentsCount int64    `json:"comments-count"`
	LikesCount    int64    `json:"likes-count"`
}

func (Post) Query(db *sql.DB, page int) ([]Post, error) {
	const itemsCount int = 4
	var offset int = page * itemsCount

	query := `SELECT * FROM post ORDER BY ID DESC LIMIT ? OFFSET ?`
	return queryFactory(db, query, func(p *Post, rows *sql.Rows) error {
		if err := rows.Scan(&p.ID, &p.Title, &p.Published, &p.CreatedAt, &p.AuthorID, &p.Content); err != nil {
			return err
		}

		err := p.queryImages(db)
		if err != nil {
			fmt.Fprintf(os.Stderr, "failed to query iamges")

			return err
		}

		commentsCount, err := p.countComments(db)
		if err != nil {
			fmt.Fprintf(os.Stderr, "failed to count comments in post")

			return err
		}

		likesCount, err := p.countLikes(db)
		if err != nil {
			fmt.Fprintf(os.Stderr, "failed to count comments in post")

			return err
		}

		p.CommentsCount = commentsCount
		p.LikesCount = likesCount

		return nil
	}, itemsCount, offset)
}

func (post Post) IsLiked(db *sql.DB, authorID int) (int64, error) {
	var id *int64
	row, err := db.Query("SELECT `ID` FROM `like` WHERE postID=? AND userID=?", post.ID, authorID)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to query id from like %s\n", err)

		return -1, err
	}

	if err := row.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "failed to check if post is liked %s\n", err)

		return -1, nil
	}

	if row.Next() {
		err := row.Scan(&id)
		if err != nil {
			fmt.Fprintf(os.Stderr, "failed to check if post is liked %s\n", err)
			return -1, err
		}
	}

	if id == nil {
		return -1, nil
	}

	return *id, nil
}

func (post Post) Insert(db *sql.DB) (int64, error) {
	query := `INSERT INTO post VALUES (NULL, ?, ?, ?, ?, ?)`
	newPostId, err := insertFactory(db, query, post.Title, post.Published, post.CreatedAt, post.AuthorID, post.Content)
	if err != nil {
		return newPostId, err
	}

	if len(post.Images) <= 0 {
		return newPostId, nil
	}

	queryArgs := make([]interface{}, 0, len(post.Images)*2)

	imageQuery := `INSERT INTO images VALUES`
	for i, v := range post.Images {
		queryArgs = append(queryArgs, newPostId, v)

		if i >= len(post.Images)-1 {
			imageQuery += "(NULL, ?, ?);"
			break
		}
		imageQuery += "(NULL, ?, ?),"
	}

	_, err = insertFactory(db, imageQuery, queryArgs...)
	if err != nil {
		return newPostId, err
	}

	return newPostId, nil
}

func (post Post) Delete(db *sql.DB) (int64, error) {
	return deleteFactory(db, `DELETE FROM post WHERE ID=?`, post.ID)
}

func (post Post) countLikes(db *sql.DB) (int64, error) {
	var count int64
	row := db.QueryRow("SELECT COUNT(*) FROM `like` WHERE postID=?", post.ID)

	err := row.Scan(&count)
	if err != nil {
		fmt.Fprint(os.Stderr, "failed to count")
		return -1, err
	}

	return count, nil
}

func (post Post) countComments(db *sql.DB) (int64, error) {
	var count int64

	row := db.QueryRow(`SELECT COUNT(*) FROM comment WHERE postID=?`, post.ID)
	err := row.Scan(&count)

	if err != nil {
		fmt.Fprint(os.Stderr, "failed to count")
		return -1, err
	}

	return count, nil
}

func (post *Post) queryImages(db *sql.DB) error {
	query := `SELECT uri FROM images WHERE postID=?`
	rows, err := db.Query(query, post.ID)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to execute query: %v\n", err)
		return err
	}

	defer rows.Close()

	for rows.Next() {
		var uri string
		if err := rows.Scan(&uri); err != nil {
			fmt.Fprintf(os.Stderr, "error scanning row: %s\n", err)

			return err
		}

		post.Images = append(post.Images, uri)
	}

	if err := rows.Err(); err != nil {
		return err
	}

	return nil
}
