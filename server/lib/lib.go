package lib

import (
	"math/rand"
	"strings"
	"time"
)

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

const letterBytes = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
const (
	letterIdxBits = 6                    // 6 bits to represent a letter index
	letterIdxMask = 1<<letterIdxBits - 1 // All 1-bits, as many as letterIdxBits
	letterIdxMax  = 63 / letterIdxBits   // # of letter indices fitting in 63 bits
)

var src = rand.NewSource(time.Now().UnixNano())

// LINK - https://stackoverflow.com/questions/22892120/how-to-generate-a-random-string-of-a-fixed-length-in-go
func RandStringBytesMaskImprSrcSB(n int) string {
	sb := strings.Builder{}
	sb.Grow(n)
	// A src.Int63() generates 63 random bits, enough for letterIdxMax characters!
	for i, cache, remain := n-1, src.Int63(), letterIdxMax; i >= 0; {
		if remain == 0 {
			cache, remain = src.Int63(), letterIdxMax
		}
		if idx := int(cache & letterIdxMask); idx < len(letterBytes) {
			sb.WriteByte(letterBytes[idx])
			i--
		}
		cache >>= letterIdxBits
		remain--
	}

	return sb.String()
}
