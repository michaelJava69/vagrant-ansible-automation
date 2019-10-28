Theory
======

Vagrant has has an Ansible provisioning option, but it requires you to install Ansible on your local machine.
To me this means creation of an environment outside of your test environment and on your own local system. 
In doing this it would cuase the following issues

1. You have to make sure you have a local system that is compatible.
2. Requires the operator has UNIX environment best suited for Ansible.
2. It is possible that that enivonment would be tampered with by introducing possible code drift.
 

Vagrantfile

1. Will spin up a management node 
   Will have an ubuntu OS
   Set fixed static address (for eth1 zone) to be used internally for cummunication so that we can utilise later in /etc/hosts to provide readble alias for iPs
   10.0.15.10  mgnt
   10.0.15.11  lb
   10.0.15.21  web
   10.0.15.22  web
   
   note :   	eth1 allows ssh and dhcpv6 access from outside box but is in public zone
    		if greater firewall protection needed this zone could be made internal 
    		                             	:  sudo firewall-cmd --permanent --zone=internal --change-internal=eth1
    		Add the above ip addresses to this internal zone
    		  				:  sudo firewall-cmd --permanent --add-source="10.0.15.10" repeat for all ip addresses
    		  				:  sudo firewall-cmd --permanent --add-port=80/tcp
    		  				:  sudo firewall-cmd reload
    		  				
A bootstrap file is used to 

1.	update /etc/hosts enabling aliases for the static ip address set up in zone eth1 for each nodes
	Vagrant can already suo between nodes becuase when it is set up it creates a dynamic NDS lookup that Vagrant uses to 
	travel between nodes with instaructions such as
	vagrant mgnt ssh
	vagrant lb ssh
	vagrant web1 ssh
	vagrant web2 ssh
2.      Install ansible from the asnible managment repository
3. 	Copy our workspace to the vagrant home directory and give it vagrant ownership



boostrap-mgnt
=============

# install ansible (http://docs.ansible.com/intro_installation.html)
apt-get -y install software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get -y install ansible

