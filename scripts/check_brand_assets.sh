#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
base="FraPoMacCleaner/Resources/Assets.xcassets"
logo="$base/BrandLogo.imageset/brand-logo.png"
icon="$base/AppIcon.appiconset/icon-1024.png"
echo "5538179542dfaf2f4aa13bc50b9456e9d4fe9a0530ce25e703d7b0ac6337cb82  $logo" | shasum -a 256 -c -
echo "db8b77d6cf1dbfddb044c71e055c4ce68dcc126ed0d7bde25c8467f574602231  $icon" | shasum -a 256 -c -
check_dimensions() {
  local source="$1" expected_width="$2" expected_height="$3" actual_width actual_height
  actual_width="$(sips -g pixelWidth "$source" | awk '/pixelWidth:/{print $2}')"
  actual_height="$(sips -g pixelHeight "$source" | awk '/pixelHeight:/{print $2}')"
  if [[ "$actual_width" != "$expected_width" || "$actual_height" != "$expected_height" ]]; then
    echo "Wrong dimensions: $source ($actual_width x $actual_height)" >&2
    exit 1
  fi
}
check_dimensions "$logo" 1460 285
for px in 16 32 64 128 256 512 1024; do
  check_dimensions "$base/AppIcon.appiconset/icon-$px.png" "$px" "$px"
done
echo "Brand originals and icon sizes verified."
