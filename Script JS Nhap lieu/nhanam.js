function layDanhSachSach() {
    let sach = {};
    sach["nxb"] = "Nhã Nam";
    sach["ten"] = document.getElementsByClassName("title-page")[0].textContent;
    sach["anh"] = document.getElementById("lightgallery").children[0].href;
    sach["nhan:Giá bìa:so:hien"] = document.getElementsByClassName("product-price-old")[0].textContent.trim();
    for (const muc of document.getElementsByClassName("book-info-detail")[0].children) {
        let ten = muc.children[0].textContent.trim();
        let giaTri =  muc.children[1].textContent.trim();
        if (ten === "Tác giả") {
            sach["tac_gia"] = giaTri;
        }
        if (ten === "Dịch giả") {
            sach["dich_gia"] = giaTri;
        }
        if (ten === "Nhà xuất bản") {
            sach["nxb"] = giaTri + ";" + sach["nxb"];
        }
        if (ten === "Số trang" && giaTri !== "Đang cập nhật") {
            sach["nhan:Số trang:so"] = giaTri;
        }
    }
    let ketQua = [sach];
    return ketQua;
}
