# 食べカー API (Ver1.0)

FastAPI + PostgreSQL バックエンド。OpenAPI 仕様は `openapi.yaml` を参照。

## 技術スタック

- Python 3.10+
- FastAPI
- SQLAlchemy 2.x
- PostgreSQL 16
- JWT (python-jose)
- bcrypt (passlib)

## セットアップ

```bash
# 依存関係
pip install -r requirements.txt

# 環境変数
cp .env.example .env
# .env の DATABASE_URL を実環境に合わせて編集（後述）

# PostgreSQL 起動（Docker 利用時）
docker compose up -d

# API 起動
uvicorn app.main:app --reload --host 0.0.0.0 --port 9999
```

API ベース URL: `http://localhost:9999/api/v1`

Swagger UI: `http://localhost:9999/docs`

## 本番サーバー環境 (ubuntuserver)

### ポート

| ポート | 用途 |
|--------|------|
| **9999** | 食べカー API（本プロジェクト） |
| 8888 | 別プロジェクト (`/home/ubuntu/python`) が使用中のため未使用 |

OpenAPI 仕様 (`openapi.yaml`) の servers URL は `8888` のままだが、実際の起動ポートは **9999**。iOS アプリ側は `http://<サーバーIP>:9999/api/v1` を指定すること。

### PostgreSQL 接続情報

| 項目 | 値 |
|------|-----|
| ホスト | `localhost` |
| ポート | `5432` |
| DB名 | `tabecar_db` |
| ユーザー | `tabecar` |
| パスワード | `tabecar_db` |

`.env` の設定例:

```env
DATABASE_URL=postgresql://tabecar:tabecar_db@localhost:5432/tabecar_db
JWT_SECRET_KEY=dev-secret-key-change-in-production
JWT_ALGORITHM=HS256
JWT_EXPIRE_MINUTES=10080
```

### DB セットアップ手順（参考）

DB `tabecar_db` は既に作成済み。ユーザー作成・パスワード設定が必要な場合:

```bash
sudo -u postgres psql
```

```sql
ALTER USER tabecar WITH PASSWORD 'tabecar_db';
GRANT ALL ON SCHEMA public TO tabecar;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO tabecar;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO tabecar;
```

スキーマ・seed 投入（未投入の場合）:

```bash
PGPASSWORD=tabecar_db psql -U tabecar -d tabecar_db -h localhost -f schema.sql
PGPASSWORD=tabecar_db psql -U tabecar -d tabecar_db -h localhost -f seed.sql
```

### 動作確認

```bash
# ヘルスチェック（API プロセスのみ）
curl http://localhost:9999/health

# DB 接続チェック（500 エラー調査用）
curl http://localhost:9999/health/db

# 店舗一覧
curl http://localhost:9999/api/v1/shops

# ログイン
curl -X POST http://localhost:9999/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user01@example.com","password":"password123"}'
```

## エンドポイント

| メソッド | パス | 説明 | 認証 |
|---------|------|------|------|
| POST | /auth/register | ユーザー登録 | 不要 |
| POST | /auth/login | ログイン (JWT) | 不要 |
| GET | /shops | 店舗一覧 | 不要 |
| POST | /shops | 店舗登録 | SHOP |
| GET | /shops/{shop_id} | 店舗詳細 | 不要 |
| GET | /events | 出店予定一覧 | 不要 |
| POST | /events | 出店予定登録 | SHOP |
| GET | /favorites | お気に入り一覧 | 必須 |
| POST | /favorites | お気に入り登録 | 必須 |
| DELETE | /favorites/{shop_id} | お気に入り解除 | 必須 |
| POST | /device-tokens | FCM トークン登録 | 必須 |
| GET | /notifications | 通知一覧 | 必須 |

## テストユーザー (seed.sql)

全ユーザーのパスワード: `password123`

- `user01@example.com` (一般ユーザー)
- `shop01@example.com` (店舗ユーザー)

## トラブルシューティング

### ログイン時に Internal Server Error (500)

パスワード間違いの場合は **401** になる。500 はサーバー側の異常。

**重要:** `/health` は API プロセスだけの確認。**DB は `/health/db` で確認する。**

```bash
# OK でも shops が 500 になる典型パターン
curl http://localhost:9999/health      # → ok（DB未使用）
curl http://localhost:9999/health/db    # → error（ここが本当の原因）
curl http://localhost:9999/api/v1/shops # → 500
```

一括診断:

```bash
bash scripts/check_server.sh
```

1. **DB 接続を確認**
   ```bash
   curl http://localhost:9999/health/db
   ```
   HTTP 503 / `{"status":"error",...}` なら PostgreSQL 接続に問題あり。

2. **`.env` の `DATABASE_URL` を確認**
   - 本番: `postgresql://tabecar:tabecar_db@localhost:5432/tabecar_db`
   - ローカル Docker: `postgresql://tabecar:tabecar@localhost:5432/tabecar`
   - DB 名・パスワードの取り違えが多い（`tabecar` と `tabecar_db`）

3. **PostgreSQL が起動しているか**
   ```bash
   sudo systemctl status postgresql
   PGPASSWORD=tabecar_db psql -U tabecar -d tabecar_db -h localhost -c "SELECT 1"
   ```

4. **API ログを確認（エラー内容がここに出る）**
   ```bash
   sudo journalctl -u tabecar-api.service -n 50 --no-pager
   ```
   よくあるログ:
   - `relation "shops" does not exist` → テーブル未作成
   - `password authentication failed` → `.env` のパスワード不一致
   - `database "tabecar" does not exist` → DB名の取り違え

5. **テーブル未作成の場合**
   ```bash
   PGPASSWORD=tabecar_db psql -U tabecar -d tabecar_db -h localhost -c "\dt"
   # 空なら schema + seed を投入
   PGPASSWORD=tabecar_db psql -U tabecar -d tabecar_db -h localhost -f schema.sql
   PGPASSWORD=tabecar_db psql -U tabecar -d tabecar_db -h localhost -f seed.sql
   sudo systemctl restart tabecar-api.service
   bash scripts/check_server.sh
   ```

## 変更履歴

### 2026-06-01

- FastAPI プロジェクトを新規作成（`openapi.yaml` / `schema.sql` / `seed.sql` 準拠）
- 全 API エンドポイントを実装（auth, shops, events, favorites, device-tokens, notifications）
- 起動ポートを **8888 → 9999** に変更（8888 は別サービスが占有）
- PostgreSQL 接続先を **`tabecar_db`** DB に設定（DB名 `tabecar` ではなく `tabecar_db`）
- DB ユーザー `tabecar` のパスワードを `tabecar_db` に設定
- `/api/v1/shops` の動作確認完了（seed データ 4 店舗を取得）


psql "postgresql://tabecar:tabecar_db@localhost:5432/tabecar_db"