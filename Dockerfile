FROM ubuntu:16.04

RUN apt-get update && apt-get install bzip2 file python gcc g++ libncurses5-dev gawk zip xz-utils wget libgetopt-complete-perl make cmake git -y -qq

ARG sdkURL=https://downloads.openwrt.org/releases/19.07.3/targets/ramips/mt7620/openwrt-sdk-19.07.3-ramips-mt7620_gcc-7.5.0_musl.Linux-x86_64.tar.xz
ENV sdkURL ${sdkURL}
ARG targetFolder=target
ENV targetFolder ${targetFolder}

RUN echo ${sdkURL}
RUN wget -q ${sdkURL} -O /sdk.tar.xz && mkdir /sdk && tar -xf /sdk.tar.xz -C /sdk && cp -R /sdk/openwrt-* /sdk/openwrt-sdk

WORKDIR /sdk/openwrt-sdk
RUN cp feeds.conf.default feeds.conf && echo "src-git openwrt_switch_lan_play https://github.com/htynkn/openwrt-switch-lan-play.git" >> feeds.conf

RUN ./scripts/feeds update -a && ./scripts/feeds install -a
RUN wget https://raw.githubusercontent.com/torvalds/linux/v4.7/scripts/kconfig/merge_config.sh && chmod +x merge_config.sh
RUN make defconfig
RUN echo "CONFIG_PACKAGE_luci-app-switch-lan-play=y" >> .config-fragment
RUN echo "CONFIG_PACKAGE_switch-lan-play=y" >> .config-fragment

RUN ./merge_config.sh -m .config .config-fragment

RUN make package/luci-app-switch-lan-play/compile && make package/switch-lan-play/compile
RUN rm -rf ${targetFolder} && mkdir -p ${targetFolder} && find . | grep lan-play | grep ipk | xargs -I {} cp {} ${targetFolder}
RUN gcc scripts/mkhash.c -o mkhash && mv mkhash /usr/local/bin && chmod +x /usr/local/bin/mkhash
RUN cd ${targetFolder} && /sdk/openwrt-sdk/scripts/ipkg-make-index.sh . >> Packages
RUN cd ${targetFolder} && gzip -k Packages
