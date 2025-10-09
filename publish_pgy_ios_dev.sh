echo "开始ios打包..."


rm -rf build/ios/

flutter clean

flutter build ipa --obfuscate --split-debug-info=./symbols --export-method ad-hoc --dart-define=DEBUG=true

echo "打包完成..."


cd build/ios/ipa/

FILE=flutter3APP.ipa

if [ ! -f $FILE ]; then
  echo "文件不存在, 打包失败..."
  exit
fi


echo "开始上传蒲公英..."

#xph
UPLOAD=$(curl -X POST -F "file=@$FILE" -F "_api_key=b89029fe2eef3d0c7deb420c1368527e" https://www.xcxwo.com/apiv2/app/upload)

echo "上传蒲公英结束..."

echo $UPLOAD