# copy examples into /home/vagrant (from inside the mgmt node)
cp -a /vagrant/examples/* /home/vagrant
chown -R vagrant:vagrant /home/vagrant

# configure hosts file for our internal network defined by Vagrantfile
cat >> /etc/hosts <<EOL

# vagrant environment nodes
10.0.15.10  mgmt
10.0.15.11  lb
10.0.15.21  web1
10.0.15.22  web2
10.0.15.23  web3
10.0.15.24  web4
10.0.15.25  web5
10.0.15.26  web6
10.0.15.27  web7
10.0.15.28  web8
10.0.15.29  web9
EOL


Enabling vms to communicate (admin to sudo between management server and nodes)

sshkeygen 
==========
#################################################
Genarate it
##################################################

Step 1:	ssh-keygen
	vagrant@mgmt:~$ ssh-keygen
	Generating public/private rsa key pair.
	Enter file in which to save the key (/home/vagrant/.ssh/id_rsa):
	Enter passphrase (empty for no passphrase):
	Enter same passphrase again:
	Your identification has been saved in /home/vagrant/.ssh/id_rsa.
	Your public key has been saved in /home/vagrant/.ssh/id_rsa.pub.
	The key fingerprint is:
	35:9a:5d:67:e2:e8:be:71:8e:45:d6:54:5e:0d:a8:f4 vagrant@mgmt
	The key's randomart image is:
	+--[ RSA 2048]----+
	|             ...+|
	|          . .  oo|
	|         .ooo + .|
	|         =.=E*   |
	|        S o + .  |
	|         . o     |
	|          o o    |
	|         . *     |
	|          +..    |
	+-----------------+

########################################
Step 2 :Copy it over to autherized keys on nodes
##############################################

	ssh-copy-id -i ~/.ssh/id_rsa user@host

	ssh-copy-id -i ~/.ssh/id_rsa vagrant@lb
	ssh-copy-id -i ~/.ssh/id_rsa vagrant@web2
	ssh-copy-id -i ~/.ssh/id_rsa vagrant@web1


	vagrant@mgmt:~/.ssh$ ssh-copy-id -i ~/.ssh/id_rsa vagrant@web1
	The authenticity of host 'web1 (10.0.15.21)' can't be established.
	ECDSA key fingerprint is 75:13:45:cf:86:19:ae:15:1f:c8:c3:af:9c:8d:33:e5.
	Are you sure you want to continue connecting (yes/no)? yes
	/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
	/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
	vagrant@web1's password: <vagrant>

	Number of key(s) added: 1

	Now try logging into the machine, with:   "ssh 'vagrant@web1'"
	and check to make sure that only the key(s) you wanted were added.


2nd way  (Step 2)
=======
	ssh-keyscan web1 web2 lb >> ~/.ssh/known_hosts
 
	Pull (x2)x3 hash generated public keys into ansible management servers known_keys 

3rd way  (step2)

	Replacing Step 2 above with an ansible playbook
	======================================
	Ansible playbook
	=================================
	keygen mover
	ansible-playbook -i hosts ssh-addkey.yml

	apt
	ansible -i hosts web1 -m apt -a "name=ntp state=installed"    				: wrong way need elevated rights
	ansible -i hosts web1 -m apt -a "name=ntp state=installed" --sudo			: right
	
================
VERYFYING THINGS
================

ansible -i hosts all -m ping --ask-pass
ansible -i hosts all -m ping

vagrant@mgmt:/vagrant/examples$ ps -x
  PID TTY      STAT   TIME COMMAND
 2983 ?        S      0:00 sshd: vagrant@pts/0
 2984 pts/0    Ss     0:00 -bash
 3783 ?        Ss     0:00 ssh: /home/vagrant/.ansible/cp/ae750fdd40 [mux]
 3787 ?        Ss     0:00 ssh: /home/vagrant/.ansible/cp/3eee52bc5e [mux]
 3790 ?        Ss     0:00 ssh: /home/vagrant/.ansible/cp/e51df67eb4 [mux]
 3820 pts/0    R+     0:00 ps -x



=========================
Common ansible commands
=========================

Checking uptime
ansible -i hosts web -m shell -a "uptime"
ansible -i hosts all -m shell -a "uptime"

reboot
ansible -i hosts web -m shell -a "/sbin/reboot"

Gathering facts
ansible -i hosts web1 -m setup | less
web1

ansible -i hosts web1 -m setup -a "filter=ansible_distribution"
web1

ansible -i hosts web1 -m setup -a "filter=ansible_distribution*"
web1

============================================
Setting up a simple website using nginx
===========================================
Templates
=========
1. nginx.conf.j2
	Lets review the nginx server configuration file.
	set mimemtypes
		types {
			text/html                               html htm shtml;
			text/css                                css;
			text/xml                                xml rss;
			image/gif                               gif;
			image/jpeg                              jpeg jpg;
			application/x-javascript                js;
			application/atom+xml
			atom;

			text/mathml                             mml;
			text/plain                              txt;
			text/vnd.sun.j2me.app-descriptor        jad;
			text/vnd.wap.wml                        wml;
			text/x-component                        htc;

			image/png                               png;
			image/tiff                              tif tiff;
		 
default_type application/octet-stream;
	This is so static files (or just GET requests) with unspecified mime type will always prompt 
	the download action in the browser and never cause to open/display them in the browser window.
	
tcp_nopush "on";
	Combined to sendfile, tcp_nopush ensures that the packets are full before being sent to the client.
	This greatly reduces network overhead and speeds the way files are sent
	
access.log (owned by root)
	10.0.15.11 - - [25/Oct/2019:18:33:26 +0000] "GET / HTTP/1.1" 200 632 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.18362"

types_hash_max_size 2048
	Affects page size
	
Disabled cahce only for testing purposes so I sould really test load balancer

include /etc/nginx/conf.d/*.conf;                                creates links foor file below
include /etc/nginx/sites-enabled/*;	                         Describes the server

default-site.j2
===============
2. server {
	
	listen 80;
	server_name {{ ansible_hostname }};   #{{ ansible_hostname }}   : Ansible gathered /Fact set the server name to the hostname of our remote machines.
	root /usr/share/nginx/html;
	index index.html index.htm;

	location / {
		try_files $uri $uri/ =404;
	}

	error_page 404 /404.html;
	error_page 500 502 503 504 /50x.html;
	location = /50x.html {
		root /usr/share/nginx/html;
	}
}

vagrant@mgmt:/vagrant/examples$ ansible -i hosts all -m setup -a "filter=ansible_hostname"

web1 | SUCCESS => {
    "ansible_facts": {
        "ansible_hostname": "web1",
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false
}
web2 | SUCCESS => {
    "ansible_facts": {
        "ansible_hostname": "web2",
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false
}
lb | SUCCESS => {
    "ansible_facts": {
        "ansible_hostname": "lb",
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false
}

3. index.html.j2

	<p>Served by {{ ansible_hostname }} ({{ ansible_eth1.ipv4.address }}).</p>    # uses Ansible gathered facts to get hostname and host ip address

4. haproxy.cfg.j2   : The Load Balancer

 	https://www.linode.com/docs/uptime/loadbalancing/how-to-use-haproxy-for-load-balancing/

        ========================== format ===================== https://www.haproxy.com/blog/the-four-essential-sections-of-an-haproxy-configuration/
        global
	    # global settings here
	
	defaults
	    # defaults here
	
	frontend
	    # a frontend that accepts requests from clients
	
	backend
	==========================================================
	
    # servers that fulfill the requests

    	# enable stats uri
	stats enable
    	stats uri /haproxy?stats	

	backend app
	    {% for host in groups['lb'] %}
	       listen episode46 {{ hostvars[host]['ansible_eth0']['ipv4']['address'] }}:80
	    {% endfor %}
	    balance     roundrobin
	    {% for host in groups['web'] %}
	        server {{ host }} {{ hostvars[host]['ansible_eth1']['ipv4']['address'] }} check port 80
            {% endfor %}
================
Results
==============
cat /etc/haproxy/haproxy.cfg
	backend app
	           listen episode46 10.0.2.15:80
	        balance     roundrobin
	            server web1 10.0.15.21 check port 80
	            server web2 10.0.15.22 check port 80

    
http://localhost:8080/haproxy?stats	# Shows the stats brought back by haproxy
http://localhost:8080    		# shows the web page being load balanced


=================
Test
===============

sudo apt-get install apache2-utils
ab -n 10000 -c 25 http://localhost:8080/# vagrant-ansible-automation
