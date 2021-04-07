# Vagrant Ansible Automation 

DevOps Demo is a demonstration of a deployment to two web servers using ansible
The infra will consist of four boxes. 

```bash
i. 	A local virula box termend the management server that will be the main controller for Ansible.
ii. 	A Load balancer virtual box that is the HAProxy server version 1.4.24 by far the most industry standard load balancer on the market # http://www.haproxy.org/#docs
iii. 	x2 .....n nginx servers as requested
```
## Summary 

```bash
i. 	4 boxes in total , totally managed by Vagrant
ii. 	Git installed to facilitate server rolling updates if planned
iii.	A python test harness provided to be run locally instructions given
iv.	Full instructions
v.	Html screen shots of the website clearly showing loadbalancing together with HAProxy Loadbalancer monitoring page
```

## Issues faced

```bash
i. 	bionic/ubuntu64 failed to download to my laptop...perhaphs curruption of my installation or Vgarent site issues. trusty/bionic64 used instead
ii. 	Also tested on bentos/ubuntu and issues found and fixed with Load balancer version  - see operational issues
```

## Installation

```bash

Pre-tasks   Get code
	i.  	git clone https://github.com/michaelJava69/ansible-automation.git
	ii. 	cd vagrant-ansible-automation
```
```bash

Step1  Bringin up vagrant 
 	i.  	vagrant up
 	ii. 	vagrant ssh mgmt
```
```bash

Step2 Create pub/private keys
	i. 	ssh-keygen
		press return x4
	ii. 	./set-knownhost.sh                      # add list of server alias to knowhost on mgmt server
	                                                  had some issues with windows characters in file ran
							  [ sed -i -e 's/\r$//' set-knownhost.sh ]
							  
	iii. 	ansible-playbook -i hosts ssh-addkey.yml  --ask-pass 
	iv.     password = vagrant
```
```bash

step 3  Bring up site
	i. 	ansible-playbook -i hosts site.yml
	ii.     http://localhost:8080/haproxy?stats	# Shows the stats brought back by haproxy   	#from your local machine please
	iii.	http://localhost:8080    		# shows the web page being load balanced	#from your local machine pleasel
	
	iv.     $  curl -I http://localhost:8080        # from your local machine please
			  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
							 Dload  Upload   Total   Spent    Left  Speed
			  0   636    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0HTTP/1.1 200 OK
			Server: nginx
			Date: Mon, 28 Oct 2019 13:03:12 GMT
			Content-Type: text/html
			Content-Length: 636
			X-Backend-Server: web2
			Cache-Control: private
			Accept-Ranges: bytes
			
	v.      $  curl -I http://localhost:8080
			  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
							 Dload  Upload   Total   Spent    Left  Speed
			  0   636    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0HTTP/1.1 200 OK
			Server: nginx
			Date: Mon, 28 Oct 2019 13:04:13 GMT
			Content-Type: text/html
			Content-Length: 636
			X-Backend-Server: web1
			Cache-Control: private
			Accept-Ranges: bytes
```
```bash

step 4  Doing some site tests    ansible-playbook -i hosts site.yml		 # from your local machine please/ ubuntu64 please with Pythin installed
	i. 	./bootstrap-local						# setup environment 
	ii. 	git clone https://github.com/michaelJava69/project.git
	iii. 	nosetests --verbosity=2 project      # https://realpython.com/testing-third-party-apis-with-mocks/
	iv.	This should report a fail on one of the tests looking for web1 50% of the time


```

## Recommendations

```bash
	i.	I can easily setup a rolling update facility that can be used to update the website in seres so that no loss of service happens

```

	
## Note

```bash
The reason you are able to view server details is curtesy to the Ansible Gather facts command being turend on which provides following details in index.html file

	<p>Served by {{ ansible_hostname }} ({{ ansible_eth1.ipv4.address }}).</p>
	
Increase number of websites
	i. 	alter hosts
	ii. 	update vagrant file web loop
	iii. 	update set-knownhost.sh  
```


### For solution to a Load balancer problem see Problem solving Operational Issues README.md

```bash
	See also html screen shots of the website and Loadbax monitoring page
```

### lb snippet of haproxy.cfg

```bash
backend app
           listen episode 46 10.0.2.15:80
        balance     roundrobin
            server web1 10.0.15.21 check port 80
            server web2 10.0.15.22 check port 80
```
