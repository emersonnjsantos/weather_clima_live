package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/google/uuid"
	"github.com/weatherpro/backend/internal/core/services"
)

type userIDKey struct{}

// Auth é um middleware JWT que extrai o user ID do token e injeta no contexto.
func Auth(authService *services.AuthService) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			authHeader := r.Header.Get("Authorization")
			if authHeader == "" {
				WriteError(w, http.StatusUnauthorized, "authorization header is required", nil)
				return
			}

			parts := strings.SplitN(authHeader, " ", 2)
			if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
				WriteError(w, http.StatusUnauthorized, "invalid authorization header format", nil)
				return
			}

			userIDStr, err := authService.ValidateToken(parts[1])
			if err != nil {
				WriteError(w, http.StatusUnauthorized, "invalid or expired token", err)
				return
			}

			userID, err := uuid.Parse(userIDStr)
			if err != nil {
				WriteError(w, http.StatusUnauthorized, "invalid user id in token", err)
				return
			}

			ctx := context.WithValue(r.Context(), userIDKey{}, userID)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// GetUserID extrai o user ID do contexto (inserido pelo middleware Auth).
func GetUserID(ctx context.Context) (uuid.UUID, bool) {
	id, ok := ctx.Value(userIDKey{}).(uuid.UUID)
	return id, ok
}
