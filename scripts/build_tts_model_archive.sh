#!/bin/bash
# Đóng gói lại model TTS vits-vctk (int8) thành tar.bz2 gọn để upload lên
# GitHub Releases — xem docs/analysis/sherpa-onnx-replacement.md §4.
#
# Tarball gốc của k2-fsa (145MB) chứa cả bản fp32 không dùng; script này chỉ
# giữ 3 file app thực sự cần (vits-vctk.int8.onnx, tokens.txt, lexicon.txt),
# nén còn ~35MB.
#
# Không cố định mtime/owner khi tar (macOS bsdtar không hỗ trợ các flag
# GNU tar --sort/--mtime/--owner/--group/--numeric-owner) — nghĩa là
# SHA-256 kết quả có thể khác giữa các máy/lần chạy. Không sao: chỉ cần
# checksum trong code khớp với đúng file bạn upload. Sau khi chạy, gửi lại
# giá trị SHA-256 script in ra để cập nhật `tts_models.dart` cho khớp.
set -euo pipefail

OUTPUT_DIR="$(pwd)"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

cd "$WORKDIR"
curl -sSL -o vits-vctk.tar.bz2 \
  "https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-vctk.tar.bz2"

mkdir -p extracted slim/vits-vctk
tar -xjf vits-vctk.tar.bz2 -C extracted
cp extracted/vits-vctk/vits-vctk.int8.onnx slim/vits-vctk/
cp extracted/vits-vctk/tokens.txt slim/vits-vctk/
cp extracted/vits-vctk/lexicon.txt slim/vits-vctk/

# Quan trọng: dùng ustar + bỏ metadata macOS. bsdtar mặc định ghi PAX
# extended header (com.apple.provenance) và file AppleDouble `._*`; package
# Dart `archive` (dùng để giải nén trong app) không parse được các header
# này → FormatException "Unexpected extension byte". `xattr -rc` xoá xattr,
# COPYFILE_DISABLE=1 chặn file `._*`, `--format ustar` chặn PAX header.
xattr -rc slim/vits-vctk 2>/dev/null || true
(cd slim && COPYFILE_DISABLE=1 tar --format ustar \
  -cjf "$WORKDIR/vits-vctk-int8.tar.bz2" vits-vctk)

OUT="$OUTPUT_DIR/vits-vctk-int8.tar.bz2"
cp "$WORKDIR/vits-vctk-int8.tar.bz2" "$OUT"

echo "Đã tạo: $OUT"
echo "SHA-256:"
if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$OUT"
else
  shasum -a 256 "$OUT"
fi
echo ""
echo "Gửi lại giá trị SHA-256 ở trên để cập nhật lib/features/study/data/tts/tts_models.dart."
