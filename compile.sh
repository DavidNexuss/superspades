#!/bin/sh

CCOPTS="-I Sources -m32 -I /usr/x86_64-w64-mingw32/include/SDL2/ -I . -I Sources/json/include -I Sources/AngelScript/include -I Sources/ENet/include -I /usr/x86_64-w64-mingw32/include/freetype2 -I /usr/x86_64-w64-mingw32/include/opus"
LDOPTS="lib64/SDL2_main.a -Llib64 -l:SDL2.dll lib64/SDL2_image.a -l:glew32.dll -l:OpenAL32.dll -l:opengl32.dll -l:libcurl64.dll -l:libopus-0.dll -l:libogg_64.dll -l:libTIFF64.dll -l:zlib.dll -l:freetype.dll -lwinmm -lws2_32 -static-libgcc -static-libstdc++ lib64/opusfile64.a lib64/libwinpthread.a"
LDOPTS32="-lglew -static-libgcc -static-libstdc++"
FDOPTS=
#FDOPTS="-maxdepth 1"
LIBNAME="lib.a"

function findLibraries { 
  echo -n "-Llib32 "
  find lib32 -type 'f' | while read line; do
    echo "-l:$(basename $line)"
  done | tr '\n' ' '
}

function findSources { 
  rm -f sources.dat
  find . $FDOPTS -type 'f' -name '*.cpp' | cut -c3- >> sources.dat
  find . $FDOPTS -type 'f' -name '*.c' | cut -c3- >> sources.dat
  cp sources.dat sources.dat.old
  grep -v "Tools" sources.dat.old > sources.dat
}

function findHeaders { 
  rm -f headers.dat
  find . $FDOPTS -type 'f' -name '*.hpp' | cut -c3- >> headers.dat
  find . $FDOPTS -type 'f' -name '*.h' | cut -c3- >> headers.dat
}

function compile  { 
  [[ "$1" == *.cpp ]] && {
    echo -e "\tx86_64-w64-mingw32-g++ $1 -c -o $2 $CCOPTS" 
  } || {
    echo -e "\tx86_64-w64-mingw32-gcc $1 -c -o $2 $CCOPTS" 
  }
}

findSources
rm -f objects.dat
cat sources.dat | while read line; do
OBJ="$(echo "$line" | tr '/' '_').o"
echo -n "$OBJ " >> objects.dat
SRC=$line
echo "$OBJ: $line"
compile $SRC $OBJ
done

echo -n "all: "
cat objects.dat

echo -e "\t\n\t\nclean:"
echo -ne "\t rm -f $(cat objects.dat)"

echo -e "\npack: all" 
echo -e "\t rm -f $LIBNAME"
echo -e "\t ar rcs $LIBNAME $(cat objects.dat)"


echo -e "\nlink: all"
echo -e "\t x86_64-w64-mingw32-g++ $(cat objects.dat) $LDOPTS -o superspades.exe"

echo -e "\nlink32: all"
echo -e "\t i686-w64-mingw32-g++ -m32 $(cat objects.dat) $(findLibraries) $LDOPTS32 -o superspades.exe"

echo -e "\ndist: link"
echo -e "\t rm -rf dist"
echo -e "\t mkdir dist"
echo -e "\t cp superspades.exe dist"
echo -e "\t cp lib64/* dist"
echo -e "\t cp -r ../Release/build/Resources dist/"
echo -e "\t rm -rf dist/*.a"
