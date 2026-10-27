function layDanhSachSach() {
    let sach = {};
    sach["nxb"] = "Đông A";

    const divImage = document.getElementById("ProductPhoto").children[0].children[0];
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
            sach["anh"] = muc.children[0].children[0].children[0].src;
            break;
        }
    }

    sach["ten"] = document.getElementsByClassName("pro-content-head clearfix")[0].children[0].textContent.trim();

    const content = document.getElementsByClassName("content")[0].innerText.trim().split("\\n");
    for (const muc of content) {
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
            }
        } else if (muc.includes("NXB")) {
            let gt = muc.substring(muc.indexOf("NXB") + 3);
            const sttLk = gt.indexOf("liên kết");
            if (sttLk >= 0) {
                gt = gt.substring(0, sttLk);
            }
            gt = gt.replaceAll(".", "").trim();
            sach["nxb"] = gt + ";" + sach["nxb"];
        }
    }
    if (sach["nhan:Giá bìa:so:hien"] === undefined) {
        sach["nhan:Giá bìa:so:hien"] = document.getElementsByClassName("original-price ComparePrice")[0].textContent.trim();
    }
    let ketQua = [sach];
    return ketQua;
}
