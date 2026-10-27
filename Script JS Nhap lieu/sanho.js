function layDanhSachSach() {
    let sach = {};
    sach["nxb"] = "San Hô";
    const dsAnh = document.getElementsByClassName("bpfw-flip bpfw-flip-front")[0].children[0].srcset.split(",");
    let anh = dsAnh[dsAnh.length - 1];
    anh = anh.substring(0, anh.lastIndexOf(" "));
    sach["anh"] = anh.trim();
    sach["ten"] = document.getElementsByClassName("product_title")[0].textContent.trim();

    sach["nhan:Giá bìa:so:hien"] = document.getElementsByClassName("woocommerce-Price-amount")[0].textContent;
    const noiDung = document.getElementsByClassName("woocommerce-product-details__short-description")[0].innerText.split("\\n");
    for (const dong of noiDung) {
        let haiCham = dong.indexOf(":");
        if (haiCham > 0) {
            let ten = dong.substring(0, haiCham).trim();
            let giaTri = dong.substring(haiCham + 1).trim();
            if (ten.includes("Tiêu đề") || ten.includes("Tên sách")) {
                sach["ten"] = giaTri;
            } else if (ten.includes("Tác giả")) {
                sach["tac_gia"] = giaTri;
            } else if (ten.includes("Dịch giả") || ten.includes("Người dịch")) {
                sach["dich_gia"] = giaTri;
            } else if (ten.includes("Số trang")) {
                sach["nhan:Số trang:so"] = giaTri;
            } else if (ten.includes("Giá bìa")) {
                sach["nhan:Giá bìa:so:hien"] = giaTri;
            } else if (ten.includes("Ngôn ngữ")) {
                sach["nhan:Ngôn ngữ"] = giaTri;
            } else if (ten.includes("ISBN")) {
                sach["isbn"] = giaTri;
            } else if (ten.includes("Nhà xuất bản") || ten.includes("NXB")) {
                let gt = giaTri;
                const sttGach = gt.indexOf("–");
                if (sttGach > 0) {
                    gt = gt.substring(0, sttGach);
                }
                gt = gt.replaceAll("NXB", "").replaceAll("Nhà xuất bản", "").trim();
                sach["nxb"] = gt + ";" + sach["nxb"];
            }
        }
    }
    let ketQua = [sach];
    return ketQua;
}
