package middleware

import (
	"encoding/json"
	"log/slog"
	"net/http"
)

// APIError representa um erro de API padronizado retornado ao cliente.
type APIError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

// WriteError escreve uma resposta de erro padronizada.
// Não expõe detalhes internos ao cliente.
func WriteError(w http.ResponseWriter, code int, publicMsg string, internalErr error) {
	if internalErr != nil {
		slog.Error("request error",
			"status", code,
			"public_message", publicMsg,
			"internal_error", internalErr.Error(),
		)
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	_ = json.NewEncoder(w).Encode(APIError{
		Code:    code,
		Message: publicMsg,
	})
}
