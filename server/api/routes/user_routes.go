package routes

import (
	"database/sql"
	"net/http"

	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/lib"
	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/models"
	"github.com/labstack/echo/v4"
)

func UsersRouter(db *sql.DB, e *echo.Echo) {
	e.GET("/users", func(context echo.Context) error {
		users, err := models.QueryUsers(db)
		if err != nil {
			return context.JSON(http.StatusInternalServerError, lib.JsonResponse{Message: "failed to get users from database"})
		}

		if err := context.Bind(users); err != nil {
			return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "failed to bind users data"})
		}

		return context.JSON(http.StatusOK, lib.JsonResponse{Message: users})
	})
}
