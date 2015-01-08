#!/bin/bash

# remove unused services
service puppet stop
update-rc.d -f puppet remove
service chef-client stop
update-rc.d -f chef-client remove

# avoid downloading useless stuff
cat <<! >/etc/apt/apt.conf.d/99notranslations
Acquire::Languages "none";
!
cat <<! |debconf-set-selections
debconf debconf/frontend string noninteractive
postfix postfix/mailname string $HOSTNAME
postfix postfix/main_mailer_type select Local only
!
# Remove booting timeouts
cat >>/etc/default/grub <<!
GRUB_TIMEOUT=0
GRUB_RECORDFAIL_TIMEOUT=0
GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"
!
update-grub

# extra apt repos
echo "deb http://repos.mesosphere.io/ubuntu/ trusty main" >/etc/apt/sources.list.d/mesosphere.list
apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
echo "deb https://get.docker.io/ubuntu docker main" >/etc/apt/sources.list.d/docker.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
apt-get update -qq

# basics setup
apt-get install -qy curl python-setuptools python-pip python-software-properties btrfs-tools

apt-get install -qy default-jdk zookeeperd mesos=0.20.\* marathon=0.7.\* chronos=2.3.\*
mkdir -p /etc/marathon/conf
touch /etc/marathon/conf/?checkpoint
echo 900000 >/etc/marathon/conf/task_launch_timeout
echo http_callback >/etc/marathon/conf/event_subscriber
echo manual >/etc/init/marathon.override
mkdir -p /etc/chronos/conf
touch /etc/chronos/conf/?checkpoint
echo manual >/etc/init/chronos.override

# Stop and disable the Mesos Slave service
service mesos-slave stop
echo manual | tee /etc/init/mesos-slave.override

# Set master ip
echo 33.33.33.100 | tee /etc/mesos-master/ip
cp /etc/mesos-master/ip /etc/mesos-master/hostname

# Specify Zookeeper service
echo zk://33.33.33.100:2181/mesos | tee /etc/mesos/zk

# Set Zookeeper id
echo 1 | tee /etc/zookeeper/conf/myid

# Cluster name
echo Cluster001 | tee /etc/mesos-master/cluster

# Configure marathon
mkdir -p /etc/marathon/conf
cp /etc/mesos-master/hostname /etc/marathon/conf
cp /etc/mesos/zk /etc/marathon/conf/master
echo zk://33.33.33.100:2181/marathon | tee /etc/marathon/conf/zk

# Restart services
service zookeeper restart
service mesos-master restart
service marathon restart
