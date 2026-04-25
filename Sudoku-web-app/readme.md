📘 README - Ứng dụng Sudoku (Flutter + Dart + SQLite)
1. Giới thiệu

Ứng dụng Sudoku là một game giải đố số cổ điển, được xây dựng bằng Flutter nhằm hỗ trợ đa nền tảng (Web và Android).
Mục tiêu của dự án là tập trung vào thiết kế giao diện đẹp, trải nghiệm người dùng tốt và có đầy đủ các màn hình cơ bản phục vụ gameplay.

Ứng dụng phù hợp với mức đồ án môn học, không tập trung vào thuật toán phức tạp mà chú trọng UI/UX và cấu trúc hệ thống.

2. Công nghệ sử dụng
Flutter: Framework chính (Web + Android)
Dart: Ngôn ngữ lập trình
SQLite (sqflite): Lưu trữ dữ liệu local
Provider: Quản lý state đơn giản
3. Tính năng chính
🎮 Gameplay
Tạo game Sudoku với 3 mức độ:
Easy
Medium
Hard
Nhập số vào bảng 9x9
Kiểm tra đúng/sai
Gợi ý (Hint)
Reset game
💾 Lưu trữ
Lưu game đang chơi
Lịch sử chơi
Thời gian hoàn thành
🎨 UI/UX
Responsive (Web + Mobile)
Dark mode
Animation cơ bản
4. Danh sách màn hình (PHẦN ĂN ĐIỂM)
4.1 Splash Screen

Mục đích:

Hiển thị logo và load app

UI:

Background gradient xanh → đậm
Logo Sudoku ở giữa
Loading animation
4.2 Home Screen

Chức năng:

Điều hướng chính

Thành phần:

Logo
4 nút:
New Game
Continue
History
Settings

Thiết kế:

Mobile: layout dọc
Web: centered + card
4.3 Difficulty Screen

Chức năng:

Chọn độ khó

UI:

3 card:
Easy (xanh lá)
Medium (vàng)
Hard (đỏ)

Animation:

Hover (web) / tap scale
4.4 Game Screen (TRỌNG TÂM)

Chức năng:

Chơi Sudoku
Layout Mobile:
Board 9x9
---------
Number Pad
---------
Action Buttons
Layout Web:
| Menu | Board | Info |
Thành phần:
Sudoku Grid (9x9)
Number Pad (1–9)
Timer
Buttons:
Hint
Reset
Check

Hiệu ứng:

Chọn ô → highlight
Nhập số → pop animation
Sai → đỏ nhẹ
4.5 Pause / Continue Popup

Chức năng:

Tạm dừng game

UI:

Popup giữa màn hình
Nút:
Continue
Restart
Exit
4.6 Result Screen

Chức năng:

Hiển thị kết quả

Thành phần:

Thời gian hoàn thành
Độ khó
Nút:
Play Again
Home

Hiệu ứng:

Confetti nhẹ
4.7 History Screen

Chức năng:

Xem lịch sử chơi

UI:

List:
Date
Time
Difficulty
Click → xem lại
4.8 Settings Screen

Chức năng:

Cài đặt app

Tùy chọn:

Dark mode
Sound on/off
4.9 About Screen (cho đủ màn hình, thầy thích mấy cái này)

Nội dung:

Giới thiệu app
Thông tin sinh viên
5. Thiết kế UI
🎨 Màu sắc
Primary: #3B82F6
Secondary: #1E293B
Accent: #F59E0B
📐 Nguyên tắc
Bo góc: 12px
Button đồng nhất
Font rõ ràng
🎬 Animation
Nhẹ, không lố:
Fade
Scale
Slide
6. Cơ sở dữ liệu (SQLite)
Bảng: games
id INTEGER PRIMARY KEY
difficulty TEXT
time INTEGER
status TEXT
date TEXT
Bảng: current_game
id INTEGER
board TEXT
solution TEXT
7. Cấu trúc project(yêu cầu cho toàn bộ dự án, không tách back và fronend, trong dự án phù hợp cho việc có cả androi và web, khi chạy dự án bằng termimal thì có thể dùng lệnh để chọn chạy web hay androi)
lib/
 ├── main.dart
 ├── core/
 ├── data/
 ├── view/
 ├── viewmodel/
8. Responsive (Web + Mobile)
Điều kiện	Layout
< 800px	Mobile
≥ 800px	Web

Sử dụng:

MediaQuery
LayoutBuilder
9. Hướng dẫn cài đặt & chạy
1. Clone project
git clone <repo>
cd sudoku_app
2. Cài dependencies
flutter pub get
3. Chạy Android
flutter run
4. Chạy Web
flutter run -d chrome
10. Hướng phát triển thêm
Leaderboard online
Multiplayer
AI solver
Animation nâng cao
11. Tổng kết

Ứng dụng đáp ứng:

✔ Đa nền tảng (Web + Android)
✔ UI đầy đủ, đẹp
✔ Có database
✔ Có nhiều màn hình