package api

import (
	"database/sql"
	"net/http"

	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/api/routes"
	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/lib"
	"github.com/labstack/echo/v4"
)

func InitAPI(db *sql.DB) {
	e := echo.New()
	e.GET("/helloworld", func(context echo.Context) error {
		return context.JSON(http.StatusOK, lib.JsonResponse{Message: "hello world"})
	})

	routes.UsersRouter(db, e)
	routes.AuthRouter(db, e)
	routes.PublicationsRouter(db, e)

	e.Logger.Fatal(e.Start(":1323"))
}
