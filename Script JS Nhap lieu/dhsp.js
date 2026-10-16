function layDanhSachSach() {
    let sach = {};
    sach["nxb"] = "Đại học Sư Phạm";
    sach["ten"] = document.getElementsByClassName("w-full md:w-1/3")[1].children[0].children[0].children[0].textContent.trim();
    sach["anh"] = document.getElementById("cover-image-product").src;
    sach["nhan:Giá bìa:so:hien"] = document.getElementsByClassName("w-full md:w-1/3")[1].children[0].children[1].children[0].children[0].children[0].textContent.trim();

    for (const muc of document.getElementsByClassName("w-full md:w-1/3")[2].children[0].children) {
        if (muc.className === "flex mt-12") {
            let ten = "";
            let giaTri =  "";
            let sttMuc = 0;
            for (const muc2 of muc.children) {
                if (sttMuc % 2 === 0) {
                    ten = muc2.textContent.trim();
                } else {
                    giaTri = muc2.textContent.trim();
                }
                sttMuc += 1;
            }
            if (ten === "Tác giả") {
                sach["tac_gia"] = giaTri;
            } else if (ten === "Số trang") {
                sach["nhan:Số trang:so"] = giaTri;
            } else if (ten.includes("ISBN")) {
                sach["isbn"] = giaTri;
            }
        }
    }
    let ketQua = [sach];
    return ketQua;
}
