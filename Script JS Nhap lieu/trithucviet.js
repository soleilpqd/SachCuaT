
function layDanhSachSach() {
    let sach = {};
    sach["nxb"] = "Trí Thức Việt";
    sach["ten"] = document.getElementsByClassName("product-name")[0].textContent.trim();
    sach["anh"] = document.getElementById("zoom1").href;
    sach["nhan:Giá bìa:so:hien"] = document.getElementsByClassName("product-name")[0].parentElement.getElementsByClassName("old-price")[0].textContent.trim();
    if (sach["nhan:Giá bìa:so:hien"].length === 0) {
        sach["nhan:Giá bìa:so:hien"] = document.getElementsByClassName("product-name")[0].parentElement.getElementsByClassName("special-price")[0].textContent.trim();
    }
    const noiDung = document.getElementById("productTabContent").innerText.split("\\n");
    for (const dong of noiDung) {
        let haiCham = dong.indexOf(":");
        if (haiCham > 0) {
            let ten = dong.substring(0, haiCham).trim().toLowerCase();
            let giaTri = dong.substring(haiCham + 1).trim();
            if (ten.includes("tác giả")) {
                sach["tac_gia"] = giaTri;
            } else if (ten.includes("dịch")) {
                sach["dich_gia"] = giaTri;
            } else if (ten.includes("isbn") || ten.includes("mã vạch")) {
                sach["isbn"] = giaTri;
            } else if (ten.includes("số trang")) {
                sach["nhan:Số trang:so"] = giaTri;
            } else if (ten.includes("nhà xuất bản")) {
                sach["nxb"] = giaTri + ";" + sach["nxb"];
            }
        }
    }
    let ketQua = [sach];
    return ketQua;
}
