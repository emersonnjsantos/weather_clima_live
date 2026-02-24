package handlers

import (
	"encoding/json"
	"net/http"
)

// HealthHandler é um handler para health check.
type HealthHandler struct{}

// NewHealthHandler cria um novo HealthHandler.
func NewHealthHandler() *HealthHandler {
	return &HealthHandler{}
}

// Check retorna o status de saúde da API.
func (h *HealthHandler) Check(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(map[string]string{
		"status": "ok",
	})
}
