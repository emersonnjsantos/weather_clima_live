package services

import (
	"context"

	"github.com/weatherpro/backend/internal/core/domain"
	"github.com/weatherpro/backend/internal/platform/database"
	"golang.org/x/crypto/bcrypt"
)

// UserService é um serviço para usuários.
type UserService struct {
	userRepo *database.UserRepository
}

// NewUserService cria uma nova instância de UserService.
func NewUserService(userRepo *database.UserRepository) *UserService {
	return &UserService{
		userRepo: userRepo,
	}
}

// CreateUser cria um novo usuário.
func (s *UserService) CreateUser(ctx context.Context, email, password string) (*domain.User, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	user := &domain.User{
		Email:        email,
		PasswordHash: string(hashedPassword),
	}

	if err := s.userRepo.CreateUser(ctx, user); err != nil {
		return nil, err
	}

	return user, nil
}
