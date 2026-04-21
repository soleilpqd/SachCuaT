# Ghi chú

## Chú ý:

- Bundle ID: ảnh hưởng Bundle ID của iOS, Package ID của Android và Flutter (đặc biệt `import` strong source).

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
