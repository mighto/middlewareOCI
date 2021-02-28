echo '说明：此脚本只在6.7.* ~ 6.8.* 版本有验证过，其他版本未做验证，如有问题请根据实际情况调整脚本内容！'
# 检查是否是root用户
if [ $USER != 'root' ];then
    echo '非root用户，无法安装。。'
    exit
fi

# 检查是否有java环境
java -version >/dev/null 2>&1
if [ $? -ne 0 ];then
    echo '未安装java环境，无法安装。。'
    exit
fi

read -ep '请输入es的rpm文件路径:' path
if [ ! -e "$path" ];then
    echo '文件不存在'
    exit
fi

# 获取各项安装设置
read -ep '数据存储路径（可选）: ' path_data
if [ -n "$path_data" ];then
    if [ ! -d $path_data ];then
        mkdir -p ${path_data}
        echo '自动创建目录：' $path_data 
    fi
    if [ "`ls -A $path_data`" != "" ];then
        echo '路径' $path_data '非空'
        exit
    fi
fi

read -ep '日志存储路径（可选）: ' log_data
if [ -n "$log_data" ];then
    if [ ! -d $log_data ];then
        mkdir -p ${log_data}
        echo '自动创建目录：' $log_data 
    fi
    if [ "`ls -A $log_data`" != "" ];then
        echo '路径' $log_data '非空'
        exit
    fi
fi

read -ep 'es的Xmx(默认1g): ' xmx
if [ -n "$xmx" ];then
    if [ $xmx -lt 1 -o $xmx -gt 8 ];then
        echo 'xmx应大于等于，小于等于8'
        exit
    fi
fi

read -ep 'es的network.host(默认127.0.0.1): ' host
host=${host:-'127.0.0.1'}


# 执行安装及配置
echo '准备安装==='
yum install -y ${path} >es-install.log 2>&1
if [ $? -ne 0 ];then
    echo '安装失败，请在es-install.log查看错误日志。。'
    exit
fi

echo '安装完成~~~'
systemctl daemon-reload
systemctl enable elasticsearch >es-install.log 2>&1
echo '已设置开机启动~~~'

if [ -n "$path_data" ];then
    # 路径替换
    # sed -i '33s#/var/lib/elasticsearch#'$path_data'#' /etc/elasticsearch/elasticsearch.yml
    # 整行替换
    sed -i '33c path.data: '$path_data /etc/elasticsearch/elasticsearch.yml
    chown -R elasticsearch:elasticsearch $path_data
fi
if [ -n "$log_data" ];then
    # 路径替换
    # sed -i '37s#/var/log/elasticsearch#'$log_data'#' /etc/elasticsearch/elasticsearch.yml
    # 整行替换
    sed -i '37c path.logs: '$log_data /etc/elasticsearch/elasticsearch.yml
    chown -R elasticsearch:elasticsearch $log_data
fi
if [ -n "$xmx" ];then
    sed -i '22s/1/'$xmx'/' /etc/elasticsearch/jvm.options
    sed -i '23s/1/'$xmx'/' /etc/elasticsearch/jvm.options
fi
if [ -n "$host" ];then
    sed -i '55c network.host: '$host /etc/elasticsearch/elasticsearch.yml
fi
# 配置$JAVA_HOME
sed -i '9c JAVA_HOME='$JAVA_HOME /etc/sysconfig/elasticsearch


read -ep '是否现在启动？[y/n] ' yn
yn=${yn:-'y'}
if [ $yn == 'y' -o $yn == 'Y' ];then
    systemctl start elasticsearch
else
    echo 'elasticsearch未启动，请手动执行: systemctl start elasticsearch'
fi
echo 'elasticsearch配置文件夹为：/etc/elasticsearch/'


read -ep '是否继续配置集群？[n/y] ' goon
goon=${goon:-'n'}
if [ $goon == 'n' -o $goon == 'N' ];then
    echo '已完成单节点安装并退出~~'
    exit
fi


read -ep '集群名称cluster.name(默认my-application): ' cluster_name
cluster_name=${cluster_name:-'my-application'}
if [ -n "$cluster_name" ];then
    sed -i '17c cluster.name: '$cluster_name /etc/elasticsearch/elasticsearch.yml
fi

read -ep '节点名称node.name(默认node-1): ' node_name
node_name=${node_name:-'node-1'}
if [ -n "$node_name" ];then
    sed -i '23c node.name: '$node_name /etc/elasticsearch/elasticsearch.yml
fi

read -ep '节点列表discovery.zen.ping.unicast.hosts(默认["127.0.0.1", "[::1]"]): ' dzpuh
if [ -n "$dzpuh" ];then
    sed -i '68c discovery.zen.ping.unicast.hosts: '$dzpuh /etc/elasticsearch/elasticsearch.yml
fi

read -ep '节点名称discovery.zen.minimum_master_nodes(默认-1): ' dzmmn
if [ -n "$dzmmn" ];then
    sed -i '72c discovery.zen.minimum_master_nodes: '$dzmmn /etc/elasticsearch/elasticsearch.yml
fi

systemctl restart elasticsearch
if [ $? -ne 0 ];then
    echo 'es重启失败。。请手动检查配置。。'
fi
echo '完成此节点配置，祝君好运~~'