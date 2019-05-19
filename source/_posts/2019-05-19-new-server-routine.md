---
title: new-server-routine
date: 2019-05-19 13:20:43
tags:
- 新vps
- centos
- linux配置
- 开启bbr
- 更新内核
- 更改ssh端口
- 关闭firewalld
---
以下所有操作均是在root账户下操作。
# 1. 更改ssh端口

```
vi /etc/ssh/sshd_config
```
把port这一行注释去掉，22改成你要的端口号。

```
service sshd status
```
看一下是不是在监听指定端口号。

# 2. 更改密码
```passwd```命令敲进去，换密码。

# 3. 关掉firewalld
centos 7自带一个firewalld防火墙，用iptables就行了，firewalld用处不是很大。
先看一下firewalld是不是开着的：
```
firewall-cmd --state
```
如果是```running```那就要先把服务关了：
```
systemctl stop firewalld
```
再disable掉不要开机启动了：
```
systemctl disable firewalld
systemctl mask firewalld
```
成了。


# 4. 升级内核
先```yum update```一波，再导入ELRepo公钥
```
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
```
再安装ELRepo(注：我的是centos 7，其他版本[参考](http://elrepo.org/tiki/tiki-index.php))
```
yum install https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
```
然后直接安装最新主线内核
```
yum --enablerepo=elrepo-kernel install kernel-ml
```
完成之后看一下新内核是不是装上去了
```
sudo awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
```
我的显示
```
[root@test2 ~]# awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
0 : CentOS Linux (5.1.3-1.el7.elrepo.x86_64) 7 (Core)
1 : CentOS Linux (3.10.0-957.12.2.el7.x86_64) 7 (Core)
2 : CentOS Linux (3.10.0-957.10.1.el7.x86_64) 7 (Core)
3 : CentOS Linux (3.10.0-693.el7.x86_64) 7 (Core)
4 : CentOS Linux (0-rescue-8508293106977c25a934808909d9e8a1) 7 (Core)
```
0就是新内核。保险起见再设置一下0为默认启动内核：
```
grub2-set-default 0
```
最后生成grub2配置
```
grub2-mkconfig -o /boot/grub2/grub.cfg
```
哦了，```reboot```即可。

重启完看一下```uname -r```是不是用新内核了：
```
[root@test2 ~]# uname -r
5.1.3-1.el7.elrepo.x86_64
```
成了。
[参考](https://www.howtoforge.com/tutorial/how-to-upgrade-kernel-in-centos-7-server/)
# 5. 开启bbr
先```lsmod | grep bbr```看一下有没有返回结果，有就是开起来了。我是没开起来，所以：
```
modprobe tcp_bbr
echo "tcp_bbr" | sudo tee --append /etc/modules-load.d/modules.conf
```
然后改一下配置文件：
```
echo "net.core.default_qdisc=fq" | sudo tee --append /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee --append /etc/sysctl.conf
```
保存一下配置
```
sysctl -p
```
再```lsmod | grep bbr```看一下，成了。
[参考](https://github.com/iMeiji/shadowsocks_install/wiki/%E5%BC%80%E5%90%AF-TCP-BBR-%E6%8B%A5%E5%A1%9E%E6%8E%A7%E5%88%B6%E7%AE%97%E6%B3%95)
# 5. 清空iptables规则
个人习惯把iptables清除一遍，再做配置。
```
iptables -t nat -F  
iptables -t nat -X  
iptables -t nat -P PREROUTING ACCEPT  
iptables -t nat -P POSTROUTING ACCEPT  
iptables -t nat -P OUTPUT ACCEPT  
iptables -t mangle -F  
iptables -t mangle -X  
iptables -t mangle -P PREROUTING ACCEPT  
iptables -t mangle -P INPUT ACCEPT  
iptables -t mangle -P FORWARD ACCEPT  
iptables -t mangle -P OUTPUT ACCEPT  
iptables -t mangle -P POSTROUTING ACCEPT  
iptables -F  
iptables -X  
iptables -P FORWARD ACCEPT  
iptables -P INPUT ACCEPT  
iptables -P OUTPUT ACCEPT  
iptables -t raw -F  
iptables -t raw -X  
iptables -t raw -P PREROUTING ACCEPT  
iptables -t raw -P OUTPUT ACCEPT  
 
```
再```iptables-save```看一下配置是不是清除干净了。
[参考](http://os.51cto.com/art/201103/249518.htm)

之后再```service iptables save```保存一下。如果出现：
```
[root@test2 ~]# service iptables save
The service command supports only basic LSB actions (start, stop, restart, try-restart, reload, force-reload, status). For other actions, please try to use systemctl.
```
那就是系统的iptables没装好，再装一下：
```
yum install iptables-services
```
再确保一下自启：
```
systemctl enable iptables
systemctl start iptables
```
[参考](https://stackoverflow.com/questions/24756240/how-can-i-use-iptables-on-centos-7)