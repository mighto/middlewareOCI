### 背景：

由于我司的项目经常需要在一些无互联网的内网环境部署，用到的中间件包括但不限于redis、mysql、elasticsearch、rabbitmq。。每次都需要重新安装。。

~~经常离线手动安装，致人恶心呕吐，有中毒症状。~~

某日受[eryajf](https://github.com/eryajf/magic-of-sysuse-scripts)老哥启发，决定做一味土方，以期解决自身痛症。

### 思路：

将中间件的安装步骤，以shell命令的形式整理为一个shell脚本，需要安装的时候执行脚本，按提示输入相应参数，脚本自动安装软件并更改配置文件。

如果有其他想法欢迎反馈给我。

### 使用：

    * 目前只提供了CentOS版本的脚本，CentOS-7完成过验证，其他版本未做验证。

各中间件的安装脚本在shell文件夹中，在CentOS中执行后，根据交互命令提示输入需要的参数即可。

通常情况首先要提供给交互命令离线安装包rpm文件的路径，rpm文件可自行准备，在本仓库rpm文件夹中也提供了一些版本供参考。

### 版本

由于资源是有限的，此脚本只完成了极少的版本验证。好消息是shell脚本的内容比较简单，有需要可以根据实际情况调整。

| 中间件 | 验证过的版本 | 理论上支持的版本 |
| --- | --- | --- |
| nginx | 1.14.2/1.18.0 | 1.12.* ~ 1.18.* |
| elasticsearch | 6.7.2/6.8.3 | 6.7.* ~ 6.8.* |

