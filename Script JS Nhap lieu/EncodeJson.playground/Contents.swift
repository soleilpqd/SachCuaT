import Cocoa

struct MaLenh: Encodable {
    let ma: String
    let loc_regex: [String]
    let loc_chinh_xac: [String]
    let bo_regex: [String]
    let bo_chinh_xac: [String]
}

struct NoiDung: Encodable {
    let ma_lenh: [MaLenh]
}

let noiDung = NoiDung(
    ma_lenh: [
        // PPDVN
        MaLenh(
            ma: """
function layDanhSachSach(){let ketQua=[],tuKhoa=["stt","isbn","ten","tac_gia","bien_tap_vien","nxb","doi_tac","in","ngay"];const divKetQua=document.getElementById("list_data_return");return null!=divKetQua&&divKetQua.childNodes.forEach((function(divKqItem,divKqIndex,divKqList){"TABLE"==divKqItem.tagName&&divKqItem.childNodes.forEach((function(tableItem,tableIndex,tableList){"TBODY"==tableItem.tagName&&tableItem.childNodes.forEach((function(tbodyItem,tbodyIndex,tbodyList){if("TR"==tbodyItem.tagName){let sach={},stt=0;tbodyItem.childNodes.forEach((function(trItem,trIndex,trList){"TD"==trItem.tagName&&(sach[tuKhoa[stt]]=trItem.textContent,stt+=1)})),ketQua.push(sach)}}))}))})),ketQua}
""",
            loc_regex: [
                "https://ppdvn.gov.vn/web/guest/tra-cuu-luu-chieu.*",
                "https://ppdvn.gov.vn/web/guest/ke-hoach-xuat-ban.*"
            ],
            loc_chinh_xac: [],
            bo_regex: [],
            bo_chinh_xac: []
        ),
        // Kim dong
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={nxb:"Kim Đồng"};sach.ten=document.getElementsByClassName("title-head")[0].textContent,sach["nhan:Giá bìa:so:hien"]=document.getElementsByClassName("product-price-old")[0].textContent,sach.anh=document.getElementById("lightgallery").children[0].children[0].getAttribute("data-zoom");let danhSach=document.getElementsByClassName("summary")[0].children[0].children,ketQua;for(const muc of danhSach){const noiDung=muc.textContent.trim();if(0==noiDung.indexOf("ISBN")&&(sach.isbn=noiDung.substring(5).trim()),0==noiDung.indexOf("Tác giả")){let tacGia="",stt=0;for(const mucTg of muc.children)tacGia+=mucTg.textContent,stt<muc.children.length-1&&(tacGia+=";"),stt+=1;sach.tac_gia=tacGia}0==noiDung.indexOf("Số trang")&&(sach["nhan:Số trang:so"]=noiDung.substring(9).trim())}return[sach]}
""",
            loc_regex: [
                "^https://nxbkimdong.com.vn/[^/?]*$"
            ],
            loc_chinh_xac: [],
            bo_regex: [
                "^https://nxbkimdong.com.vn/search.*$"
            ],
            bo_chinh_xac: []
        ),
        // Nha Nam
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={nxb:"Nhã Nam"};sach.ten=document.getElementsByClassName("title-page")[0].textContent,sach.anh=document.getElementById("lightgallery").children[0].href;let tagGia=document.getElementsByClassName("product-price-old"),ketQua;0===tagGia.length&&(tagGia=document.getElementsByClassName("product-price")),sach["nhan:Giá bìa:so:hien"]=tagGia[0].textContent.trim();for(const muc of document.getElementsByClassName("book-info-detail")[0].children){let ten=muc.children[0].textContent.trim(),giaTri=muc.children[1].textContent.trim();"Tác giả"===ten&&(sach.tac_gia=giaTri),"Dịch giả"===ten&&(sach.dich_gia=giaTri),"Nhà xuất bản"!==ten||giaTri.toLowerCase().includes("nhã nam")||(sach.nxb=giaTri+";"+sach.nxb),"Số trang"===ten&&"Đang cập nhật"!==giaTri&&(sach["nhan:Số trang:so"]=giaTri)}return[sach]}
""",
            loc_regex: [
                "^https://nhanam.vn/[^/?]*$"
            ],
            loc_chinh_xac: [],
            bo_regex: [
                "^https://nhanam.vn/search.*$"
            ],
            bo_chinh_xac: []
        ),
        // Tre
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={nxb:"Trẻ"},ketQua;sach.ten=document.getElementsByClassName("titleAut")[0].textContent.trim(),sach.anh=document.getElementById("Content_ctl00_imgMain").src;for(const muc of document.getElementsByClassName("itemDetail-cat")[0].children){let ten=muc.textContent;if(0===ten.indexOf("Tác giả:")){let giaTri=muc.children[0].textContent.trim();sach.tac_gia=giaTri}else if(0===ten.indexOf("Dịch giả:")){let giaTri=muc.children[0].textContent.trim();sach.dich_gia=giaTri}else if(0===ten.indexOf("Số trang:")){let giaTri=muc.children[0].textContent.trim();sach["nhan:Số trang:so"]=giaTri}else if(0===ten.indexOf("Giá bán:")){let giaTri=muc.children[0].textContent.trim();sach["nhan:Giá bìa:so:hien"]=giaTri}else if(0===ten.indexOf("ISBN:")){let giaTri=muc.children[0].textContent.trim();sach.isbn=giaTri.substring(0,17)}}return[sach]}
""",
            loc_regex: [
                "^https://www.nxbtre.com.vn/sach/[^/?]*\\.html$"
            ],
            loc_chinh_xac: [],
            bo_regex: [],
            bo_chinh_xac: []
        ),
        // Thai Ha
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={nxb:"Thái Hà"};sach.anh=document.getElementsByClassName("slick-current")[0].children[0].href;let contents=document.getElementById("content").children,ketQua;for(const table of contents)if("TABLE"===table.tagName){let tbody=table.children[0];for(const tr of tbody.children){let ten=tr.children[0].textContent.trim(),giaTri=tr.children[1].textContent.trim();"Tên sách"===ten?sach.ten=giaTri:"Tác giả"===ten?sach.tac_gia=giaTri:"Nhà xuất bản"===ten?sach.nxb=giaTri+";"+sach.nxb:"Số trang"===ten?sach["nhan:Số trang:so"]=giaTri:"Giá"===ten?sach["nhan:Giá bìa:so:hien"]=giaTri:(ten.includes("Barcode")||ten.includes("ISBN"))&&giaTri.includes(" ")&&(sach.isbn=giaTri.substring(giaTri.lastIndexOf(" ")+1).trim())}}return[sach]}
""",
            loc_regex: [
                "^https://thaihabooks.com/products/[^/?]*$"
            ],
            loc_chinh_xac: [],
            bo_regex: [],
            bo_chinh_xac: []
        ),
        // AZ
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={};sach.ten=document.getElementsByClassName("product-heading")[0].children[0].textContent,0===sach.ten.indexOf("Sách")&&(sach.ten=sach.ten.substring(7)),sach.anh=document.getElementsByClassName("owl-item active")[0].children[0].children[0].children[0].children[0].href;let gia=document.getElementById("price-preview").children;for(const muc of gia)"DEL"===muc.tagName&&(sach["nhan:Giá bìa:so:hien"]=muc.textContent);let contents=document.getElementById("nav-desc").children[0].children[0].children[0].innerText.split("\\n"),ketQua;for(const muc of contents)if(0===muc.indexOf("Tác giả"))sach.tac_gia=muc.substring(8).trim();else if(0===muc.indexOf("Dịch giả"))sach.dich_gia=muc.substring(9).trim();else if(0===muc.indexOf("Nhà xuất bản")||0===muc.indexOf("Thương hiệu")){let giaTri=muc;giaTri=0===muc.indexOf("Nhà xuất bản")?muc.substring(13):muc.substring(12),sach.nxb?sach.nxb+=";"+giaTri:sach.nxb=giaTri}else 0===muc.indexOf("Số trang")?sach["nhan:Số trang:so"]=muc.substring(9):muc.includes("ISBN")&&(sach.isbn=muc.substring(muc.lastIndexOf(" ")+1));return[sach]}
""",
            loc_regex: [
                "^https://azvietnam.vn/products/[^/?]*$"
            ],
            loc_chinh_xac: [],
            bo_regex: [],
            bo_chinh_xac: []
        ),
        // Phu nu VN
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={nxb:"Phụ nữ Việt Nam"};sach.ten=document.getElementsByClassName("BookDetailSection-title")[0].textContent.trim(),sach.anh=document.getElementsByClassName("BookDetailSection-preview-carousel-item")[0].children[0].src,sach.tac_gia=document.getElementsByClassName("des_info-title")[0].textContent.trim();let tableBody=document.getElementsByClassName("details-table-list-wrapper")[0].children[0].children[0],ketQua;if("TBODY"===tableBody.tagName)for(const tr of tableBody.children){let sttTd=0,khoa="",giaTri="";for(const td of tr.children)sttTd%2==0?khoa=td.textContent.trim():(giaTri=td.textContent.trim(),"Số trang:"===khoa?sach["nhan:Số trang:so"]=giaTri:"Quốc gia:"===khoa&&giaTri.length>0?sach["nhan:Quốc gia"]=giaTri:"Mã ISBN:"===khoa&&(sach.isbn=giaTri)),sttTd+=1}return[sach]}
""",
            loc_regex: [
                "^https://sach.nxbphunu.com.vn/[^/?]*\\.html$"
            ],
            loc_chinh_xac: [],
            bo_regex: [],
            bo_chinh_xac: []
        ),
        // SkyBooks
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={nxb:"Sky Books"};sach.ten=document.getElementsByClassName("title-product")[0].textContent.trim(),sach.anh=document.getElementsByClassName("img_bigg slick-slide slick-current slick-active")[0].href;let content=document.getElementById("content"),ketQua;for(const table of content.children)if("TABLE"===table.tagName){const tbody=table.children[0];for(const tr of tbody.children){let sttTd=0,khoa="",giaTri="";for(const td of tr.children)sttTd%2==0?khoa=td.textContent.trim():giaTri=td.textContent.trim(),sttTd+=1;"Tác giả"===khoa?sach.tac_gia=giaTri:"Người Dịch"===khoa?sach.dich_gia=giaTri:"NXB"===khoa&&giaTri.length>0?sach.nxb=giaTri+";"+sach.nxb:"Số trang"===khoa&&(sach["nhan:Số trang:so"]=giaTri)}}return[sach]}
""",
            loc_regex: [
                "^https://skybooks.vn/[^/?]*$"
            ],
            loc_chinh_xac: [],
            bo_regex: [],
            bo_chinh_xac: []
        ),
        // 1980
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={nxb:"1980 Books"};sach.ten=document.getElementsByClassName("product-heading")[0].children[0].textContent.trim();const divAnh=document.getElementsByClassName("product-gallery slick-slide slick-current slick-active");divAnh.length>0?sach.anh=divAnh[0].children[0].href:sach.anh=document.getElementsByClassName("product-gallery")[0].children[0].src;const divGia=document.getElementById("price-preview");for(const muc of divGia.children)if("DEL"===muc.tagName){sach["nhan:Giá bìa:so:hien"]=muc.textContent.trim();break}const divMieuTa=document.getElementsByClassName("description-productdetail")[0];for(const muc of divMieuTa.children){const dong=muc.textContent.trim(),haiCham=dong.indexOf(":");if(haiCham>=0){const khoa=dong.substring(0,haiCham).trim().toUpperCase(),giaTri=dong.substring(haiCham+1).trim();giaTri.length>0&&("TÁC GIẢ"===khoa?sach.tac_gia=giaTri:"DỊCH GIẢ"===khoa?sach.dich_gia=giaTri:"SỐ TRANG"===khoa?sach["nhan:Số trang:so"]=giaTri:0===khoa.indexOf("NXB")&&(sach.nxb=giaTri.replaceAll("NXB","").trim()+";"+sach.nxb))}}let ketQua;return[sach]}
""",
            loc_regex: [
                "^https://1980books.com/products/[^/?]*$"
            ],
            loc_chinh_xac: [],
            bo_regex: [],
            bo_chinh_xac: []
        ),
        // Tao Dan
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={nxb:"Tao Đàn"};const divImage=document.getElementById("sync1").children[0].children[0];let doLech=divImage.style.transform;doLech=doLech.substring(doLech.indexOf("(")+1),0===doLech.indexOf("-")&&(doLech=doLech.substring(1)),doLech=doLech.substring(0,doLech.indexOf("px"));let doLechHienTai=0;for(const muc of divImage.children){let mucW=muc.style.width;if(mucW=mucW.substring(0,mucW.indexOf("px")),doLechHienTai+=Number(mucW),doLechHienTai>doLech){sach.anh=muc.children[0].children[0].src;break}}const divTab1=document.getElementsByClassName("rte")[0];for(const muc of divTab1.children)if("TABLE"===muc.tagName){const tbody=muc.children[0];for(const tr of tbody.children){let sttTd=0,khoa="",giaTri="";for(const td of tr.children)sttTd%2==0?khoa=td.textContent.trim():giaTri=td.textContent.trim(),sttTd+=1;"Tác phẩm"===khoa?sach.ten=giaTri:"Tác giả"===khoa?sach.tac_gia=giaTri:"Dịch giả"===khoa?sach.dich_gia=giaTri:"Nhà xuất bản"===khoa?sach.nxb=giaTri+";"+sach.nxb:"Số trang"===khoa?sach["nhan:Số trang:so"]=giaTri:"Giá bìa"===khoa?sach["nhan:Giá bìa:so:hien"]=giaTri:"ISBN"===khoa&&(sach.isbn=giaTri)}}let ketQua;return[sach]}
""",
            loc_regex: [
                "^https://sachtaodan.vn/[^/?]*$"
            ],
            loc_chinh_xac: [],
            bo_regex: [
                "^https://sachtaodan.vn/search.*$"
            ],
            bo_chinh_xac: []
        ),
        // DH SP
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={nxb:"Đại học Sư Phạm"},ketQua;sach.ten=document.getElementsByClassName("w-full md:w-1/3")[1].children[0].children[0].children[0].textContent.trim(),sach.anh=document.getElementById("cover-image-product").src,sach["nhan:Giá bìa:so:hien"]=document.getElementsByClassName("w-full md:w-1/3")[1].children[0].children[1].children[0].children[0].children[0].textContent.trim();for(const muc of document.getElementsByClassName("w-full md:w-1/3")[2].children[0].children)if("flex mt-12"===muc.className){let ten="",giaTri="",sttMuc=0;for(const muc2 of muc.children)sttMuc%2==0?ten=muc2.textContent.trim():giaTri=muc2.textContent.trim(),sttMuc+=1;"Tác giả"===ten?sach.tac_gia=giaTri:"Số trang"===ten?sach["nhan:Số trang:so"]=giaTri:ten.includes("ISBN")&&(sach.isbn=giaTri)}return[sach]}
""",
            loc_regex: [
                "^https://nxbdhsp.edu.vn/san-pham/[^/?]*$"
            ],
            loc_chinh_xac: [],
            bo_regex: [],
            bo_chinh_xac: []
        ),
        // Dong A
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={nxb:"Đông A"};const divImage=document.getElementById("ProductPhoto").children[0].children[0];let doLech=divImage.style.transform;doLech=doLech.substring(doLech.indexOf("(")+1),0===doLech.indexOf("-")&&(doLech=doLech.substring(1)),doLech=doLech.substring(0,doLech.indexOf("px"));let doLechHienTai=0;for(const muc of divImage.children){let mucW=muc.style.width;if(mucW=mucW.substring(0,mucW.indexOf("px")),doLechHienTai+=Number(mucW),doLechHienTai>doLech){sach.anh=muc.children[0].children[0].children[0].src;break}}sach.ten=document.getElementsByClassName("pro-content-head clearfix")[0].children[0].textContent.trim();const content=document.getElementsByClassName("content")[0].innerText.trim().split("\\n");for(const muc of content){let haiCham=muc.indexOf(":");if(haiCham>0){let ten=muc.substring(0,haiCham).trim(),giaTri=muc.substring(haiCham+1).trim();"Tác giả"===ten?sach.tac_gia=giaTri:"Số trang"===ten?sach["nhan:Số trang:so"]=giaTri:"Giá bìa"===ten?sach["nhan:Giá bìa:so:hien"]=giaTri:"Dịch giả"===ten?sach.dich_gia=giaTri:ten.includes("ISBN")&&(sach.isbn=giaTri)}else if(muc.includes("NXB")){let gt=muc.substring(muc.indexOf("NXB")+3);const sttLk=gt.indexOf("liên kết");sttLk>=0&&(gt=gt.substring(0,sttLk)),gt=gt.replaceAll(".","").trim(),sach.nxb=gt+";"+sach.nxb}}let ketQua;return void 0===sach["nhan:Giá bìa:so:hien"]&&(sach["nhan:Giá bìa:so:hien"]=document.getElementsByClassName("original-price ComparePrice")[0].textContent.trim()),[sach]}
""",
            loc_regex: [
                "^https://sachdonga.vn/products/[^/?]*$"
            ],
            loc_chinh_xac: [],
            bo_regex: [],
            bo_chinh_xac: []
        ),
        // Dan Tri
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={nxb:"Dân Trí"};sach.ten=document.getElementsByClassName("product_title entry-title")[0].textContent.replaceAll("–","").trim(),sach.anh=document.getElementsByClassName("woocommerce-product-gallery__image")[0].children[0].href;let noiDung=document.getElementsByClassName("woocommerce-product-details__short-description")[0].innerText.split("\\n"),stt=0,ketQua;for(;stt<noiDung.length;){const muc=noiDung[stt];if(muc.includes("–")){const mucCon=muc.split("–");if(mucCon.length>2){for(const mCon of mucCon){const mmCon=mCon.trim();mmCon.length>0&&noiDung.push(mmCon)}stt+=1;continue}}let haiCham=muc.indexOf(":");if(haiCham>0){let ten=muc.substring(0,haiCham).trim(),giaTri=muc.substring(haiCham+1).trim();ten.includes("Tác giả")?sach.tac_gia=giaTri.replaceAll("Chủ biên:","").trim():ten.includes("Dịch giả")?sach.dich_gia=giaTri:ten.includes("ISBN")?sach.isbn=giaTri:ten.includes("Số trang")?sach["nhan:Số trang:so"]=giaTri:ten.includes("Giá bìa")?sach["nhan:Giá bìa:so:hien"]=giaTri:ten.includes("liên kết ")&&(sach.nxb+=";"+giaTri)}stt+=1}return[sach]}
""",
            loc_regex: [
                "^https://nxbdantri.com.vn/s%E1%BA%A3n%20ph%E1%BA%A9m/[^?]*$"
            ],
            loc_chinh_xac: [],
            bo_regex: [],
            bo_chinh_xac: []
        ),
        // Phuc Minh
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={nxb:"Phúc Minh"};const divImage=document.getElementsByClassName("owl-stage")[0];let doLech=divImage.style.transform;doLech=doLech.substring(doLech.indexOf("(")+1),0===doLech.indexOf("-")&&(doLech=doLech.substring(1)),doLech=doLech.substring(0,doLech.indexOf("px"));let doLechHienTai=0;for(const muc of divImage.children){let mucW=muc.style.width;if(mucW=mucW.substring(0,mucW.indexOf("px")),doLechHienTai+=Number(mucW),doLechHienTai>doLech){sach.anh=muc.children[0].src;break}}const divTen=document.getElementsByClassName("product-title");sach.ten=divTen[divTen.length-1].textContent.trim();const noiDung=document.getElementsByClassName("goods-subtitle")[0].innerText.trim().split("\\n");for(const muc of noiDung){let haiCham=muc.indexOf(":");if(haiCham>0){let ten=muc.substring(0,haiCham).trim(),giaTri=muc.substring(haiCham+1).trim();"Tác giả"===ten?sach.tac_gia=giaTri:"Số trang"===ten?sach["nhan:Số trang:so"]=giaTri:"Giá bìa"===ten?sach["nhan:Giá bìa:so:hien"]=giaTri:"Dịch giả"===ten?sach.dich_gia=giaTri:ten.includes("ISBN")?sach.isbn=giaTri:"Nhà xuất bản"===ten&&(sach.nxb=giaTri+";"+sach.nxb)}else muc.includes("Nhà xuất bản")&&(sach.nxb=muc.replaceAll("Nhà xuất bản","").trim()+";"+sach.nxb)}let ketQua;return void 0===sach["nhan:Giá bìa:so:hien"]&&(sach["nhan:Giá bìa:so:hien"]=document.getElementById("price-preview").textContent.trim()),[sach]}
""",
            loc_regex: [
                "^https://www.phucminhbooks.vn/products/[^/?]*$"
            ],
            loc_chinh_xac: [],
            bo_regex: [],
            bo_chinh_xac: []
        ),
        // Dinh Ti
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={nxb:"ĐINH TỊ"};for(const muc of document.getElementsByClassName("mySlides"))if("block"===muc.style.display||""===muc.style.display){sach.anh=muc.src;break}const noiDung=document.getElementsByClassName("info-prd")[0].children[0].children[0].innerText.trim().split("\\n");let stt=0,ketQua;for(const dong of noiDung){if(0===stt){sach.ten=dong.trim(),stt+=1;continue}let haiCham=dong.indexOf(":");if(haiCham>0){let ten=dong.substring(0,haiCham).trim().toLowerCase(),giaTri=dong.substring(haiCham+1).trim();if("tác giả"===ten)sach.tac_gia=giaTri;else if("dịch giả"===ten)sach.dich_gia=giaTri;else if("số trang"===ten)sach["nhan:Số trang:so"]=giaTri;else if("giá"===ten){const gt=giaTri.split(" ");gt.length>1&&(sach["nhan:Giá bìa:so:hien"]=gt[1])}else"nhà xuất bản"===ten&&(sach.nxb=giaTri.replaceAll("NXB","").replaceAll("Nhà xuất bản","").trim()+";"+sach.nxb)}stt+=1}return[sach]}
""",
            loc_regex: [
                "^https://dinhtibooks.com.vn/[^/?]*\\.html$"
            ],
            loc_chinh_xac: [],
            bo_regex: [],
            bo_chinh_xac: []
        ),
        // San Ho
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={nxb:"San Hô"};const dsAnh=document.getElementsByClassName("bpfw-flip bpfw-flip-front")[0].children[0].srcset.split(",");let anh=dsAnh[dsAnh.length-1];anh=anh.substring(0,anh.lastIndexOf(" ")),sach.anh=anh.trim(),sach.ten=document.getElementsByClassName("product_title")[0].textContent.trim(),sach["nhan:Giá bìa:so:hien"]=document.getElementsByClassName("woocommerce-Price-amount")[0].textContent;const noiDung=document.getElementsByClassName("woocommerce-product-details__short-description")[0].innerText.split("\\n");for(const dong of noiDung){let haiCham=dong.indexOf(":");if(haiCham>0){let ten=dong.substring(0,haiCham).trim(),giaTri=dong.substring(haiCham+1).trim();if(ten.includes("Tiêu đề")||ten.includes("Tên sách"))sach.ten=giaTri;else if(ten.includes("Tác giả"))sach.tac_gia=giaTri;else if(ten.includes("Dịch giả")||ten.includes("Người dịch"))sach.dich_gia=giaTri;else if(ten.includes("Số trang"))sach["nhan:Số trang:so"]=giaTri;else if(ten.includes("Giá bìa"))sach["nhan:Giá bìa:so:hien"]=giaTri;else if(ten.includes("Ngôn ngữ"))sach["nhan:Ngôn ngữ"]=giaTri;else if(ten.includes("ISBN"))sach.isbn=giaTri;else if(ten.includes("Nhà xuất bản")||ten.includes("NXB")){let gt=giaTri;const sttGach=gt.indexOf("–");sttGach>0&&(gt=gt.substring(0,sttGach)),gt=gt.replaceAll("NXB","").replaceAll("Nhà xuất bản","").trim(),sach.nxb=gt+";"+sach.nxb}}}let ketQua;return[sach]}
""",
            loc_regex: [
                "^https://sanhobooks.com/san-pham/[^?]*$"
            ],
            loc_chinh_xac: [],
            bo_regex: [],
            bo_chinh_xac: []
        ),
        // Linh Lan
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={nxb:"Linh Lan"},tagTen=document.getElementsByClassName("title-head fixitem-title")[0];sach.ten=tagTen.textContent.trim();let tagAnh=document.getElementsByClassName("kiti active");0===tagAnh.length&&(tagAnh=document.getElementById("zoom_01").parentElement.parentElement.children[1].children[0].children),sach.anh=tagAnh[0].attributes["data-image"].textContent;let tagGia=tagTen.parentElement.getElementsByClassName("product-price-old");0===tagGia.length&&(tagGia=tagTen.parentElement.getElementsByClassName("product-price")),sach["nhan:Giá bìa:so:hien"]=tagGia[0].textContent.trim();const noiDung=document.getElementsByClassName("short-description")[0].innerText.split("\\n");for(const dong of noiDung){let haiCham=dong.indexOf(":");if(haiCham>0){let ten=dong.substring(0,haiCham).trim(),giaTri=dong.substring(haiCham+1).trim();"Tác giả"===ten?sach.tac_gia=giaTri:"Số trang"===ten?sach["nhan:Số trang:so"]=giaTri:"NXB"===ten&&(sach.nxb=giaTri+";"+sach.nxb)}}let ketQua;return[sach]}
""",
            loc_regex: [
                "^https://linhlanbooks.vn/products/[^/?]*$"
            ],
            loc_chinh_xac: [],
            bo_regex: [],
            bo_chinh_xac: []
        ),
        // IPM
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={nxb:"IPM"};sach.ten=document.getElementsByClassName("product-title")[0].children[0].textContent.trim(),sach.anh=document.getElementsByClassName("product-image-feature-slider")[0].getElementsByClassName("owl-item active")[0].children[0].href;let tagGia=document.getElementById("price-preview").children,ketQua;tagGia.length>1?sach["nhan:Giá bìa:so:hien"]=tagGia[1].textContent.trim():sach["nhan:Giá bìa:so:hien"]=tagGia[0].textContent.trim();for(const divRow of document.getElementsByClassName("box-tag")[0].children[0].children)if(divRow.children.length>1){let ten=divRow.children[0].textContent.trim(),giaTri=divRow.children[1].textContent.trim();"Tác giả"===ten?sach.tac_gia=giaTri:"Nhà xuất bản"===ten&&(sach.nxb=giaTri+";"+sach.nxb)}return[sach]}
""",
            loc_regex: [
                "^https://ipm.vn/products/[^/?]*$"
            ],
            loc_chinh_xac: [],
            bo_regex: [],
            bo_chinh_xac: []
        ),
        // Tri Thuc Viet
        MaLenh(
            ma: """
