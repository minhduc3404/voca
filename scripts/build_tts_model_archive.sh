#!/bin/bash
# Đóng gói lại model TTS vits-vctk (int8) thành tar.bz2 gọn để upload lên
# GitHub Releases — xem docs/analysis/sherpa-onnx-replacement.md §4.
#
# Tarball gốc của k2-fsa (145MB) chứa cả bản fp32 không dùng; script này chỉ
# giữ 3 file app thực sự cần (vits-vctk.int8.onnx, tokens.txt, lexicon.txt),
# nén còn ~35MB.
#
# Cố định mtime/owner/group khi tar để build reproducible — nếu không, mỗi
# lần chạy lại (kể cả nội dung giống hệt) sẽ ra SHA-256 khác nhau vì `cp`
# stamp mtime theo thời điểm chạy.
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

(cd slim && tar --sort=name --mtime='UTC 2024-01-01' --owner=0 --group=0 \
  --numeric-owner -cjf "$WORKDIR/vits-vctk-int8.tar.bz2" vits-vctk)

OUT="$OUTPUT_DIR/vits-vctk-int8.tar.bz2"
cp "$WORKDIR/vits-vctk-int8.tar.bz2" "$OUT"

echo "Đã tạo: $OUT"
echo "SHA-256:"
sha256sum "$OUT"
echo "Kỳ vọng (tts_models.dart): 13065d20d9e39dca81d2934551a41041591ffa463c50fe6dc50351fb30306d61"
