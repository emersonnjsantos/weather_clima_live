package handlers

import (
	"encoding/json"
	"net/http"

	mw "github.com/weatherpro/backend/internal/api/middleware"
	"github.com/weatherpro/backend/internal/core/services"
)

// UserHandler é um handler para usuários.
type UserHandler struct {
	userService *services.UserService
}

// NewUserHandler cria um novo UserHandler.
func NewUserHandler(userService *services.UserService) *UserHandler {
	return &UserHandler{
		userService: userService,
	}
}

// RegisterUser registra um novo usuário.
func (h *UserHandler) RegisterUser(w http.ResponseWriter, r *http.Request) {
	type request struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	var req request
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		mw.WriteError(w, http.StatusBadRequest, "invalid request body", err)
		return
	}

	if req.Email == "" || req.Password == "" {
		mw.WriteError(w, http.StatusBadRequest, "email and password are required", nil)
		return
	}

	user, err := h.userService.CreateUser(r.Context(), req.Email, req.Password)
	if err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to create user", err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	if err := json.NewEncoder(w).Encode(user); err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to encode response", err)
	}
}
