package crypt

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
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
	return string(dataBuffer), nil
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

	nonceSize := aesGCM.NonceSize()
	nonce, ciphertext := encryptedData[:nonceSize], encryptedData[nonceSize:]

	plaintext, err := aesGCM.Open(nil, []byte(nonce), []byte(ciphertext), nil)
	if err != nil {
		return "", fmt.Errorf("failed to decode encrypted data (aesGCM open): %s", err)
	}

	return string(plaintext), nil
}
