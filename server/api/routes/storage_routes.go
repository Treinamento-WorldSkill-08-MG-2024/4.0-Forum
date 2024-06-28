package routes

import (
	"database/sql"
	"fmt"
	"image"
	"net/http"
	"os"

	"github.com/labstack/echo/v4"
)

func StorageRoute(db *sql.DB, e *echo.Echo) {
	e.GET("/image/:id", getImage)
	e.POST("/image", postImage)
}

func getImage(context echo.Context) error {
	openedImage, err := os.Open("./images/matrix.png")
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to open image %s\n", err)

		return context.NoContent(http.StatusBadRequest)
	}

	defer openedImage.Close()

	imageData, imageType, err := image.Decode(openedImage)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to decode image %s\n", err)

		return context.NoContent(http.StatusInternalServerError)
	}

	openedImage.Seek(0, 0)

	fmt.Println(imageData)
	fmt.Println(imageType)

	return nil
}

func postImage(context echo.Context) error {
	return nil
}
