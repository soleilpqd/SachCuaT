function layDanhSachSach() {
    let sach = {};
    sach["nxb"] = "1980 Books";
    sach["ten"] = document.getElementsByClassName("product-heading")[0].children[0].textContent.trim();
    sach["anh"] = document.getElementsByClassName("product-gallery slick-slide slick-current slick-active")[0].children[0].href;
    const divGia = document.getElementById("price-preview");
    for (const muc of divGia.children) {
        if (muc.tagName === "DEL") {
            sach["nhan:Giá bìa:so:hien"] = muc.textContent.trim();
            break;
        }
    }
    const divMieuTa = document.getElementsByClassName("description-productdetail")[0];
    for (const muc of divMieuTa.children) {
        const dong = muc.textContent.trim();
        const haiCham = dong.indexOf(":");
        if (haiCham >= 0) {
            const khoa = dong.substring(0, haiCham).trim().toUpperCase();
            const giaTri = dong.substring(haiCham + 1).trim();
            if (giaTri.length > 0) {
                if (khoa === "TÁC GIẢ") {
                    sach["tac_gia"] = giaTri;
                } else if (khoa === "DỊCH GIẢ") {
                    sach["dich_gia"] = giaTri;
                } else if (khoa === "SỐ TRANG") {
                    sach["nhan:Số trang:so"] = giaTri;
                } else if (khoa.indexOf("NXB") === 0) {
                    sach["nxb"] = giaTri.replaceAll("NXB", "").trim() + ";" + sach["nxb"];
                }
            }
        }
    }
    let ketQua = [sach];
    return ketQua;
}
