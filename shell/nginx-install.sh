if [ $USER != 'root' ];then
    echo '非root用户，无法安装。。'
    exit
fi

read -ep '请输入nginx的rpm文件路径:' path
if [ ! -e "$path" ];then
    echo '文件不存在'
    exit
fi

echo '准备安装='
yum install -y ${path} >nginx-install.log 2>&1
if [ $? -ne 0 ];then
    echo '安装失败，请在nginx-install.log查看错误日志。。'
    exit
fi
echo '安装完成~'

read -ep '是否使用root做为nginx启动用户？[y/n] ' useRoot
useRoot=${useRoot:-'y'}
if [ ${useRoot} == 'y' -o ${useRoot} == 'Y' ];then
    sed -i '2s/nginx/root/' /etc/nginx/nginx.conf
    echo '已更新启动用户为root~~~'
fi

systemctl enable nginx >nginx-install.log 2>&1
echo '已设置开机启动~~~'

read -ep '是否现在启动？[y/n] ' yn
yn=${yn:-'y'}
if [ ${yn} == 'y' -o ${yn} == 'Y' ];then
    systemctl start nginx
else
    echo 'nginx未启动，请手动执行: systemctl start nginx'
fi
echo 'nginx配置文件夹为：/etc/nginx/conf.d'
echo '完成nginx安装，再会~~'
