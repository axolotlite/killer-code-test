**CKA Lab 09: cri-dockerd Installation**

### Tasks

**Install the Debian package** `cri-dockerd.deb`
**Enable and start the cri-dockerd service**
**Configure sysctl parameters persistently**

Configure these kernel params:
* Set `net.bridge.bridge-nf-call-iptables=1`
* Set `net.ipv6.conf.all.forwarding=1`
* Set `net.ipv4.ip_forward=1`
* Set `net.netfilter.nf_conntrack_max=131072`


**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.