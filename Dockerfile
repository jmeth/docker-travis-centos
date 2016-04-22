FROM centos:7
MAINTAINER jmeth <jmeth@users.noreply.github.com>
RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs
RUN yum -y update; yum clean all; \
    (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*; \
    rm -f /etc/systemd/system/*.wants/*; \
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*
RUN yum -y install epel-release; \
    yum -y install gcc git sudo python-devel python-pip; \
    pip install --upgrade ansible; \
    sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers; \
    mkdir -p /etc/ansible/; \
    yum -y purge gcc python-devel python-pip; \
    yum -y autoremove; \
    yum clean all; \
    echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]