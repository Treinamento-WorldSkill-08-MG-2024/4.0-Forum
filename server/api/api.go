package api

import (
	"database/sql"
	"net/http"

	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/models"
	"github.com/labstack/echo/v4"
)

type JsonResponse struct {
	Message interface{} `json:"message"`
}

func usersRoutes(db *sql.DB, e *echo.Echo) {
	e.GET("/users", func(context echo.Context) error {
		users, err := models.QueryUsers(db)
		if err != nil {
			return context.JSON(http.StatusInternalServerError, JsonResponse{Message: "failed to get users from database"})
		}

		if err := context.Bind(users); err != nil {
			return context.JSON(http.StatusInternalServerError, JsonResponse{Message: "failed to bind users data"})
		}

		return context.JSON(http.StatusOK, JsonResponse{Message: users})
	})
}

func InitAPI(db *sql.DB) {
	e := echo.New()
	e.GET("/helloworld", func(context echo.Context) error {

		return context.JSON(http.StatusOK, JsonResponse{Message: "hello world"})
	})

	usersRoutes(db, e)

	e.Logger.Fatal(e.Start(":1323"))
}
