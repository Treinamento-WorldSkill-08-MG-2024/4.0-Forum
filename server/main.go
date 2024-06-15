package main

import (
	"fmt"

	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/api"
	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/database"
	"github.com/gofor-little/env"

	_ "github.com/tursodatabase/libsql-client-go/libsql"
)

func main() {
	if err := env.Load(".env"); err != nil {
		panic("failed to load environment file")
	}

	db := database.InitDatabase()
	defer db.Close()

	api.InitAPI(db)

	fmt.Println("Database is ready to go")
}
