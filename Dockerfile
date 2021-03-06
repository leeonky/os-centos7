# centos7 with some basic tools

FROM daocloud.io/centos:7.2.1511

###### EPEL repository
#RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

###### install basic tools
RUN yum -y install \
	sudo \
	wget \
	perl \
	ack \
	which \
	net-tools.x86_64 \
	glibc.i686 \
	xdg-utils \
	bash-completion \
	unzip.x86_64 mount.nfs

###### ssh server and client
RUN yum -y install openssh-server.x86_64 openssh-clients.x86_64  && \
	ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N "" && \
	ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N "" && \
	ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""

###### add user devuser
ENV DEV_HOME /home/devuser
RUN ( printf 'devuser\ndevuser\n' | passwd ) && \
	useradd devuser && \
	( printf 'devuser\ndevuser\n' | passwd devuser ) && \
	( echo 'devuser    ALL=(ALL)       NOPASSWD:ALL' > /etc/sudoers.d/devuser ) && \
	sed 's/^Defaults \{1,\}requiretty'//g -i /etc/sudoers && \
	mkdir -p $DEV_HOME/bin && \
	chown devuser:devuser $DEV_HOME/bin

ADD lang.sh /etc/profile.d/
USER devuser

###### enable .bashrc.d
RUN echo 'for f in $(ls ~/.bashrc.d/); do source ~/.bashrc.d/$f; done' >> $DEV_HOME/.bashrc && \
	mkdir -p $DEV_HOME/.bashrc.d

EXPOSE 22
CMD sudo /usr/sbin/sshd -D