function layDanhSachSach(){let sach={nxb:"Trí Thức Việt"};sach.ten=document.getElementsByClassName("product-name")[0].textContent.trim(),sach.anh=document.getElementById("zoom1").href,sach["nhan:Giá bìa:so:hien"]=document.getElementsByClassName("product-name")[0].parentElement.getElementsByClassName("old-price")[0].textContent.trim(),0===sach["nhan:Giá bìa:so:hien"].length&&(sach["nhan:Giá bìa:so:hien"]=document.getElementsByClassName("product-name")[0].parentElement.getElementsByClassName("special-price")[0].textContent.trim());const noiDung=document.getElementById("productTabContent").innerText.split("\\n");for(const dong of noiDung){let haiCham=dong.indexOf(":");if(haiCham>0){let ten=dong.substring(0,haiCham).trim().toLowerCase(),giaTri=dong.substring(haiCham+1).trim();ten.includes("tác giả")?sach.tac_gia=giaTri:ten.includes("dịch")?sach.dich_gia=giaTri:ten.includes("isbn")||ten.includes("mã vạch")?sach.isbn=giaTri:ten.includes("số trang")?sach["nhan:Số trang:so"]=giaTri:ten.includes("nhà xuất bản")&&(sach.nxb=giaTri+";"+sach.nxb)}}let ketQua;return[sach]}
""",
            loc_regex: [
                "^https://www.trithucvietbook.com/[^/?]*$"
            ],
            loc_chinh_xac: [],
            bo_regex: [],
            bo_chinh_xac: []
        )
    ]
)

if let json = try? JSONEncoder().encode(noiDung), let str = String(data: json, encoding: .utf8) {
    print(str)
}
exit(0)
