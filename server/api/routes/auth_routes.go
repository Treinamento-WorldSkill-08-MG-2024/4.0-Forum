package routes

import (
	"database/sql"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/lib"
	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/lib/crypt"
	"github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/models"
	mailer "github.com/Treinamento-WorldSkill-08-MG-2024/ArchForum/server/smtp"
	"github.com/gofor-little/env"
	"github.com/labstack/echo/v4"
)

const (
	userIdBytesLength           uint8 = 4
	expDateBytesLength          uint8 = 20
	recuperationCodeBytesLength uint8 = 5
)

var key string

func AuthRouter(db *sql.DB, e *echo.Echo) {
	internal_db = &db

	key = env.Get("AUTH_KEY", "-1")
	if strings.Compare(key, "-1") == 0 {
		fmt.Fprintf(os.Stderr, "failed to load authentication key\n")
		os.Exit(1)
	}

	e.POST("/auth", authenticateRoute)
	e.POST("/auth/login", loginRoute)
	e.POST("/auth/register", registerRoute)
	e.POST("/auth/forgot", forgotRoute)
	e.POST("/auth/validate", validateRoute)
	e.POST("auth/changePassword", changePasswordRoute)
}

func loginRoute(context echo.Context) error {
	user := new(models.User)
	if err := context.Bind(user); err != nil {
		fmt.Fprintf(os.Stderr, "Failed to bind user (login route): %d\n", err)

		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid request body"})
	}

	reqPassword := user.Password

	foundUser, err := user.QueryUserByEmail(*internal_db, user.Email)
	if err != nil {
		return context.JSON(http.StatusInternalServerError, lib.JsonResponse{Message: "Failed to query user data"})
	}

	if !foundUser {
		return context.JSON(http.StatusNotFound, lib.JsonResponse{Message: "User not found"})
	}
	fmt.Println(foundUser)

	if user.Password != reqPassword {
		return context.JSON(http.StatusUnauthorized, lib.JsonResponse{Message: "Invalid password"})
	}

	token, err := buildAuthToken(strconv.Itoa(user.ID))
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

	foundUser, err := user.QueryUserByEmail(*internal_db, user.Email)
	if err != nil {
		return context.JSON(http.StatusInternalServerError, lib.JsonResponse{Message: "Failed to query user data"})
	}

	if foundUser {
		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "User already exists"})
	}

	id, err := user.Insert(*internal_db)
	if err != nil {
		return context.JSON(http.StatusInternalServerError, lib.JsonResponse{Message: "Failed to add user into database"})
	}

	return context.JSON(http.StatusCreated, lib.JsonResponse{Message: id})
}

func forgotRoute(context echo.Context) error {
	user := new(models.User)
	if err := context.Bind(user); err != nil {
		fmt.Fprintf(os.Stderr, "failed to bind user data %s\n", err)

		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid request body"})
	}

	foundUser, err := user.QueryUserByEmail(*internal_db, user.Email)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%s", err)
		return context.JSON(http.StatusInternalServerError, lib.JsonResponse{Message: "Failed to query user data"})
	}

	if !foundUser {
		return context.JSON(http.StatusNotFound, lib.JsonResponse{Message: "User not found"})
	}

	token, err := buildRecuperationToken()
	if err != nil {
		return context.JSON(http.StatusInternalServerError, lib.JsonResponse{Message: "Failed to generate recuperation code"})
	}

	user.TempCode = &token
	result, err := user.UpdateTempCode(*internal_db)
	if err != nil || result <= 0 {
		return context.JSON(http.StatusInternalServerError, lib.ApiResponse{"message": "Failed to update user"})
	}

	randomCode := token[:recuperationCodeBytesLength]

	email := new(mailer.Email)
	email.
		SetBody(fmt.Sprintf("<html><head><title>Seu código de recuperação:</title></head><body><strong>%s</strong></body>", randomCode)).
		SetTo(user.Email).
		SetSubject("Recuperação de senha")

	if err := email.Mail(); err != nil {
		fmt.Fprintf(os.Stderr, "%s", err)

		return context.JSON(http.StatusInternalServerError, lib.ApiResponse{"message": "Failed to send email:"})
	}

	return context.JSON(http.StatusOK, lib.JsonResponse{Message: user.ID})
}

func changePasswordRoute(context echo.Context) error {
	user := new(models.User)
	if err := context.Bind(user); err != nil {
		fmt.Fprintf(os.Stderr, "failed to bind user data %s\n", err)

		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid request body"})
	}

	if user.TempCode == nil {
		fmt.Fprintf(os.Stderr, "failed to bind user data\n")

		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid request body"})
	}

	expectedTempCode := (*user.TempCode)[:recuperationCodeBytesLength]
	reqPassword := user.Password

	foundUser, err := user.QueryUserByID(*internal_db, user.ID)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%s", err)
		return context.JSON(http.StatusInternalServerError, lib.JsonResponse{Message: "Failed to query user data"})
	}

	if !foundUser {
		return context.JSON(http.StatusNotFound, lib.JsonResponse{Message: "User not found"})
	}

	if expectedTempCode != (*user.TempCode)[:recuperationCodeBytesLength] {
		fmt.Println(expectedTempCode, (*user.TempCode)[:recuperationCodeBytesLength])
		return context.JSON(http.StatusUnauthorized, lib.JsonResponse{Message: "Invalid token"})
	}

	stringExpDate := (*user.TempCode)[recuperationCodeBytesLength : expDateBytesLength+recuperationCodeBytesLength-1]

	expDate, err := time.Parse(time.DateTime, stringExpDate)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to read expiration data %s\n", err)

		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid request body"})
	}

	nowFormatted, err := time.Parse(time.DateTime, time.Now().Format(time.DateTime))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to read expiration data %s\n", err)

		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid request body"})
	}

	if nowFormatted.After(expDate) {
		return context.JSON(http.StatusUnauthorized, lib.JsonResponse{Message: "Token Expired"})
	}

	user.Password = reqPassword
	result, err := user.UpdatePassword(*internal_db)
	if err != nil || result <= 0 {
		fmt.Fprintf(os.Stderr, "%s", err)

		return context.JSON(http.StatusInternalServerError, lib.ApiResponse{"Message": "failed to update password"})
	}

	return context.NoContent(http.StatusOK)
}

