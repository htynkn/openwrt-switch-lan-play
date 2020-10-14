SDKURL=$1;
TARGET_FOLDER=$2;
echo "sdkURL: ${SDKURL} targetFolder:${TARGET_FOLDER}";
echo "building ipk ..."

docker build --build-arg sdkURL=${SDKURL} --build-arg targetFolder=${TARGET_FOLDER} . -t htynkn/openwrt-switch-lan-play-${TARGET_FOLDER}:latest
rm -f target.zip
docker run -v $PWD:/opt/mount --rm htynkn/openwrt-switch-lan-play-${TARGET_FOLDER}:latest bash -c "cd /sdk/openwrt-sdk && ./staging_dir/host/bin/usign -S -m ${TARGET_FOLDER}/Packages -s /opt/mount/secrets.key -x ${TARGET_FOLDER}/Packages.sig && cp /opt/mount/public.key ${TARGET_FOLDER}/public.key  && find ${TARGET_FOLDER} | xargs zip -ur target.zip && cp /sdk/openwrt-sdk/target.zip /opt/mount/target.zip"