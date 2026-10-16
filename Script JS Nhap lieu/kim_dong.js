function layDanhSachSach() {
    let sach = {};
    sach["nxb"] = "Kim Đồng";
    sach["ten"] = document.getElementsByClassName("title-head")[0].textContent;
    sach["nhan:Giá bìa:so:hien"] = document.getElementsByClassName("product-price-old")[0].textContent;
    sach["anh"] = document.getElementById("lightgallery").children[0].children[0].getAttribute("data-zoom");
    let danhSach = document.getElementsByClassName("summary")[0].children[0].children;
    for (const muc of danhSach) {
        const noiDung = muc.textContent.trim();
        if (noiDung.indexOf("ISBN") == 0) {
            sach["isbn"] = noiDung.substring(5).trim();
        }
        if (noiDung.indexOf("Tác giả") == 0) {
            let tacGia = "";
            let stt = 0;
            for (const mucTg of muc.children) {
                tacGia += mucTg.textContent;
                if (stt < muc.children.length - 1) {
                    tacGia += ";"
                }
                stt += 1;
            }
            sach["tac_gia"] = tacGia;
        }
        if (noiDung.indexOf("Số trang") == 0) {
            sach["nhan:Số trang:so"] = noiDung.substring(9).trim();
        }
    }
    let ketQua = [sach];
    return ketQua;
}
