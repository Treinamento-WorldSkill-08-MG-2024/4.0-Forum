package routes

import (
	"database/sql"
	"fmt"
	"os"
	"strconv"

	"github.com/labstack/echo/v4"
)

var internal_db **sql.DB

func getIntParam(context echo.Context, paramName string) (int, error) {
	paramValue, err := strconv.Atoi(context.Param(paramName))
	if err != nil {
		fmt.Fprintf(os.Stderr, "invalid %s parameter: %s\n", paramName, err)
	}

	return paramValue, err
}

func bindJSONBody(context echo.Context, v interface{}) error {
	if err := context.Bind(v); err != nil {
		fmt.Fprintf(os.Stderr, "Failed to bind JSON body: %v\n", err)
	}

	return nil
}
