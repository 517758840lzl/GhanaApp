echo "开始打包..."

flutter clean

time=$(date "+%m-%d %H:%M")

flutter build apk --release --obfuscate --split-debug-info=./symbols --dart-define=BUILD_TIME="$time"

#aab包
#flutter build appbundle --release --obfuscate --split-debug-info=./symbols --dart-define=BUILD_TIME="$time"


echo "打包完成..."

cd build/app/outputs/flutter-apk


FILE=app-release.apk

if [ ! -f $FILE ]; then
  echo "文件不存在, 打包失败..."
  exit
fi


echo "开始上传蒲公英..."

#xph
UPLOAD=$(curl -X POST -F "file=@$FILE" -F "_api_key=b89029fe2eef3d0c7deb420c1368527e" https://www.xcxwo.com/apiv2/app/upload)

echo "上传蒲公英结束..."

echo $UPLOAD