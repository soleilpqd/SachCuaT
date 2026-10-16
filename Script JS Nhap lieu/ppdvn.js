function layDanhSachSach() {
    let ketQua = [];
    let tuKhoa = ["stt", "isbn", "ten", "tac_gia", "bien_tap_vien", "nxb", "doi_tac", "in", "ngay"]
    const divKetQua = document.getElementById("list_data_return");
    if (divKetQua != null) {
        divKetQua.childNodes.forEach(function (divKqItem, divKqIndex, divKqList) {
            if (divKqItem.tagName == "TABLE") {
                divKqItem.childNodes.forEach(function (tableItem, tableIndex, tableList) {
                    if (tableItem.tagName == "TBODY") {
                        tableItem.childNodes.forEach(function (tbodyItem, tbodyIndex, tbodyList) {
                            if (tbodyItem.tagName == "TR") {
                                let sach = {};
                                let stt = 0;
                                tbodyItem.childNodes.forEach(function (trItem, trIndex, trList) {
                                    if (trItem.tagName == "TD") {
                                        sach[tuKhoa[stt]] = trItem.textContent;
                                        stt += 1;
                                    }
                                })
                                ketQua.push(sach);
                            }
                        })
                    }
                })
            }
        })
    }
    return ketQua;
}
