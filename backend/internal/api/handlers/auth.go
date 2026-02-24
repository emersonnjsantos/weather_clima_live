package handlers

import (
	"encoding/json"
	"errors"
	"net/http"

	mw "github.com/weatherpro/backend/internal/api/middleware"
	"github.com/weatherpro/backend/internal/core/services"
)

// AuthHandler é um handler para autenticação.
type AuthHandler struct {
	authService *services.AuthService
}

// NewAuthHandler cria um novo AuthHandler.
func NewAuthHandler(authService *services.AuthService) *AuthHandler {
	return &AuthHandler{
		authService: authService,
	}
}

// Register registra um novo usuário e retorna um JWT.
func (h *AuthHandler) Register(w http.ResponseWriter, r *http.Request) {
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

	if len(req.Password) < 6 {
		mw.WriteError(w, http.StatusBadRequest, "password must be at least 6 characters", nil)
		return
	}

	tokenResp, err := h.authService.Register(r.Context(), req.Email, req.Password)
	if err != nil {
		if errors.Is(err, services.ErrUserAlreadyExists) {
			mw.WriteError(w, http.StatusConflict, "user already exists", err)
			return
		}
		mw.WriteError(w, http.StatusInternalServerError, "failed to register user", err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	_ = json.NewEncoder(w).Encode(tokenResp)
}

// Login autentica um usuário e retorna um JWT.
func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
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

	tokenResp, err := h.authService.Login(r.Context(), req.Email, req.Password)
	if err != nil {
		if errors.Is(err, services.ErrInvalidCredentials) {
			mw.WriteError(w, http.StatusUnauthorized, "invalid email or password", err)
			return
		}
		mw.WriteError(w, http.StatusInternalServerError, "failed to authenticate user", err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(tokenResp)
}
