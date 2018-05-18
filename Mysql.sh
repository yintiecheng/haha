#!/bin/bash
##This is Mysql Master Slave install
##2018/5/23 
##Mr:yin

if [ -z $1 ];then

   echo -e "\033[32m 1)安装Mysql服务\033[0m"
   echo -e "\033[32m 2)安装Mysql主服务器\033[0m"
   echo -e "\033[32m 3)安装Amoeba服务\033[0m"
fi
mysql=/root/mysql-5.5.22.tar.gz
cmake=/root/cmake-2.8.6.tar.gz
mysql_install=/usr/local/mysql
if [[ "$1" -eq "1" ]];then
   if [ -f $mysql ];then
       if [ -f $cmake ];then
      useradd -M -s /sbin/nologin mysql
      rpm -e mysql-server mysql --nodeps
         for i in "gcc-c++ ncurlses-devel ntp";do
          yum -y install $i
          done
         sed -i -e '2a  server 127.127.1.0\nfudge 127.127.1.0 stratum 8' /etc/ntp.conf
         chkconfig --level 35 ntp on
         service ntp restart
         tar -axvf $cmake -C /usr/src
         cd /usr/src/cmake-2.8.6 &&./configure &&make &&make install
             if [ $? -eq 0 ];then
                 echo -e "\033[32m Cmake Install OK!!\033[0m"
               else
                 echo -e "\033[31m Cmake Install filed!!\033[0m"
                 exit
             fi
tar -axvf $mysql -C /usr/src
cd /usr/src/mysql-5.5.22
cmake -DCMAKE_INSTALL_PREFIX=$mysql_install \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EXTRA_CHARSETS=all \
-DSYSCONFDIR=/etc &&make &&make install
sleep 5
chown -R mysql:mysql $mysql_install
rm -rf /etc/my.cnf
\cp /usr/src/mysql-5.5.22/support-files/my-medium.cnf /etc/my.cnf
\cp /usr/src/mysql-5.5.22/support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
sleep 3
/usr/local/mysql/scripts/mysql_install_db \
--user=mysql \
--basedir=/usr/local/mysql/ \
--datadir=/usr/local/mysql/data/
echo "PATH=$PATH:/usr/local/mysql/bin">>/etc/profile
source /etc/profile
chkconfig --add mysqld
chkconfig --level 35 mysqld on
service mysqld start
           if [ $? -eq 0 ];then
               echo -e "\033[32m Mysql Install OK\033[0m"
            else
              echo -e "\033[31m Mysql Install Filed!!\033[0m"
             exit 
           fi
       fi
    fi
 fi
if [[ "$1" -eq "2" ]];then
sed -i -e '49 s/log-bin=mysql-bin/log-bin=master-bin/' /etc/my.cnf
sed -i -e '49a log-slave-updates=true' /etc/my.cnf
sed -i -e '58 s/1/10/' /etc/my.cnf
service mysqld restart
mysqladmin -uroot password zmkj@007
mysql -uroot -pzmkj@007 mysql </root/mysql.txt
fi
if [[ "$1" -eq "3" ]];then
read -p "请输入主数据库IP地址" Y
read -p "请输入Mysql从端IP地址" IP
read -p "请输入Mysql从端密码" M
file=`mysql -uroot -h $Y -pzmkj@007 -e 'show master status' |tail -1 |awk '{print $1}'`
position=`mysql -uroot -h $Y -pzmkj@007 -e 'show master status' |tail -1 |awk '{print $2}'`
sshpass -p "$M" ssh root@$IP
  for a in "ntp ncurses-devel";do
      yum -y install $a
  done
ntpdate $IP
#add corntab
user=`whoai`
echo "1 * * * * /usr/sbin/ntpdate $IP" >>/var/spool/cron/${user}
service cron restart
MYSQL=/root/mysql-5.5.22.tar.gz
CMAKE=/root/cmake-2.8.6.tar.gz
MYSQL_INSTALL=/usr/local/mysql
     if [ -f $CMAKE ];then
         tar -axvf $CMAKE -C /usr/src
         cd /usr/src/cmake-2.8.6 &&./configure &&make &&make install
     fi
           if [ $? -eq 0 ];then
               echo -e "\033[32m CMAKE INSTALL OK !\033[0m"
            else
               echo -e "\033[31m CMAKE INSTALL FAIDE!\033[0m"
           fi
tar -axvf $MYSQL -C /usr/src
cd /usr/src/mysql-5.5.22
cmake -DCMAKE_INSTALL_PREFIX=$MYSQL_INSTALL \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EXTRA_CHARSETS=all \
-DSYSCONFDIR=/etc/ &&make &&make install
\cp -rf /usr/src/mysql-5.5.22/support-files/my-medium.cnf /etc/my.cnf
\cp -rf /usr/src/mysql-5.5.22/support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig --level 35 mysqld on
echo "export PATH=$PATH:/usr/local/mysql/bin"  >>/etc/profile && source /etc/profile
useradd -M -s /sbin/nologin mysql
chown -R mysql.mysql $MYSQL_INSTALL
/usr/local/mysql/scripts/mysql_install_db \
--basedir=$MYSQL_INSTALL \
--datadir=/usr/local/mysql/data \
--user=mysql &&service mysqld start
sed -i -e '37a slave_skip_errors = 1062' /etc/my.cnf
sed -i -e '50a relay-log=relay-log-bin\nrelay-log-index=slave-relay-bin.index' /etc/my.cnf
sed -i -e '60 s/1/20/' /etc/my.cnf
service mysqld restart
mysqladmin -uroot password zmkj@007
mysql -uroot -h $IP -pzmkj@007 -e "change master to master_host='$Y',master_user='slave',master_password='123',master_log_file='$file',master_log_pos=$position;"
mysql -uroot -h $IP -pzmkj@007 -e 'start slave;'
                 if [ $? -eq 0 ];then
                    echo -e "\033[32m Mysql Slave INstall OK!!\033[0m"
                 else
                    echo -e "\033[31m Mysql Slave Install failed!\033[0m"
                 fi
fi
