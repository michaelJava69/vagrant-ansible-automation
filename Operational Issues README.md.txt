====================================================================
1. Load balancer failing  HAProxy due to issues with version 1.6.4
======================================================================

Summary

This was only discovered when I had to move to bentos/ubuntu due to my Vagrant refusing to download bionic/ubuntu and trusty/ubuntu
So it seesm  that awareness is needed that different flavours of these boxes will affect the running services on them

https://superuser.com/questions/1080306/haproxy-configuration-errors 

service haproxy start

Log onto lb box

vagrant@lb:~$ systemctl status haproxy.service

? haproxy.service - HAProxy Load Balancer
   Loaded: loaded (/lib/systemd/system/haproxy.service; enabled; vendor preset: enabled)
   Active: failed (Result: start-limit-hit) since Mon 2019-10-28 11:30:14 UTC; 45s ago
     Docs: man:haproxy(1)
           file:/usr/share/doc/haproxy/configuration.txt.gz
  Process: 13612 ExecStartPre=/usr/sbin/haproxy -f ${CONFIG} -c -q (code=exited, status=1/FAILURE)
 Main PID: 13447 (code=exited, status=0/SUCCESS)

Oct 28 11:30:14 lb systemd[1]: haproxy.service: Control process exited, code=exited status=1
Oct 28 11:30:14 lb systemd[1]: Failed to start HAProxy Load Balancer.
Oct 28 11:30:14 lb systemd[1]: haproxy.service: Unit entered failed state.
Oct 28 11:30:14 lb systemd[1]: haproxy.service: Failed with result 'exit-code'.
Oct 28 11:30:14 lb systemd[1]: haproxy.service: Service hold-off time over, scheduling restart.
Oct 28 11:30:14 lb systemd[1]: Stopped HAProxy Load Balancer.
Oct 28 11:30:14 lb systemd[1]: haproxy.service: Start request repeated too quickly.
Oct 28 11:30:14 lb systemd[1]: Failed to start HAProxy Load Balancer.
Oct 28 11:30:14 lb systemd[1]: haproxy.service: Unit entered failed state.
Oct 28 11:30:14 lb systemd[1]: haproxy.service: Failed with result 'start-limit-hit'.


haproxy  -f /path/to/haproxy.cfg    # find path to proxy

vagrant@lb:/etc$ whereis haproxy.cfg
haproxy: /usr/sbin/haproxy /etc/haproxy /usr/share/man/man1/haproxy.1.gz

haproxy  -f /haproxy.cfg/usr/sbin/haproxy/haproxy.cfg   # wrong

haproxy  -f /etc/haproxy/haproxy.cfg   # correct

vagrant@lb:/etc$ haproxy  -f /etc/haproxy/haproxy.cfg
[ALERT] 300/113752 (13682) : parsing [/etc/haproxy/haproxy.cfg:38] : 'listen' cannot handle unexpected argument '10.0.2.15:80'.
[ALERT] 300/113752 (13682) : parsing [/etc/haproxy/haproxy.cfg:38] : please use the 'bind' keyword for listening addresses.
[ALERT] 300/113752 (13682) : Error(s) found in configuration file : /etc/haproxy/haproxy.cfg
[WARNING] 300/113752 (13682) : config : proxy 'michael' has no 'bind' directive. Please declare it as a backend if this was intended.
[WARNING] 300/113752 (13682) : config : missing timeouts for proxy 'michael'.
   | While not properly invalid, you will certainly encounter various problems
   | with such a configuration. To fix this, please ensure that all following
   | timeouts are set to a non-zero value: 'client', 'connect', 'server'.
[ALERT] 300/113752 (13682) : Fatal errors found in configuration.

nano /etc/haproxy/haproxy.cfg

# Ansible managed
global
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        root
    group       root
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats level admin

defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

    # enable stats uri
    stats enable
    stats uri /haproxy?stats

backend app
           listen michael 
           bind 10.0.2.15:80                                   # change  to add "bind"
        balance     roundrobin
            server web1 10.0.15.21 check port 80
            server web2 10.0.15.22 check port 80


vagrant@lb:/etc$ haproxy  -f /etc/haproxy/haproxy.cfg

[ALERT] 300/114254 (13697) : Starting frontend GLOBAL: cannot bind UNIX socket [/var/lib/haproxy/stats]
[ALERT] 300/114254 (13697) : Starting proxy michael: cannot bind socket [10.0.2.15:80]

===========================
All this done on lb box
==============================

==============================================================================
2. Other issue   ssh-keygen and key copy does not work on bionic/ubuntu
   Would have looked into this if I could download the bionic/ubuntu64 env again
==============================================================================
