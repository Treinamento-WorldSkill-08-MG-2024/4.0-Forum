package routes

import (
	"database/sql"
	"errors"
	"fmt"
	"net/http"
	"strconv"

	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/lib"
	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/models"
	"github.com/labstack/echo/v4"
)

var internal_db *sql.DB

func AuthRouter(db *sql.DB, e *echo.Echo) {
	internal_db = db

	e.POST("/auth/login", loginRoute)
	e.POST("/auth/register", registerRoute)
	e.POST("/auth/forgot", forgotRoute)
}

func loginRoute(context echo.Context) error {
	user := new(models.User)
	if err := context.Bind(user); err != nil {
		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid request body"})
	}

	reqPassword := user.Password

	foundUser, err := user.QueryUserByName(internal_db, user.Name)
	if err != nil {
		return context.JSON(http.StatusInternalServerError, lib.JsonResponse{Message: "Failed to query user data"})
	}

	if !foundUser {
		return context.JSON(http.StatusNotFound, lib.JsonResponse{Message: "User not found"})
	}

	if user.Password != reqPassword {
		return context.JSON(http.StatusUnauthorized, lib.JsonResponse{Message: "Invalid password"})
	}

	// TODO - build token
	token := buildToken(strconv.Itoa(user.ID), "10/10/10")

	return context.JSON(http.StatusOK, lib.JsonResponse{Message: token})
}

func registerRoute(context echo.Context) error {
	user := new(models.User)
	if err := context.Bind(user); err != nil {
		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid request body"})
	}

	id, err := user.InsertNewUser(internal_db)
	if err != nil {
		return context.JSON(http.StatusInternalServerError, lib.JsonResponse{Message: "Failed to add user into database"})
	}

	return context.JSON(http.StatusCreated, lib.JsonResponse{Message: id})
}

func forgotRoute(context echo.Context) error {
	return errors.New("Not implemented")
}

/**
 * Authentication Proccess
 * - Store for each user a token with a certain validity that refers to a static user identifier data
 * - Send this token to the client and store it either in the local or session storage
 * - Now for each client call to the api that requires validation we internally check if both hashes matches
 *
 * The key and the iv should be the same both for the encryption and decryption
 * it might be good to write a script that for every n days, refresh both iv and passphrase values and write
 * them into a .env file so we can read in the server
 *
 * user_id = 4 bytes
 * exp_date = 25 bytes (REVIEW - could be smaller)
 * ?hash offset = 29 bytes
 * hash layout sha256(user_id + exp_date) maybe? (+ hash(password || email || unique_id))
 */
func buildToken(id string, exp_data string) string {
	// REVIEW - BASIC
	return fmt.Sprintf("%s:%s", id, exp_data)
}
