package routes

import (
	"database/sql"
	"errors"
	"fmt"
	"net/http"
	"os"

	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/lib"
	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/models"
	"github.com/labstack/echo/v4"
)

func PublicationsRouter(db *sql.DB, e *echo.Echo) {
	e.GET("/feed/:page", getFeedRoute)
	e.GET("/post/comments/:postId", getPostCommentsRoute)
	e.GET("/post/likes/:id", getPostLikes)
	e.GET("/comment/likes/:id", getCommentLikes)

	e.POST("/comment/:id", postCommentRoute)
	e.POST("/post", postPostRoute)
	e.POST("/comment/like/:authorId/:postId", postCommentLike)
	e.POST("/post/like/:authorId/:postId", postPostLike)

	e.DELETE("/post/:id", deletePostRoute)
	e.DELETE("/like/:id", deleteLike)
}

func getFeedRoute(context echo.Context) error {
	page, err := getIntParam(context, "page")
	if err != nil {
		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid page parameter"})
	}

	posts, err := models.Post{}.Query(*internal_db, page)
	if err != nil {
		fmt.Fprintf(os.Stderr, "could not perform posts query: %v\n", err)
		return context.JSON(http.StatusInternalServerError, lib.ApiResponse{"message": "something went wrong"})
	}

	return context.JSON(http.StatusOK, lib.ApiResponse{"message": posts})
}

func postPostRoute(context echo.Context) error {
	post := new(models.Post)
	if err := bindJSONBody(context, post); err != nil {
		return context.JSON(http.StatusBadRequest, lib.ApiResponse{"message": "Invalid Request Body"})
	}

	id, err := post.Insert(*internal_db)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to add post into database: %v\n", err)
		return context.JSON(http.StatusInternalServerError, lib.JsonResponse{Message: "Failed to add post into database"})
	}

	return context.JSON(http.StatusCreated, lib.ApiResponse{"message": id})
}

func deletePostRoute(context echo.Context) error {
	id, err := getIntParam(context, "id")
	if err != nil {
		return context.JSON(http.StatusBadRequest, lib.ApiResponse{"message": "Invalid id"})
	}

	postsAffected, err := models.Post{ID: id}.Delete(*internal_db)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Could not delete post: %v\n", err)
		return context.JSON(http.StatusInternalServerError, lib.ApiResponse{"message": "Could not delete post"})
	}

	if postsAffected <= 0 {
		return context.JSON(http.StatusNotFound, lib.ApiResponse{"message": "nothing to delete"})
	}

	return context.NoContent(http.StatusNoContent)
}

func getPostCommentsRoute(context echo.Context) error {
	id, err := getIntParam(context, "postId")
	if err != nil {
		return context.JSON(http.StatusBadRequest, lib.ApiResponse{"message": "Invalid id"})
	}

	comments, err := models.Comment{}.Query(*internal_db, id, -1)
	if err != nil {
		fmt.Fprintf(os.Stderr, "could not perform comments query: %v\n", err)
		return context.JSON(http.StatusInternalServerError, lib.ApiResponse{"message": "something went wrong"})
	}

	if len(comments) <= 0 {
		return context.NoContent(http.StatusNoContent)
	}

	return context.JSON(http.StatusOK, lib.ApiResponse{"message": comments})
}

func postCommentRoute(context echo.Context) error {
	comment := new(models.Comment)
	if err := bindJSONBody(context, comment); err != nil {
		return context.JSON(http.StatusBadRequest, lib.ApiResponse{"message": "Invalid Request Body"})
	}

	id, err := comment.Insert(*internal_db)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to add comment into database: %v\n", err)
		return context.JSON(http.StatusInternalServerError, lib.JsonResponse{Message: "Failed to add comment into database"})
	}

	return context.JSON(http.StatusCreated, lib.ApiResponse{"message": id})
}

func postCommentLike(context echo.Context) error {
	// TODO - Implement logic for liking a comment
	return errors.New("not implemented")
}

func postPostLike(context echo.Context) error {
	authorID, err := getIntParam(context, "authorId")
	if err != nil {
		return context.JSON(http.StatusBadRequest, lib.ApiResponse{"message": "Invalid authorId"})
	}

	publicationID, err := getIntParam(context, "postId")
	if err != nil {
		return context.JSON(http.StatusBadRequest, lib.ApiResponse{"message": "Invalid publicationId"})
	}

	like := new(models.Like)
	if err := bindJSONBody(context, like); err != nil {
		return context.JSON(http.StatusBadRequest, lib.ApiResponse{"message": "Invalid Request Body"})
	}

	id, err := like.Insert(*internal_db)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to add like into database: %v\n", err)
		return context.JSON(http.StatusInternalServerError, lib.JsonResponse{Message: "Failed to add like into database"})
	}

	fmt.Println(authorID)
	fmt.Println(publicationID)

	return context.JSON(http.StatusOK, lib.ApiResponse{"message": id})
}

func deleteLike(context echo.Context) error {
	id, err := getIntParam(context, "id")
	if err != nil {
		return context.JSON(http.StatusBadRequest, lib.ApiResponse{"message": "Invalid Id"})
	}

	likesAffected, err := models.Like{ID: id}.Delete(*internal_db)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Could not delete like: %v\n", err)
		return context.JSON(http.StatusInternalServerError, lib.ApiResponse{"message": "Could not delete like"})
	}

	if likesAffected <= 0 {
		return context.JSON(http.StatusNotFound, lib.ApiResponse{"message": "nothing to delete"})
	}

	return context.NoContent(http.StatusNoContent)
}

func getPostLikes(context echo.Context) error {
	// TODO - Implement logic for getting post likes
	return errors.New("not implemented")
}

func getCommentLikes(context echo.Context) error {
	// TODO - Implement logic for getting comment likes
	return errors.New("not implemented")
}
