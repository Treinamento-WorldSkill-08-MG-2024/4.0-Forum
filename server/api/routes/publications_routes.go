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
	e.GET("/post/comment/:postId", getPostCommentsRoute)
	e.GET("/post/likes/:id", getPostLikes)
	e.GET("/comment/likes/:id", getCommentLikes)

	e.POST("/comment/:id", postCommentRoute)
	e.POST("/post", getPostRoute)
	e.POST("/like/:authorId/:publicationId", postLike)

	e.DELETE("/post/:id", deletePostRoute)
	e.DELETE("/like/:id", deleteLike)
}

func feedRoute(context echo.Context) error {
	page, err := strconv.Atoi(context.Param("page"))
	if err != nil {
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

func getPostRoute(context echo.Context) error {
	post := new(models.Post)
	if err := context.Bind(post); err != nil {
		fmt.Fprintf(os.Stderr, "Failed to bind user (post route): %d\n", err)

		return context.JSON(http.StatusBadRequest, lib.ApiResponse{"message": "Invalid Request Body"})
	}

	id, err := post.InsertPost(*internal_db)
	if err != nil {
		fmt.Fprintf(os.Stderr, "")

		return context.JSON(http.StatusInternalServerError, lib.JsonResponse{Message: "Failed to add post into database"})
	}

	return context.JSON(http.StatusCreated, lib.ApiResponse{"message": id})
}

func deletePostRoute(context echo.Context) error {
	id, err := strconv.Atoi(context.Param("id"))
	if err != nil {
		return context.JSON(http.StatusBadRequest, lib.ApiResponse{"message": "Invalid id"})
	}

	postsAffected, err := models.DeletePost(*internal_db, id)
	if err != nil {
		return context.JSON(http.StatusInternalServerError, lib.ApiResponse{"message": "Could not delete post"})
	}

	if postsAffected <= 0 {
		return context.JSON(http.StatusNotFound, lib.ApiResponse{"message": "nothin to delete"})
	}

	return context.NoContent(http.StatusNoContent)
}

func getPostCommentsRoute(context echo.Context) error {
	// TODO -
	return nil
}

func postCommentRoute(context echo.Context) error {
	// TODO -
	return nil
}

func postLike(context echo.Context) error
func deleteLike(context echo.Context) error
func getPostLikes(context echo.Context) error
func getCommentLikes(context echo.Context) error
