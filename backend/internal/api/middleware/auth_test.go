package middleware

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/google/uuid"
)

func TestGetUserID_WithValidUUID(t *testing.T) {
	expectedID := uuid.New()
	ctx := context.WithValue(context.Background(), userIDKey{}, expectedID)

	id, ok := GetUserID(ctx)
	if !ok {
		t.Fatal("expected ok to be true")
	}
	if id != expectedID {
		t.Errorf("expected %v, got %v", expectedID, id)
	}
}

func TestGetUserID_WithoutUserID(t *testing.T) {
	_, ok := GetUserID(context.Background())
	if ok {
		t.Fatal("expected ok to be false when no user ID in context")
	}
}

func TestGetUserID_WithWrongType(t *testing.T) {
	ctx := context.WithValue(context.Background(), userIDKey{}, "not-a-uuid")

	_, ok := GetUserID(ctx)
	if ok {
		t.Fatal("expected ok to be false when context value is wrong type")
	}
}

func TestWriteError_StatusCodes(t *testing.T) {
	tests := []struct {
		name       string
		statusCode int
		message    string
	}{
		{"bad request", http.StatusBadRequest, "bad request"},
		{"unauthorized", http.StatusUnauthorized, "unauthorized"},
		{"internal server error", http.StatusInternalServerError, "internal error"},
		{"not found", http.StatusNotFound, "not found"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			w := httptest.NewRecorder()
			WriteError(w, tt.statusCode, tt.message, nil)

			if w.Code != tt.statusCode {
				t.Errorf("expected status %d, got %d", tt.statusCode, w.Code)
			}

			body := w.Body.String()
			if body == "" {
				t.Error("expected non-empty body")
			}
		})
	}
}

func TestWriteError_ContentType(t *testing.T) {
	w := httptest.NewRecorder()
	WriteError(w, http.StatusBadRequest, "test", nil)

	contentType := w.Header().Get("Content-Type")
	if contentType != "application/json" {
		t.Errorf("expected Content-Type application/json, got %s", contentType)
	}
}
