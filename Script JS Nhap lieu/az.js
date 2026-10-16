function layDanhSachSach() {
    let sach = {};
    sach["ten"] = document.getElementsByClassName("product-heading")[0].children[0].textContent;
    if (sach["ten"].indexOf("Sách") === 0) {
        sach["ten"] = sach["ten"].substring(7);
    }
    sach["anh"] = document.getElementsByClassName("owl-item active")[0].children[0].children[0].children[0].children[0].href;
    let gia = document.getElementById("price-preview").children;
    for (const muc of gia) {
        if (muc.tagName === "DEL") {
            sach["nhan:Giá bìa:so:hien"] = muc.textContent;
        }
    }
    let contents = document.getElementById("nav-desc").children[0].children[0].children[0].innerText.split('\n');
    for (const muc of contents) {
        if (muc.indexOf("Tác giả") === 0) {
            sach["tac_gia"] = muc.substring(8).trim();
        } else if (muc.indexOf("Dịch giả") === 0) {
            sach["dich_gia"] = muc.substring(9).trim();
        } else if (muc.indexOf("Nhà xuất bản") === 0 || muc.indexOf("Thương hiệu") === 0) {
            let giaTri = muc;
            if (muc.indexOf("Nhà xuất bản") === 0) {
                giaTri = muc.substring(13);
            } else {
                giaTri = muc.substring(12);
            }
            if (sach["nxb"]) {
                sach["nxb"] += ";" + giaTri;
            } else {
                sach["nxb"] = giaTri;
            }
        } else if (muc.indexOf("Số trang") === 0) {
            sach["nhan:Số trang:so"] = muc.substring(9);
        } else if (muc.includes("ISBN")) {
            sach["isbn"] = muc.substring(muc.lastIndexOf(" ") + 1);
        }
    }
    let ketQua = [sach];
    return ketQua;
}
