package models

import (
	"context"
	"database/sql"
	"fmt"
	"os"
)

type Model interface {
	Insert(db *sql.DB) (int64, error)
	Delete(db *sql.DB) (int64, error)
}

func queryFactory[M Model](
	db *sql.DB,
	query string,
	scan func(*M, *sql.Rows) error,
	args ...interface{},
) ([]M, error) {
	var models []M

	rows, err := db.Query(query, args...)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to execute query: %v\n", err)
		return nil, err
	}

	defer rows.Close()

	for rows.Next() {
		var model M
		if err := scan(&model, rows); err != nil {
			fmt.Fprintf(os.Stderr, "error scanning row: %s\n", err)

			return []M{}, nil
		}

		models = append(models, model)
	}

	if err := rows.Err(); err != nil {
		return []M{}, nil
	}

	return models, nil
}

func insertFactory(db *sql.DB, query string, args ...interface{}) (int64, error) {
	insertResult, err := db.ExecContext(context.Background(), query, args...)
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

func deleteFactory(db *sql.DB, query string, id int) (int64, error) {
	queryResult, err := db.ExecContext(context.Background(), query, id)
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
