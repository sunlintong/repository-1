# 一.安装vmware12.5.7
# 二.在vmware上安装CentOS-7
## 1. 基本设置
内存：1G;  
处理器：1:  
硬盘：20G;  
安装最小的版本，不装图形界面  
## 2. 磁盘分区
## 3. 设置用户名和密码
## 4. 网络配置
用vim修改**/etc/sysconfig/network-scripts/ifcfg-ens33**文件(虚拟机不同，文件名可能不同），将**BOOTPROTO**配置为**dhcp**，**ONBOOT=yes**  
注：BOOTPROTO网络配置参数  
    BOOTPROTO=static   静态IP  
    BOOTPROTO=dhcp   动态IP  
    BOOTPROTO=none   无（不指定）  
    ONBOOT指明在系统启动时是否激活网卡，只有在激活状态的网卡才能去连接网络，进行网络通讯
## 5. 安装ssh服务
(1).检查是否有安装openssh-server: *yum list installed | grep openssh-server*  
(2).编辑ssh服务配置文件：**vi /etc/ssh/sshd_config**  
(3).去除监听端口**port 22**和监听地址**ListenAddress**前的#  
(4).开启允许远程登录（去掉**PermitRootLogin**前的#）  
(5).开启使用用户名密码作为连接验证（去掉**PasswordAuthentication**前的#），保存退出vi  
(6).开启sshd服务：**sudo service sshd start**  
    检查：ps -e|grep sshd  
    检查22端口：netstat -an|grep 22  
(7).在主机上安装Xshell5，新建会话，设置连接目标的ip和端口号，输入要使用的用户名和密码，完成连接，可以远程控制  
		我的参考链接：[如何为centos开启ssh服务?](http://blog.csdn.net/lishaojun0115/article/details/70172409)
