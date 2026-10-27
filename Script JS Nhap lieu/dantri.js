function layDanhSachSach() {
    let sach = {};
    sach["nxb"] = "Dân Trí";
    sach["ten"] = document.getElementsByClassName("product_title entry-title")[0].textContent.replaceAll("–", "").trim();
    sach["anh"] = document.getElementsByClassName("woocommerce-product-gallery__image")[0].children[0].href;

    let noiDung = document.getElementsByClassName("woocommerce-product-details__short-description")[0].innerText.split("\\n");
    let stt = 0;
    while (stt < noiDung.length) {
        const muc = noiDung[stt];
        if (muc.includes("–")) {
            const mucCon = muc.split("–");
            if (mucCon.length > 2) {
                for (const mCon of mucCon) {
                    const mmCon = mCon.trim();
                    if (mmCon.length > 0) {
                        noiDung.push(mmCon);
                    }
                }
                stt += 1;
                continue;
            }
        }
        let haiCham = muc.indexOf(":");
        if (haiCham > 0) {
            let ten = muc.substring(0, haiCham).trim();
            let giaTri = muc.substring(haiCham + 1).trim();
            if (ten.includes("Tác giả")) {
                sach["tac_gia"] = giaTri.replaceAll("Chủ biên:", "").trim();
            } else if (ten.includes("Dịch giả")) {
                sach["dich_gia"] = giaTri;
            } else if (ten.includes("ISBN")) {
                sach["isbn"] = giaTri;
            } else if (ten.includes("Số trang")) {
                sach["nhan:Số trang:so"] = giaTri;
            } else if (ten.includes("Giá bìa")) {
                sach["nhan:Giá bìa:so:hien"] = giaTri;
            } else if (ten.includes("liên kết ")) {
                sach["nxb"] += ";" + giaTri;
            }
        }
        stt += 1;
    }
    let ketQua = [sach];
    return ketQua;
}
