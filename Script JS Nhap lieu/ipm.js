function layDanhSachSach() {
    let sach = {};
    sach["nxb"] = "IPM";
    sach["ten"] = document.getElementsByClassName("product-title")[0].children[0].textContent.trim();
    sach["anh"] = document.getElementsByClassName("product-image-feature-slider")[0].getElementsByClassName("owl-item active")[0].children[0].href;
    let tagGia = document.getElementById("price-preview").children;
    if (tagGia.length > 1) {
        sach["nhan:Giá bìa:so:hien"] = tagGia[1].textContent.trim();
    } else {
        sach["nhan:Giá bìa:so:hien"] = tagGia[0].textContent.trim();
    }
    for (const divRow of document.getElementsByClassName("box-tag")[0].children[0].children) {
        if (divRow.children.length > 1) {
            let ten = divRow.children[0].textContent.trim();
            let giaTri = divRow.children[1].textContent.trim();
            if (ten === "Tác giả") {
                sach["tac_gia"] = giaTri;
            } else if (ten === "Nhà xuất bản") {
                sach["nxb"] = giaTri + ";" + sach["nxb"];
            }
        }
    }

    let ketQua = [sach];
    return ketQua;
}
