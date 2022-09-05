#!/bin/bash
[[ -f "Release/Makefile" ]] || cmake -S . -B Release/ -D CMAKE_BUILD_TYPE=Release
cd Release
make -j$(nproc)
mkdir -p AppDir/usr/bin
cp bin/openspades AppDir/usr/bin

LINUXDEPLOY="https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
LINUXDEPLOYNAME="linuxDeploy"

[[ -f "$LINUXDEPLOYNAME" ]] || wget -O "$LINUXDEPLOYNAME" "$LINUXDEPLOY" 
chmod +x "$LINUXDEPLOYNAME"

cp Resources/Icons/hicolor/256x256/apps/openspades.png .
cp ../openspades.desktop .
./"$LINUXDEPLOYNAME" --appdir AppDir -dopenspades.desktop -iopenspades.png --output appimage
mkdir ../dist
cp $(ls | grep 'AppImage') superspades.appimage
zip superspades.zip -r superspades.appimage Resources
cp superspades.zip ../dist/superspades_linux.zip
