function layDanhSachSach() {
    let sach = {};
    sach["nxb"] = "Phúc Minh";

    const divImage = document.getElementsByClassName("owl-stage")[0];
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
            sach["anh"] = muc.children[0].src;
            break;
        }
    }

    const divTen = document.getElementsByClassName("product-title");
    sach["ten"] = divTen[divTen.length - 1].textContent.trim();

    const noiDung = document.getElementsByClassName("goods-subtitle")[0].innerText.trim().split("\\n");
    for (const muc of noiDung) {
        let haiCham = muc.indexOf(":");
        if (haiCham > 0) {
            let ten = muc.substring(0, haiCham).trim();
            let giaTri = muc.substring(haiCham + 1).trim();
            if (ten === "Tác giả") {
                sach["tac_gia"] = giaTri;
            } else if (ten === "Số trang") {
                sach["nhan:Số trang:so"] = giaTri;
            } else if (ten === "Giá bìa") {
                sach["nhan:Giá bìa:so:hien"] = giaTri;
            } else if (ten === "Dịch giả") {
                sach["dich_gia"] = giaTri;
            } else if (ten.includes("ISBN")) {
                sach["isbn"] = giaTri;
            } else if (ten === "Nhà xuất bản") {
                sach["nxb"] = giaTri + ";" + sach["nxb"];
            }
        } else if (muc.includes("Nhà xuất bản")) {
            sach["nxb"] = muc.replaceAll("Nhà xuất bản", "").trim() + ";" + sach["nxb"];
        }
    }
    if (sach["nhan:Giá bìa:so:hien"] === undefined) {
        sach["nhan:Giá bìa:so:hien"] = document.getElementById("price-preview").textContent.trim();
    }
    let ketQua = [sach];
    return ketQua;
}
