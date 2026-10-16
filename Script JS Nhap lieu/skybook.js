function layDanhSachSach() {
    let sach = {};
    sach["nxb"] = "Sky Books";
    sach["ten"] = document.getElementsByClassName("title-product")[0].textContent.trim();
    sach["anh"] = document.getElementsByClassName("img_bigg slick-slide slick-current slick-active")[0].href;

    let content = document.getElementById("content");
    for (const table of content.children) {
        if (table.tagName === "TABLE") {
            const tbody = table.children[0];
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
                if (khoa === "Tác giả") {
                    sach["tac_gia"] = giaTri;
                } else if (khoa === "Người Dịch") {
                    sach["dich_gia"] = giaTri;
                } else if (khoa === "NXB" && giaTri.length > 0) {
                    sach["nxb"] = giaTri + ";" + sach["nxb"];
                } else if (khoa === "Số trang") {
                    sach["nhan:Số trang:so"] = giaTri;
                }
            }
        }
    }
    let ketQua = [sach];
    return ketQua;
}
