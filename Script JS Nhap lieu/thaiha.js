function layDanhSachSach() {
    let sach = {};
    sach["nxb"] = "Thái Hà";
    sach["anh"] = document.getElementsByClassName("slick-current")[0].children[0].href;
    let contents = document.getElementById("content").children;
    for (const table of contents) {
        if (table.tagName === "TABLE") {
            let tbody = table.children[0];
            for (const tr of tbody.children) {
                let ten = tr.children[0].textContent.trim();
                let giaTri =  tr.children[1].textContent.trim();
                if (ten === "Tên sách") {
                    sach["ten"] = giaTri;
                } else if (ten === "Tác giả") {
                    sach["tac_gia"] = giaTri;
                } else if (ten === "Nhà xuất bản") {
                    sach["nxb"] = giaTri + ";" + sach["nxb"];
                } else if (ten === "Số trang") {
                    sach["nhan:Số trang:so"] = giaTri;
                } else if (ten === "Giá") {
                    sach["nhan:Giá bìa:so:hien"] = giaTri;
                } else if ((ten.includes("Barcode") || ten.includes("ISBN")) && giaTri.includes(" ")) {
                    sach["isbn"] = giaTri.substring(giaTri.lastIndexOf(" ") + 1).trim();
                }
            }
        }
    }
    let ketQua = [sach];
    return ketQua;
}
