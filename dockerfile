FROM centos:7
COPY install_lnp.sh /tmp
RUN sh /tmp/install_lnp.sh
#脚本内记录了一些安装错误的解决办法，有些网址可能失效，建议可以自己在网上下载源码包拷贝到容器
#是为了完全还原公司环境制作
#该容器体积较大
#根据个人需求采纳
COPY run.sh /
CMD [ "/run.sh" ]

