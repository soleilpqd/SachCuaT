function layDanhSachSach() {
    let sach = {};
    sach["nxb"] = "Tao Đàn";

    const divImage = document.getElementById("sync1").children[0].children[0];
    let doLech = divImage.style["transform"];
    doLech = doLech.substring(doLech.indexOf("(") + 1);
    if (doLech.indexOf("-") === 0) {
        doLech = doLech.substring(1);
    }
    doLech = doLech.substring(0, doLech.indexOf("px"));
    let doLechHienTai = 0;
    for (const muc of divImage.children) {
        let mucW = muc.style["width"];
        mucW = mucW.substring(0, mucW.indexOf("px"));
        doLechHienTai += Number(mucW);
        if (doLechHienTai > doLech) {
            sach["anh"] = muc.children[0].children[0].src;
            break;
        }
    }

    const divTab1 = document.getElementById("tab-1");
    for (const muc of divTab1.children[0].children) {
        if (muc.tagName === "TABLE") {
            const tbody = muc.children[0];
            for (const tr of tbody.children) {
                let sttTd = 0;
                let khoa = "";
                let giaTri = "";
                for (const td of tr.children) {
                    if (sttTd % 2 === 0) {
                        khoa = td.textContent.trim();
                    } else {
                        giaTri = td.textContent.trim();
                    }
                    sttTd += 1;
                }
                if (khoa === "Tác phẩm") {
                    sach["ten"] = giaTri;
                } else if (khoa === "Tác giả") {
                    sach["tac_gia"] = giaTri;
                } else if (khoa === "Dịch giả") {
                    sach["dich_gia"] = giaTri;
                } else if (khoa === "Nhà xuất bản") {
                    sach["nxb"] = giaTri + ";" + sach["nxb"];
                } else if (khoa === "Số trang") {
                    sach["nhan:Số trang:so"] = giaTri;
                } else if (khoa === "Giá bìa") {
                    sach["nhan:Giá bìa:so:hien"] = giaTri;
                } else if (khoa === "ISBN") {
                    sach["isbn"] = giaTri;
                }
            }
        }
    }

    let ketQua = [sach];
    return ketQua;
}
