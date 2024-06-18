package lib

type JsonResponse struct {
	Message interface{} `json:"message"`
}

type ApiResponse map[string]interface{}
