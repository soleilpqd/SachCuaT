function layDanhSachSach() {
    let sach = {};
    sach["nxb"] = "ĐINH TỊ";
    for (const muc of document.getElementsByClassName("mySlides")) {
        if (muc.style["display"] === "block" || muc.style["display"] === "") {
            sach["anh"] = muc.src;
            break;
        }
    }

    const noiDung = document.getElementsByClassName("info-prd")[0].children[0].children[0].innerText.trim().split("\\n");
    let stt = 0;
    for (const dong of noiDung) {
        if (stt === 0) {
            sach["ten"] = dong.trim();
            stt += 1;
            continue;
        }
        let haiCham = dong.indexOf(":");
        if (haiCham > 0) {
            let ten = dong.substring(0, haiCham).trim().toLowerCase();
            let giaTri = dong.substring(haiCham + 1).trim();
            if (ten === "tác giả") {
                sach["tac_gia"] = giaTri;
            } else if (ten === "dịch giả") {
                sach["dich_gia"] = giaTri;
            } else if (ten === "số trang") {
                sach["nhan:Số trang:so"] = giaTri;
            } else if (ten === "giá") {
                const gt = giaTri.split(" ");
                if (gt.length > 1) {
                    sach["nhan:Giá bìa:so:hien"] = gt[1];
                }
            } else if (ten === "nhà xuất bản") {
                sach["nxb"] = giaTri.replaceAll("NXB", "").replaceAll("Nhà xuất bản", "").trim() + ";" + sach["nxb"];
            }
        }
        stt += 1;
    }
    let ketQua = [sach];
    return ketQua;
}
