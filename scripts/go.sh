#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Go tool binaries..."

if ! command -v go &>/dev/null; then
  echo "    ERROR: go not found. Run brew.sh first."
  exit 1
fi

GO_PACKAGES=(
  "github.com/air-verse/air@latest"
  "github.com/melkeydev/go-blueprint@latest"
  "goa.design/goa/v3/cmd/goa@latest"
  "golang.org/x/tools/gopls@latest"
  "google.golang.org/protobuf/cmd/protoc-gen-go@latest"
  "google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest"
  "honnef.co/go/tools/cmd/staticcheck@latest"
  "github.com/swaggo/swag/cmd/swag@latest"
  "github.com/go-task/task/v3/cmd/task@latest"
  "github.com/a-h/templ/cmd/templ@latest"
)

for pkg in "${GO_PACKAGES[@]}"; do
  echo "    Installing $pkg..."
  go install "$pkg"
done

echo "    Go tool binaries installed."
