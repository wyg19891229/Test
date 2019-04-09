#!/bin/bash

#Proxy information
Proxy_URL=http://3.93.19.9:9091

#Netbrain Config  Information
FrontServer_ID=oraclefs
FrontServer_Key=oraclefs
Tenant_Name=oracleTenant

#Installation Path
Default_Path=/home

yum  install glibc.x86_64 glibc.i686 libstdc++.x86_64 libstdc++.i686 libuuid.x86_64 libuuid.i686 pam.x86_64 pam.i686 -y
yum  install openssl 1.0.2 -y  
cd ${Default_Path}
mkdir netbraintemp
cd netbraintemp

# download FrontServer installation
wget https://s3.amazonaws.com/packages.aws.netbraintech.com/IE/7.1a1/Release/FS/netbrain-frontserver-x86_64-linux-rhel7.tar.gz

# download chisel 
wget https://s3.amazonaws.com/packages.aws.netbraintech.com/PATCH/7.1a1Proxy/chisel_linux_amd64

tar -zxvf netbrain-frontserver-x86_64-linux-rhel7.tar.gz
cd FrontServer/
sudo ./install.sh
sleep 3
cd /opt/netbrain/frontserver/conf
#modify the Front Server Controller = 129.146.155.87:9095,Enable SSL = Yes, Front Server ID=oraclefs and Authentication Key =oraclefs
sed -i "s/Front Server Controller =.*/Front Server Controller = 127.0.0.1:9095/" /opt/netbrain/frontserver/conf/register_frontserver.conf
sed -i "s/Enable SSL =.*/Enable SSL = Yes/" /opt/netbrain/frontserver/conf/register_frontserver.conf
sed -i "s/Front Server ID =.*/Front Server ID=${FrontServer_ID}/" /opt/netbrain/frontserver/conf/register_frontserver.conf
sed -i "s/Authentication Key =.*/Authentication Key =${FrontServer_Key}/" /opt/netbrain/frontserver/conf/register_frontserver.conf
sed -i "s/Tenant Name =.*/Tenant Name =${Tenant_Name}/" /opt/netbrain/frontserver/conf/register_frontserver.conf

cd ${Default_Path}/netbraintemp
chmod 755 chisel_linux_amd64
./chisel_linux_amd64 client -v --proxy ${Proxy_URL}  129.146.155.87:9098 0.0.0.0:9095:10.0.4.3:9095 &

sleep 3
cd /opt/netbrain/frontserver/bin
sudo ./registration
sleep 3
setcap cap_net_raw,cap_net_admin=eip /opt/netbrain/frontserver/bin/frontserver
service NetBrainFrontServer restart
echo "Done"

