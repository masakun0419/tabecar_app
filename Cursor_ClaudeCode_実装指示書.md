# 食べカー Ver1.0 実装指示書（Cursor / Claude Code 用）

## 目的
SwiftUI + FastAPI + PostgreSQL + Google Maps + Firebase Cloud Messaging で、全国版キッチンカー出店情報アプリ「食べカー」Ver1.0を実装する。

## 確定仕様
- ログイン: メールアドレス + パスワード。登録時にbcryptでハッシュ化。
- 認証: JWT Bearer Token。
- 店舗: 店舗ユーザー自身が店舗情報・出店予定・メニューを登録する。
- 地図: iOS側はGoogle Maps SDK for iOSを使用。
- 通知: お気に入り店舗の出店通知、近隣キッチンカー出店通知。
- 対象地域: 全国。
- 収益化: Ver1.0では無し。

## Backend 実装方針
- Python 3.12
- FastAPI
- SQLAlchemy 2.x
- Alembic
- PostgreSQL 16
- passlib[bcrypt]
- python-jose または pyjwt
- firebase-admin

## iOS 実装方針
- SwiftUI
- MVVM
- Google Maps SDK for iOS
- Firebase Messaging
- URLSession + async/await
- KeychainにJWT保存

## 最初に実装する順番
1. PostgreSQLのDocker起動
2. FastAPIプロジェクト作成
3. DB接続、SQLAlchemyモデル作成
4. auth/register, auth/login 実装
5. shops, events API 実装
6. SwiftUI ログイン画面
7. SwiftUI ホーム一覧画面
8. Google Maps ピン表示
9. お気に入り登録/解除
10. FCMトークン登録
11. 出店登録時の通知処理

## 注意
- パスワード平文保存は絶対NG。
- 店舗登録APIはSHOPユーザーのみ許可。
- 他店舗の出店予定編集は禁止。
- 緯度経度はGoogle Mapsのピン表示と近隣通知で使用する。
