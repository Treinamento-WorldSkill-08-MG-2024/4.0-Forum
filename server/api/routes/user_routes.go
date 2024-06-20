package routes

import (
	"database/sql"
	"fmt"
	"net/http"
	"os"
	"strconv"

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

	e.GET("/user/:id", func(context echo.Context) error {
		id, err := strconv.Atoi(context.Param("id"))
		if err != nil {
			return context.JSON(http.StatusBadRequest, lib.ApiResponse{"message": "Invalid ID"})
		}

		var user models.User
		found, err := user.QueryUserByID(*internal_db, id)
		if err != nil {
			fmt.Fprintf(os.Stderr, "could'nt perform QueryUserByID query")

			return context.JSON(http.StatusInternalServerError, lib.ApiResponse{"message": "something went wrong"})
		}

		if !found {
			return context.JSON(http.StatusNotFound, lib.ApiResponse{"message": "user not found"})
		}

		return context.JSON(http.StatusOK, lib.ApiResponse{"message": user})
	})
}
