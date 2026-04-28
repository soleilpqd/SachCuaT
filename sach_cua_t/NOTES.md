# Ghi chú

## Chú ý:

- Bundle ID: ảnh hưởng Bundle ID của iOS, Package ID của Android và Flutter (đặc biệt `import` strong source).
- Phiên bản thư viện `webview_flutter` phụ thuộc vào phiên bản XCode (XCode từ 14.3 trở lên thì có thể sử dụng thư viện này với phiên bản mới nhất).

## Các cấu hình so với mặc định:

### iOS:

Info.plist:
- Privacy - Camera

### Android:

AndroidManifest.xml:
- uses-feature: camera
- uses-permission: camera

app/build.gradle.kts:
- buildFeatures: viewBinding & buildConfig.
- dependencies: quét QR.

## Mã nguồn module native được thêm vào:

- Kênh xử lý yêu cầu từ module Flutter.
- Màn hình quét mã: class, giao diện (storyboard, XML layout).
