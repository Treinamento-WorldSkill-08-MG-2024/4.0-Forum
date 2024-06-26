package crypt

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"io"
)

func Encrypt_AES256(data string, key string) (string, error) {
	aesBlock, err := aes.NewCipher([]byte(key))
	if err != nil {
		return "", fmt.Errorf("failed to create encryption block: %s", err)
	}

	aesGCM, err := cipher.NewGCM(aesBlock)
	if err != nil {
		return "", fmt.Errorf("failed to create gcm for aes block: %s", err)
	}

	nonce := make([]byte, aesGCM.NonceSize())
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		return "", fmt.Errorf("failed to read nonce from gcm: %s", err)
	}

	dataBuffer := aesGCM.Seal(nonce, nonce, []byte(data), nil)
	encodedData := base64.StdEncoding.EncodeToString(dataBuffer)
	return encodedData, nil
}

func Decrypt_AES256(encryptedData string, key string) (string, error) {
	aesBlock, err := aes.NewCipher([]byte(key))
	if err != nil {
		return "", fmt.Errorf("failed to create encryption block: %s", err)
	}

	aesGCM, err := cipher.NewGCM(aesBlock)
	if err != nil {
		return "", fmt.Errorf("failed to create gcm for aes block: %s", err)
	}

	decodedData, err := base64.StdEncoding.DecodeString(encryptedData)
	if err != nil {
		return "", fmt.Errorf("failed to decoded base64 for encrypted data")
	}

	nonceSize := aesGCM.NonceSize()
	nonce, ciphertext := decodedData[:nonceSize], decodedData[nonceSize:]

	plaintext, err := aesGCM.Open(nil, []byte(nonce), []byte(ciphertext), nil)
	if err != nil {
		return "", fmt.Errorf("failed to decode encrypted data (aesGCM open): %s", err)
	}

	return string(plaintext), nil
}
