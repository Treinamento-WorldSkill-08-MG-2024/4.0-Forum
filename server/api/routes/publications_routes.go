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

func PublicationsRouter(db *sql.DB, e *echo.Echo) {
	internal_db = &db

	e.GET("/feed/:page", feedRoute)
	e.POST("/post", postRoute)
}

func feedRoute(context echo.Context) error {
	page, err := strconv.Atoi(context.Param("page"))
	if err != nil || page <= 0 {
		fmt.Fprintf(os.Stderr, "invalid page parameter: %s\n", err)

		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid page parameter"})
	}

	posts, err := models.QueryPosts(*internal_db, page)
	if err != nil {
		fmt.Fprintf(os.Stderr, "could'nt perform posts query")

		return context.JSON(http.StatusInternalServerError, lib.ApiResponse{"message": "something went wrong"})
	}

	return context.JSON(http.StatusOK, lib.ApiResponse{"message": posts})
}

func postRoute(context echo.Context) error {
	post := new(models.Post)
	if err := context.Bind(post); err != nil {
		fmt.Fprintf(os.Stderr, "Failed to bind user (post route): %d\n", err)

		return context.JSON(http.StatusBadRequest, lib.ApiResponse{"message": "Invalid Request Body"})
	}

	id, err := post.InsertPost(*internal_db)
	if err != nil {
		return context.JSON(http.StatusInternalServerError, lib.JsonResponse{Message: "Failed to add post into database"})
	}

	return context.JSON(http.StatusCreated, lib.ApiResponse{"message": id})
}
