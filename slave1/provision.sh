#!/bin/bash

export http_proxy=http://proxy-us.intel.com:911/
export https_proxy=http://proxy-us.intel.com:911/

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

apt-get install -qy default-jdk zookeeperd mesos=0.20.\*
touch /etc/mesos-slave/?checkpoint
touch /etc/mesos-slave/?strict

# Stop and disable the Mesos Master service
service mesos-master stop
echo manual | tee /etc/init/mesos-master.override

# Stop and disable the Zookeeper service
service zookeeper stop
echo manual | tee /etc/init/zookeeper.override
apt-get -y remove --purge zookeeper

# Set slave ip
echo 33.33.33.101 | tee /etc/mesos-slave/ip
cp /etc/mesos-slave/ip /etc/mesos-slave/hostname

# Specify Zookeeper service
echo zk://33.33.33.100:2181/mesos | tee /etc/mesos/zk

# Restart service
service mesos-slave restart
