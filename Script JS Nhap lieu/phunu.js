function layDanhSachSach() {
    let sach = {};
    sach["nxb"] = "Phụ nữ Việt Nam";
    sach["ten"] = document.getElementsByClassName("BookDetailSection-title")[0].textContent.trim();
    sach["anh"] = document.getElementsByClassName("BookDetailSection-preview-carousel-item")[0].children[0].src;
    sach["tac_gia"] = document.getElementsByClassName("des_info-title")[0].textContent.trim();
    let tableBody = document.getElementsByClassName("details-table-list-wrapper")[0].children[0].children[0];
    if (tableBody.tagName === "TBODY") {
        for (const tr of tableBody.children) {
            let sttTd = 0;
            let khoa = "";
            let giaTri = "";
            for (const td of tr.children) {
                if (sttTd % 2 === 0) {
                    khoa = td.textContent.trim();
                } else {
                    giaTri = td.textContent.trim();
                    if (khoa === "Số trang:") {
                        sach["nhan:Số trang:so"] = giaTri;
                    } else if (khoa === "Quốc gia:" && giaTri.length > 0) {
                        sach["nhan:Quốc gia"] = giaTri;
                    } else if (khoa === "Mã ISBN:") {
                        sach["isbn"] = giaTri;
                    }
                }
                sttTd += 1;
            }
        }
    }
    let ketQua = [sach];
    return ketQua;
}
