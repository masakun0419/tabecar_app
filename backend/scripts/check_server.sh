#!/usr/bin/env bash
set -uo pipefail

BASE_URL="${1:-http://localhost:9999}"

echo "=== /health (API process only) ==="
curl -s "${BASE_URL}/health"
echo

echo
echo "=== /health/db (PostgreSQL) ==="
curl -s -w "\nHTTP:%{http_code}\n" "${BASE_URL}/health/db"
echo

echo "=== /api/v1/shops ==="
curl -s -w "\nHTTP:%{http_code}\n" "${BASE_URL}/api/v1/shops"
echo

echo "=== /api/v1/auth/login ==="
curl -s -w "\nHTTP:%{http_code}\n" -X POST "${BASE_URL}/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"user01@example.com","password":"password123"}'
echo
