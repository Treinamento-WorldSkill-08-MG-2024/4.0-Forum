package models

import (
	"context"
	"database/sql"
	"fmt"
	"os"
)

type Post struct {
	ID        int       `json:"id" query:"ID"`
	Title     string    `json:"title" query:"title"`
	Content   *string   `json:"-" query:"content"`
	Images    []*string `json:"-" query:"-"`
	Published bool      `json:"published" query:"published"`
	CreatedAt string    `json:"created-at" query:"createdAt"`
	AuthorID  int       `json:"author-id" query:"authorID"`
}

func QueryPosts(db *sql.DB, page int) ([]Post, error) {
	var posts []Post

	const itemsCount int = 4
	var offset int = page * itemsCount

	query := fmt.Sprintf(`SELECT * FROM post LIMIT %d OFFSET %d`, itemsCount, offset)
	rows, err := db.Query(query)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to execute query: %v\n", err)
		return nil, err
	}

	defer rows.Close()

	for rows.Next() {
		var post Post
		if err := rows.Scan(
			&post.ID, &post.Title, &post.Published,
			&post.CreatedAt, &post.AuthorID, &post.Content,
		); err != nil {
			fmt.Fprintf(os.Stderr, "error scanning row: %s\n", err)

			return []Post{}, nil
		}

		posts = append(posts, post)
	}

	if err := rows.Err(); err != nil {
		return []Post{}, nil
	}

	return posts, nil
}

func (post Post) InsertPost(db *sql.DB) (int64, error) {
	query := `INSERT INTO post VALUES (NULL, ?, ?, ?, ?)`

	insertResult, err := db.ExecContext(context.Background(), query, post.Title, post.Published, post.CreatedAt, post.AuthorID)
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

func DeletePost(db *sql.DB, id int) (int64, error) {
	queryResult, err := db.ExecContext(context.Background(), `DELETE FROM post WHERE ID=?`, id)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to delete user: %s\n", err)

		return -1, err
	}

	rowsAffected, err := queryResult.RowsAffected()
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to retrieve rows affected by deletion: %s\n", err)

		return -1, err
	}

	return rowsAffected, nil
}
