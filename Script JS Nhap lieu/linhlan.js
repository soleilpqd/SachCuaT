function layDanhSachSach() {
    let sach = {};
    sach["nxb"] = "Linh Lan";
    let tagTen = document.getElementsByClassName("title-head fixitem-title")[0];
    sach["ten"] = tagTen.textContent.trim();
    let tagAnh = document.getElementsByClassName("kiti active");
    if (tagAnh.length === 0) {
        tagAnh = document.getElementById("zoom_01").parentElement.parentElement.children[1].children[0].children;
    }
    sach["anh"] = tagAnh[0].attributes["data-image"].textContent;
    let tagGia = tagTen.parentElement.getElementsByClassName("product-price-old");
    if (tagGia.length === 0) {
        tagGia = tagTen.parentElement.getElementsByClassName("product-price");
    }
    sach["nhan:Giá bìa:so:hien"] = tagGia[0].textContent.trim();
    const noiDung = document.getElementsByClassName("short-description")[0].innerText.split("\\n");
    for (const dong of noiDung) {
        let haiCham = dong.indexOf(":");
        if (haiCham > 0) {
            let ten = dong.substring(0, haiCham).trim();
            let giaTri = dong.substring(haiCham + 1).trim();
            if (ten === "Tác giả") {
                sach["tac_gia"] = giaTri;
            } else if (ten === "Số trang") {
                sach["nhan:Số trang:so"] = giaTri;
            } else if (ten === "NXB") {
                sach["nxb"] = giaTri + ";" + sach["nxb"];
            }
        }
    }
    let ketQua = [sach];
    return ketQua;
}
