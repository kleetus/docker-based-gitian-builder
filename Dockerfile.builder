FROM ubuntu:trusty
MAINTAINER Chris Kleeschulte <chrisk@bitpay.com>
RUN useradd -d /home/ubuntu -m -s /bin/bash ubuntu && \
mkdir -p -m0755 /var/run/sshd && \
mkdir -p /home/ubuntu/.ssh && \
mkdir -p /root/.ssh && \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends -yq install \
locales \
build-essential \
openssh-server \
rsync && \
sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
locale-gen en_US.UTF-8 && \
update-locale LANG=en_US.UTF-8
EXPOSE 22
RUN ssh-keygen -t rsa -N '' -f /home/ubuntu/.ssh/id_rsa && \
echo '#!/bin/bash' > /root/runit.sh && \
echo 'mkdir -p /privkey' >> /root/runit.sh && \
echo 'mkdir -p /pubkey' >> /root/runit.sh && \
echo 'cp /home/ubuntu/.ssh/id_rsa.pub /home/ubuntu/.ssh/authorized_keys' >> /root/runit.sh && \
echo 'cp /home/ubuntu/.ssh/id_rsa.pub /root/.ssh/authorized_keys' >> /root/runit.sh && \
echo 'chown root.root /root/.ssh/authorized_keys' >> /root/runit.sh && \
echo 'cp /home/ubuntu/.ssh/id_rsa.pub /pubkey/' >> /root/runit.sh && \
echo 'cp /home/ubuntu/.ssh/id_rsa /privkey/' >> /root/runit.sh && \
echo 'chown -R ubuntu.ubuntu /home/ubuntu/.ssh/' >> /root/runit.sh && \
echo '/usr/sbin/sshd -D' >> /root/runit.sh && \
chmod +x /root/runit.sh
CMD ["/root/runit.sh"]
