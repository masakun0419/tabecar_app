-- ============================================================
-- 食べカー Ver1.0 テストデータ
-- パスワードは全ユーザー共通で password123 を想定
-- password_hash はダミーbcrypt文字列。実装時はアプリ側で生成すること。
-- ============================================================

INSERT INTO users (email, password_hash, display_name, user_type) VALUES
('user01@example.com', '$2b$12$abcdefghijklmnopqrstuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu', 'テストユーザー01', 'USER'),
('shop01@example.com', '$2b$12$abcdefghijklmnopqrstuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu', 'クレープSunny担当', 'SHOP'),
('shop02@example.com', '$2b$12$abcdefghijklmnopqrstuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu', 'からあげ永屋担当', 'SHOP'),
('shop03@example.com', '$2b$12$abcdefghijklmnopqrstuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu', 'Nara Burger担当', 'SHOP'),
('shop04@example.com', '$2b$12$abcdefghijklmnopqrstuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu', 'Tokyo Taco担当', 'SHOP'),
('admin@example.com', '$2b$12$abcdefghijklmnopqrstuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu', '管理者', 'ADMIN');

INSERT INTO user_profiles (user_id, notification_radius_km, last_latitude, last_longitude) VALUES
(1, 5, 34.685087, 135.804848);

INSERT INTO categories (name, display_order) VALUES
('クレープ', 1), ('唐揚げ', 2), ('ハンバーガー', 3), ('タコス', 4), ('カレー', 5), ('コーヒー', 6), ('たこ焼き', 7), ('スイーツ', 8);

INSERT INTO shops (owner_user_id, category_id, name, description, phone, email, instagram_url, icon_image_url) VALUES
(2, 1, 'クレープSunny', '奈良県を中心に営業するもちもち生地のクレープ専門キッチンカー。', '090-1111-1111', 'shop01@example.com', 'https://instagram.com/example_sunny', 'https://example.com/images/sunny_icon.jpg'),
(3, 2, 'からあげ永屋', '揚げたてジューシーな唐揚げ専門店。', '090-2222-2222', 'shop02@example.com', 'https://instagram.com/example_karaage', 'https://example.com/images/karaage_icon.jpg'),
(4, 3, 'Nara Burger Stand', '国産牛パティのハンバーガーを提供。', '090-3333-3333', 'shop03@example.com', 'https://instagram.com/example_burger', 'https://example.com/images/burger_icon.jpg'),
(5, 4, 'Tokyo Taco Truck', 'スパイス香る本格タコスのキッチンカー。', '090-4444-4444', 'shop04@example.com', 'https://instagram.com/example_taco', 'https://example.com/images/taco_icon.jpg');

INSERT INTO shop_images (shop_id, image_url, caption, display_order) VALUES
(1, 'https://example.com/images/sunny_01.jpg', '人気のいちごクレープ', 1),
(2, 'https://example.com/images/karaage_01.jpg', '揚げたて唐揚げ', 1),
(3, 'https://example.com/images/burger_01.jpg', 'チーズバーガー', 1),
(4, 'https://example.com/images/taco_01.jpg', 'タコスセット', 1);

INSERT INTO menus (shop_id, name, description, price, image_url, display_order) VALUES
(1, 'いちごクレープ', 'ホイップといちごの定番クレープ', 650, 'https://example.com/images/menu_crepe_strawberry.jpg', 1),
(1, 'チョコバナナクレープ', 'チョコソースとバナナの人気メニュー', 600, 'https://example.com/images/menu_crepe_choco.jpg', 2),
(2, 'からあげ5個', '外カリ中ジューシー', 600, 'https://example.com/images/menu_karaage.jpg', 1),
(3, 'チーズバーガー', '濃厚チーズと国産牛パティ', 950, 'https://example.com/images/menu_burger.jpg', 1),
(4, 'タコス2P', 'スパイス香る本格タコス', 800, 'https://example.com/images/menu_taco.jpg', 1);

INSERT INTO shop_events (shop_id, title, address, prefecture, city, latitude, longitude, start_at, end_at, note) VALUES
(1, 'イオンモール橿原 出店', '奈良県橿原市曲川町7丁目20-1', '奈良県', '橿原市', 34.507601, 135.793804, '2026-06-06 10:00:00', '2026-06-06 18:00:00', '雨天時は中止の可能性あり'),
(2, '奈良公園前 出店', '奈良県奈良市登大路町', '奈良県', '奈良市', 34.685087, 135.804848, '2026-06-07 11:00:00', '2026-06-07 17:00:00', NULL),
(3, '大阪城公園イベント', '大阪府大阪市中央区大阪城1-1', '大阪府', '大阪市', 34.687315, 135.526201, '2026-06-08 10:00:00', '2026-06-08 19:00:00', NULL),
(4, '代々木公園フードイベント', '東京都渋谷区代々木神園町2-1', '東京都', '渋谷区', 35.671736, 139.694944, '2026-06-09 10:00:00', '2026-06-09 18:00:00', NULL),
(1, '名古屋駅前マルシェ', '愛知県名古屋市中村区名駅1丁目', '愛知県', '名古屋市', 35.170915, 136.881537, '2026-06-10 11:00:00', '2026-06-10 19:00:00', NULL),
(2, '博多駅前 出店', '福岡県福岡市博多区博多駅中央街1-1', '福岡県', '福岡市', 33.590355, 130.420611, '2026-06-11 11:00:00', '2026-06-11 20:00:00', NULL);

INSERT INTO favorites (user_id, shop_id) VALUES
(1, 1), (1, 2);

INSERT INTO device_tokens (user_id, fcm_token, platform) VALUES
(1, 'dummy_fcm_token_for_ios_user01', 'iOS');

INSERT INTO notifications (user_id, shop_id, event_id, notification_type, title, body) VALUES
(1, 1, 1, 'FAVORITE_EVENT', 'お気に入り店舗が出店します', 'クレープSunnyがイオンモール橿原に出店予定です。'),
(1, 2, 2, 'NEARBY_EVENT', '近くにキッチンカーが出店します', 'からあげ永屋が奈良公園前に出店予定です。');
