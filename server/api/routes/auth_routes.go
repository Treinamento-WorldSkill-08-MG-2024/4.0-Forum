package routes

import (
	"database/sql"
	"errors"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/lib"
	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/lib/crypt"
	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/models"
	"github.com/gofor-little/env"
	"github.com/labstack/echo/v4"
)

var (
	internal_db *sql.DB
	key         string
)

func AuthRouter(db *sql.DB, e *echo.Echo) {
	internal_db = db

	key = env.Get("AUTH_KEY", "-1")
	if strings.Compare(key, "-1") == 0 {
		fmt.Fprintf(os.Stderr, "failed to load authentication key\n")
		os.Exit(1)
	}

	e.POST("/auth/login", loginRoute)
	e.POST("/auth/register", registerRoute)
	e.POST("/auth/forgot", forgotRoute)
}

func loginRoute(context echo.Context) error {
	user := new(models.User)
	if err := context.Bind(user); err != nil {
		fmt.Fprintf(os.Stderr, "Failed to bind user (login route): %d\n", err)

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

	token, err := buildToken(strconv.Itoa(user.ID))
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to build token: %s\n", err)

		return context.JSON(http.StatusInternalServerError, lib.JsonResponse{Message: "Failed to build token"})
	}

	return context.JSON(http.StatusOK, lib.JsonResponse{
		Message: map[string]interface{}{"user": user, "token": token},
	})
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
	return errors.New("not implemented")
}

const (
	userIdBytesLength  uint8 = 4
	expDateBytesLength uint8 = 20
)

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
 * exp_date = 20 bytes (REVIEW - could be smaller)
 * ?hash offset = 24 bytes
 * hash layout sha256(user_id + exp_date) maybe? (+ hash(password || email || unique_id))
 */
func buildToken(id string) (string, error) {
	if uint8(len(id)) > userIdBytesLength {
		return "", fmt.Errorf("user id should not be greater than %d bytes in length", userIdBytesLength)
	}

	formatedId := fmt.Sprintf("%0*s", userIdBytesLength, id)

	now := time.Now()
	yyyy, mm, dd := now.Date()

	expOffsetTime := time.Date(yyyy, mm, dd+1, 15, 0, 0, 0, now.Location())
	expOffset := expOffsetTime.String()[:20]
	if uint8(len(expOffset)) > expDateBytesLength {
		fmt.Println(expOffsetTime.String())

		return "", fmt.Errorf("users expiration offset should not be greater than %d bytes in length", userIdBytesLength)
	}

	token := formatedId + expOffset
	return crypt.Encrypt_AES(token, key)
}
