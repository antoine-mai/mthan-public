# Cập nhật Hệ thống (Update Guide)

MTHAN VPS Platform được thiết kế để dễ dàng cập nhật mà không làm ảnh hưởng đến dữ liệu hiện tại của bạn. Khi có tính năng mới hoặc bản vá lỗi, bạn chỉ cần chạy lệnh "Repair".

## 🔄 Cập nhật qua giao diện dòng lệnh (Terminal)

Để nhận được các bản cập nhật mới nhất từ GitHub chứa các file Binary và Giao diện đã được đóng gói sẵn, sử dụng cờ `--repair`.

Lệnh này sẽ tải lại và cài đặt đè hệ thống, tuy nhiên **toàn bộ User, Ứng dụng, Database và Cấu hình của bạn vẫn sẽ được giữ nguyên vẹn**.

```bash
curl -sSL https://raw.githubusercontent.com/antoine-mai/mthan-vps/main/install.sh | bash -s -- --repair
```

## ⚠️ Lưu ý Quan trọng
* Quá trình cập nhật thường mất khoảng 10-20 giây.
* Hệ thống `mthan-cpanel` và `caddy` sẽ tự động khởi động lại sau khi cập nhật.
* Đừng chạy lệnh `install.sh` mà KHÔNG CÓ cờ `--repair` nếu bạn không muốn xóa sạch toàn bộ hệ thống cũ. (Clean install sẽ format toàn bộ file trong `/root/.mthan/`)