func validateRoute(context echo.Context) error {
	user := new(models.User)
	if err := context.Bind(user); err != nil {
		fmt.Fprintf(os.Stderr, "failed to bind user data %s\n", err)

		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid request body"})
	}

	if user.TempCode == nil {
		fmt.Fprintf(os.Stderr, "failed to bind user data\n")

		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid request body"})
	}

	expectedTempCode := (*user.TempCode)[:recuperationCodeBytesLength]

	foundUser, err := user.QueryUserByID(*internal_db, user.ID)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%s", err)
		return context.JSON(http.StatusInternalServerError, lib.JsonResponse{Message: "Failed to query user data"})
	}

	if !foundUser {
		return context.JSON(http.StatusNotFound, lib.JsonResponse{Message: "User not found"})
	}

	if expectedTempCode != (*user.TempCode)[:recuperationCodeBytesLength] {
		fmt.Println(expectedTempCode, (*user.TempCode)[:recuperationCodeBytesLength])
		return context.JSON(http.StatusUnauthorized, lib.JsonResponse{Message: "Invalid token"})
	}

	stringExpDate := (*user.TempCode)[recuperationCodeBytesLength : expDateBytesLength+recuperationCodeBytesLength-1]

	expDate, err := time.Parse(time.DateTime, stringExpDate)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to read expiration data %s\n", err)

		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid request body"})
	}

	nowFormatted, err := time.Parse(time.DateTime, time.Now().Format(time.DateTime))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to read expiration data %s\n", err)

		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid request body"})
	}

	if nowFormatted.After(expDate) {
		return context.JSON(http.StatusUnauthorized, lib.JsonResponse{Message: "Token Expired"})
	}

	return context.NoContent(http.StatusOK)
}

func authenticateRoute(context echo.Context) error {
	type reqPayload struct {
		Token string `json:"token"`
	}

	payload := new(reqPayload)
	if err := context.Bind(payload); err != nil {
		fmt.Fprintf(os.Stderr, "Failed to bind payload (authenticate route): %s\n", err)

		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid request body"})
	}

	token, err := crypt.Decrypt_AES256(payload.Token, key)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to decrypt token %s\n", err)

		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid token"})
	}

	stringID := token[:userIdBytesLength]
	stringExpDate := token[userIdBytesLength : expDateBytesLength+3]

	formatExpData := stringExpDate
	expDate, err := time.Parse(time.DateTime, formatExpData)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to read expiration data %s\n", err)

		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid request body"})
	}

	nowFormatted, err := time.Parse(time.DateTime, time.Now().Format(time.DateTime))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to read expiration data %s\n", err)

		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid request body"})
	}

	if nowFormatted.After(expDate) {
		return context.JSON(http.StatusUnauthorized, lib.JsonResponse{Message: "Token Expired"})
	}

	user := new(models.User)

	id, err := strconv.Atoi(stringID)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to parse id to string %s\n", err)

		return context.JSON(http.StatusBadRequest, lib.JsonResponse{Message: "Invalid request body"})
	}

	foundUser, err := user.QueryUserByID(*internal_db, id)
	if err != nil {
		return context.JSON(http.StatusInternalServerError, lib.JsonResponse{Message: "Failed to query user data"})
	}

	if !foundUser {
		return context.JSON(http.StatusNotFound, lib.JsonResponse{Message: "User not found"})
	}

	return context.JSON(http.StatusOK, lib.JsonResponse{Message: user})
}

func buildToken(id string, idBytesLength uint8, dateOffset int) (string, error) {
	if uint8(len(id)) > idBytesLength {
		return "", fmt.Errorf("user id should not be greater than %d bytes in length", idBytesLength)
	}

	formatedId := fmt.Sprintf("%0*s", idBytesLength, id)

	now := time.Now()
	yyyy, mm, dd := now.Date()

	expOffsetTime := time.Date(yyyy, mm, dd+dateOffset, now.Hour(), now.Minute()+5, 0, 0, now.Location())
	expOffset := expOffsetTime.String()[:20]
	if uint8(len(expOffset)) > expDateBytesLength {
		fmt.Println(expOffsetTime.String())

		return "", fmt.Errorf("users expiration offset should not be greater than %d bytes in length", expDateBytesLength)
	}

	token := formatedId + expOffset
	return token, nil
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
 * exp_date = 20 bytes (REVIEW - could be smaller)
 * ?hash offset = 24 bytes
 * hash layout sha256(user_id + exp_date) maybe? (+ hash(password || email || unique_id))
 */
func buildAuthToken(id string) (string, error) {
	token, err := buildToken(id, userIdBytesLength, 1)
	if err != nil {
		return "", err
	}

	return crypt.Encrypt_AES256(token, key)
}

func buildRecuperationToken() (string, error) {
	randomCode := lib.RandStringBytesMaskImprSrcSB(5)
	return buildToken(randomCode, recuperationCodeBytesLength, 0)
}
