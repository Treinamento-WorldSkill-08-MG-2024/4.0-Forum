package smtp

import (
	"errors"
	"strings"

	"github.com/gofor-little/env"
	"gopkg.in/gomail.v2"
)

const smtpServer string = "smtp.gmail.com"
const smtpPort int = 587

type Email struct {
	to      string
	body    string
	subject string
}

func (e *Email) SetBody(body string) *Email {
	e.body = body
	return e
}

func (e *Email) SetSubject(subject string) *Email {
	e.subject = subject
	return e
}

func (e *Email) SetTo(to string) *Email {
	e.to = to
	return e
}

func (e *Email) Mail() error {
	smtpUsername := env.Get("SMTP_USERNAME", "-1")
	if strings.Compare(smtpUsername, "-1") == 0 {
		return errors.New("failed to load smtp username from .env")
	}

	smtpPassword := env.Get("SMTP_PASSWORD", "-1")
	if strings.Compare(smtpPassword, "-1") == 0 {
		return errors.New("failed to load smtp password from .env")
	}

	message := gomail.NewMessage()
	message.SetHeader("From", smtpUsername)
	message.SetHeader("To", e.to)
	message.SetHeader("Subject", e.subject)
	message.SetBody("text/html", e.body)

	dialer := gomail.NewDialer(smtpServer, smtpPort, smtpUsername, smtpPassword)
	if err := dialer.DialAndSend(message); err != nil {
		return err
	}

	return nil
}
