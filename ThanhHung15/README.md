# Sudoku (Flutter + MVC) — Offline & Online

## Màn hình (ít nhất 5)

- **Home**: chọn độ khó, chơi offline, thi đấu online, cấu hình server, vào lịch sử
- **Login**: đăng nhập online, hoặc vào offline dạng khách
- **Đăng ký**: tạo tài khoản online
- **Lịch sử**: xem/xóa lịch sử ván chơi
- **Chơi game**: bảng Sudoku 9x9 + bàn phím số + nộp bài + timer

## Kiến trúc (MVC đơn giản)

- **Model**: `lib/src/models/`
- **Controller**: `lib/src/controllers/` (dùng `ChangeNotifier`)
- **View**: `lib/src/views/`
- **Service**: `lib/src/services/` (local storage, sudoku engine, online API)

## Chạy Flutter app

```bash
flutter pub get
flutter run
```

## Chạy chế độ Online (thi đấu)

Online được implement bằng **Dart server + MySQL** chạy kèm trong repo.

### 1) Chạy MySQL (root/123456)

- Cách nhanh bằng Docker:

```bash
cd server
docker compose up -d
```

- Tạo schema (nếu cần):

```bash
cd server
mysql -uroot -p123456 < schema.sql
```

Mặc định server kết nối:
- `DB_HOST=127.0.0.1`
- `DB_PORT=3306`
- `DB_USER=root`
- `DB_PASS=123456`
- `DB_NAME=sudoku`

### 2) Chạy server

```bash
cd server
dart pub get
dart run bin/server.dart
```

Server mặc định chạy ở `http://0.0.0.0:8080`.

### 3) Cấu hình URL trong app

Trong **Home → Online server**:

- **Android emulator**: `http://10.0.2.2:8080`
- **Máy thật**: `http://<IP-máy-chạy-server>:8080`

Sau đó vào **Đăng ký/Đăng nhập online** và:
- Bấm **Random online** để tự join phòng đang chờ (nếu có), hoặc tự tạo phòng.
- Hoặc nhập **Mã phòng** để chơi theo mã.
