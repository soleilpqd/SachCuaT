# Kệ sách cá nhân

## A.Cấu trúc dữ liệu

Thuộc tính của sách:
- Tên
- Tác giả: 0, 1 hoặc nhiều.
- Dịch giả: 0, 1 hoặc nhiều.
- Đơn vị phát hành: 0, 1 hoặc nhiều.
- Vị trí: 1 hoặc nhiều, tương ứng với số lượng quyển của sách. Sách có thể rời khỏi vị trí (vị trí được đánh dấu thành vị trí trước đây, không xóa vị trí của sách). Mỗi vị trí có ngày nhập liệu lần đầu.
- Mã ISBN: 0 hoặc 1.
- Nhãn: 0 hoặc nhiều. Danh sách nhãn dùng chung nhưng mỗi sách có giá trị nhãn của riêng mình.
- Chuỗi (Serie), số thự tự (tập) trong chuỗi.
- Ảnh chụp bìa sách (tên ảnh lấy theo mã quản lý dữ liệu sách).

Nhãn sách: có 3 kiểu
- Số
- Văn bản
- Mã vạch

Đơn vị phát hành: có thể có hoặc không mã ISBN.

Chuỗi: có hoặc không có tên.

## B. Tính năng

### B.I. Nhập sách mới

- Chụp ảnh bìa sách: tự động dò văn bản trên bìa làm dữ liệu gợi ý khi gõ thông tin sách.
- Quét mã ISBN.
- Tra cứu Website Cục xuất bản: mở browser hoặc bên trong app. Bên trong app thì có tính năng tự động bôi chọn, nhập dữ liệu từ dòng được bôi chọn.
- Nhập tên sách: có gợi ý từ bước chụp ảnh.
- Nhập tên tác giả, dịch giả: gợi ý từ bước chụp ảnh; thêm, bớt tác giả, dịch giả.
- Nhập vị trí; thêm, bớt vị trí (tương ứng số lượng quyển sách), không bắt buộc gán vị trí ngay. Gợi ý vị trí khi gõ.
- Nhập đơn vị phát hảnh: gợi ý từ bước chụp ảnh, từ danh sách đã có; thêm, bớt đơn vị.
- Nhãn: thêm nhãn, chọn kiểu nhãn, nhập giá trị nhãn. Nhãn thêm mới sẽ làm nhãn chung cho tất cả các sách.

### B.II. Tra cứu

#### B.II.1 Tìm kiếm

- Quét mã ISBN.
- Tìm theo các tiêu chí (AND): tên, đơn vị phát hành, tác giả, dịch giả, nhãn (nhãn kiểu mã vạch thì cần chức năng quét mã).

#### B.II.2 Hiển thị chi tiết

- Hiển thị thông tin.
- Chỉnh sửa thông tin.
- Xóa sách.

### B.III. Di chuyển sách

- Quét mã ISBN để xác định sách rời vị trí. Trường hợp sách có nhiều vị trí (nhiều cuốn) thì hiển thị hộp thoại chọn hoặc quét tiếp mã QR vị trí để xác định vị trí rời đi.
- Quét mã QR vị trí để xác định vị trí mới sách di chuyển đến hoặc nhập văn bản để chọn.
- Giữa các bước có hộp thoại xác nhận hoàn thành. Có thể tiếp tục quét để hoàn thành các bước mà không cần ấn xác nhận.

### B.IV. Quản lý danh sách đơn vị xuất bản

- Thêm.
- Sửa.
- Xóa.

### B.V. Quản lý danh sách vị trí sách

- Thêm.
- Sửa.
- Xóa.
- Sinh mã QR. Có thể tập hợp nhiều mã QR để tạo PDF.

### B.VI. Khác

- Giới thiệu, bản quyền.
- Xuất dữ liệu (sao lưu): zip, csv, json. Nhập dữ liệu.
- Cấu hình: âm thanh khi quét mã vạch.
- Xóa các nhãn thừa.
- Hướng dẫn sử dụng.
- Thống kê: số lượng sách, số lượng quyển sách, số lượng theo từng nhà xuất bản, tổng giá trị theo từng nhãn loại số.
- Đánh dấu sách.
