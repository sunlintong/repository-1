
ad mysql compressed file 
if [ `find / -name "mysql*.tar.gz" | wc -l` -eq 0 ];then
echo  "mysql download begin---------"
wget http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.15.tar.gz -P /tmp   
echo  "mysql compressed file download complete"  
else
echo "you have download mysql compressed file package"
fi  
  
#decompression mysql package   
cd /tmp
echo  "mysql decompression begin---------"
tar xzvf mysql-5.6.15.tar.gz 
echo  "mysql decompression complete"


#configuration before compilation and installation
cd mysql-5.6.15
echo  "mysql configuration begin---------"
cmake \
   -DCMAKE_INSTALL_PREFIX=/usr/local/webserver/mysql/ \
   -DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
   -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci \
   -DWITH_EXTRA_CHARSETS=all -DWITH_MYISAM_STORAGE_ENGINE=1 \
   -DWITH_INNOBASE_STORAGE_ENGINE=1 \
   -DWITH_MEMORY_STORAGE_ENGINE=1 \
   -DWITH_READLINE=1 \
   -DWITH_INNODB_MEMCACHED=1 \
   -DWITH_DEBUG=OFF -DWITH_ZLIB=bundled -DENABLED_LOCAL_INFILE=1 \
   -DENABLED_PROFILING=ON \
   -DMYSQL_MAINTAINER_MODE=OFF \
   -DMYSQL_DATADIR=/usr/local/webserver/mysql/data \
   -DMYSQL_TCP_PORT=3306
echo  "mysql configuration complete"

#compile
echo  "compile mysql begin---------"
make
echo  "compile mysql complete---------"

#install
echo  "install mysql begin---------"
make install
echo  "install mysql complete---------"


#addGroup  
echo  "add new group mysql---------"
groupadd mysql


#addUser
echo  "add new user mysql belong to mysql group---------" 
adduser -g mysql mysql
echo "complete to add new group---mysql and new user---mysql"


#create new diretory "binlog" in /usr/local/webserver/mysql ,which place mysql's cofiguration file
#create new directory /www/data_mysql to place the database file
mkdir -p /usr/local/webserver/mysql/binlog /www/data_mysql

echo "complete to create directory /usr/local/webserver/mysql/binlog and /www/data_mysql"



#make user mysql.mysql to be the two direcrory's owner
chown mysql.mysql /usr/local/webserver/mysql/binlog/ /www/data_mysql/
echo "make user mysql.mysql to be the two direcrory's owner"

#use the content below to replace mysql's start configuration file "/etc/my.cnf" 
echo "begin to change mysql's start configuration file "/etc/my.cnf" "

echo "[client]
port = 3306
socket = /tmp/mysql.sock
[mysqld]
replicate-ignore-db = mysql
replicate-ignore-db = test
replicate-ignore-db = information_schema
user = mysql
port = 3306
socket = /tmp/mysql.sock
basedir = /usr/local/webserver/mysql
datadir = /www/data_mysql
log-error = /usr/local/webserver/mysql/mysql_error.log
pid-file = /usr/local/webserver/mysql/mysql.pid
open_files_limit = 65535
back_log = 600
max_connections = 5000
max_connect_errors = 1000
table_open_cache = 1024
external-locking = FALSE
max_allowed_packet = 32M
sort_buffer_size = 1M
join_buffer_size = 1M
thread_cache_size = 600
#thread_concurrency = 8
query_cache_size = 128M
query_cache_limit = 2M
query_cache_min_res_unit = 2k
default-storage-engine = MyISAM
default-tmp-storage-engine=MYISAM
thread_stack = 192K
transaction_isolation = READ-COMMITTED
tmp_table_size = 128M
max_heap_table_size = 128M
log-slave-updates
log-bin = /usr/local/webserver/mysql/binlog/binlog
binlog-do-db=oa_fb
binlog-ignore-db=mysql
binlog_cache_size = 4M
binlog_format = MIXED
max_binlog_cache_size = 8M
max_binlog_size = 1G
relay-log-index = /usr/local/webserver/mysql/relaylog/relaylog
relay-log-info-file = /usr/local/webserver/mysql/relaylog/relaylog
relay-log = /usr/local/webserver/mysql/relaylog/relaylog
expire_logs_days = 10
key_buffer_size = 256M
read_buffer_size = 1M
read_rnd_buffer_size = 16M
bulk_insert_buffer_size = 64M
myisam_sort_buffer_size = 128M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1
myisam_recover
interactive_timeout = 120
wait_timeout = 120
skip-name-resolve
#master-connect-retry = 10
slave-skip-errors = 1032,1062,126,1114,1146,1048,1396
#master-host = 192.168.1.2
#master-user = username
#master-password = password
#master-port = 3306
server-id = 1
loose-innodb-trx=0 
loose-innodb-locks=0 
loose-innodb-lock-waits=0 
loose-innodb-cmp=0 
loose-innodb-cmp-per-index=0
loose-innodb-cmp-per-index-reset=0
loose-innodb-cmp-reset=0 
loose-innodb-cmpmem=0 
loose-innodb-cmpmem-reset=0 
loose-innodb-buffer-page=0 
loose-innodb-buffer-page-lru=0 
loose-innodb-buffer-pool-stats=0 
loose-innodb-metrics=0 
loose-innodb-ft-default-stopword=0 
loose-innodb-ft-inserted=0 
loose-innodb-ft-deleted=0 
loose-innodb-ft-being-deleted=0 
loose-innodb-ft-config=0 
loose-innodb-ft-index-cache=0 
loose-innodb-ft-index-table=0 
loose-innodb-sys-tables=0 
loose-innodb-sys-tablestats=0 
loose-innodb-sys-indexes=0 
loose-innodb-sys-columns=0 
loose-innodb-sys-fields=0 
loose-innodb-sys-foreign=0 
loose-innodb-sys-foreign-cols=0

slow_query_log_file=/usr/local/webserver/mysql/mysql_slow.log
long_query_time = 1
[mysqldump]
quick
max_allowed_packet = 32M" >/etc/my.cnf

echo "complete to change mysql's start configuration file "/etc/my.cnf" "



#initial the database by the file mysql_install_db 
#assign the default start file /etc/my.cnf
#assign the mysql server's user is mysql
#assign the path to the MySQL installation directory is /usr/local/webserver/mysql
#assign the path to the MySQL data directory is /www/data_mysql
/usr/local/webserver/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf  --user=mysql --basedir=/usr/local/webserver/mysql --datadir=/www/data_mysql


#the following 6 commond is to set mysql to start every time we start CentOS
cd /usr/local/webserver/mysql/
#make user mysql to be the owner of the current directory and it's subdirectory
chown -R mysql:mysql ./
cp support-files/mysql.server /etc/rc.d/init.d/mysqld
#add mysql server in chkconfig tool service list
chkconfig --add mysqld 
#change the default start level of mysql service
chkconfig --level 35 mysqld on
#start mysql server
service mysqld start
echo "complete to start mysql server and set is to start every time we start CentOS"

#link all files in /usr/local/webserver/mysql/bin to /usr/bin
ln -s /usr/local/webserver/mysql/bin/* /usr/bin


#create database myapp
mysql<<EOF
create database if not exists myapp;
show databases;
exit
EOF
echo -e "\ncomplete login and create database myapp!"
