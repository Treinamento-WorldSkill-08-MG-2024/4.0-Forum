package lib

type JsonResponse struct {
	Message interface{} `json:"message"`
}

type ApiResponse map[string]interface{}

// Safely dereferences a comparable type pointer.
// It returns the dereferenced value if the pointer is not nil.
// If the pointer is a nil-pointer, it returns nil.
//
// Use Concerns:
// * Only use this function when the pointer type (parameter) is known and evident.
// * Avoid using it for complex logic to prevent unexpected behavior
func SafeDerefComparable[T comparable](pointer *T) any {
	if pointer == nil {
		return nil
	}

	return *pointer
}
