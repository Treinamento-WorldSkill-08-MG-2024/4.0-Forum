package lib

type JsonResponse struct {
	Message interface{} `json:"message"`
}

type ApiResponse map[string]interface{}

func SafeDerefComparable[T comparable](pointer *T) any {
	if pointer == nil {
		return nil
	}

	return *pointer
}
