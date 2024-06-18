package main

import (
	"database/sql"
	"flag"
	"fmt"
	"time"

	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/database"
	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/models"
	"github.com/gofor-little/env"

	_ "github.com/tursodatabase/libsql-client-go/libsql"
)

func main() {
	if err := env.Load(".env"); err != nil {
		panic("failed to load environment file")
	}

	db := database.InitDatabase()
	fmt.Println("(cli) Database instatiated")

	defer db.Close()

	// FIXME - Not working properly
	isPublication := flag.Bool("publication", false, "seed placeholder publications into database")
	if *isPublication {
		seedPublications(db)

		return
	}
	flag.Parse()
	fmt.Println("\nUsage:\npublication\tseed placeholder publications into database")
}

func seedPublications(db *sql.DB) {
	var posts []models.Post = []models.Post{
		{Title: "Post 1", Published: true, CreatedAt: time.DateTime, AuthorID: 1},
		{Title: "Post 2", Published: false, CreatedAt: time.DateTime, AuthorID: 2},
		{Title: "Post 3", Published: true, CreatedAt: time.DateTime, AuthorID: 3},
		{Title: "Post 4", Published: true, CreatedAt: time.DateTime, AuthorID: 3},
		{Title: "Post 5", Published: true, CreatedAt: time.DateTime, AuthorID: 1},
		{Title: "Post 6", Published: true, CreatedAt: time.DateTime, AuthorID: 1},
		{Title: "Post 7", Published: false, CreatedAt: time.DateTime, AuthorID: 2},
		{Title: "Post 8", Published: true, CreatedAt: time.DateTime, AuthorID: 3},
		{Title: "Post 9", Published: true, CreatedAt: time.DateTime, AuthorID: 2},
		{Title: "Post 10", Published: true, CreatedAt: time.DateTime, AuthorID: 2},
	}

	for _, post := range posts {
		post.InsertPost(db)
	}
}
