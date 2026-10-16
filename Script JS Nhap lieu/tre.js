function layDanhSachSach() {
    let sach = {};
    sach["nxb"] = "Trẻ";
    sach["ten"] = document.getElementsByClassName("titleAut")[0].textContent.trim();
    sach["anh"] = document.getElementById("Content_ctl00_imgMain").src;
    for (const muc of document.getElementsByClassName("itemDetail-cat")[0].children) {
        let ten = muc.textContent;
        if (ten.indexOf("Tác giả:") === 0) {
            let giaTri =  muc.children[0].textContent.trim();
            sach["tac_gia"] = giaTri;
        } else if (ten.indexOf("Dịch giả:") === 0) {
            let giaTri =  muc.children[0].textContent.trim();
            sach["dich_gia"] = giaTri;
        } else if (ten.indexOf("Số trang:") === 0) {
            let giaTri =  muc.children[0].textContent.trim();
            sach["nhan:Số trang:so"] = giaTri;
        } else if (ten.indexOf("Giá bán:") === 0) {
            let giaTri =  muc.children[0].textContent.trim();
            sach["nhan:Giá bìa:so:hien"] = giaTri;
        } else if (ten.indexOf("ISBN:") === 0) {
            let giaTri =  muc.children[0].textContent.trim();
            sach["isbn"] = giaTri.substring(0, 17);
        }
    }
    let ketQua = [sach];
    return ketQua;
}
