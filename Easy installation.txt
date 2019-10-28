
Please follow

Step 0 Gte code
	git clone https://github.com/michaelJava69/ansible-automation.git
	cd ansible-automation

Step1 Vagrant up
 	vagrant up
 	vagrant ssh mgmt
Step2 Create pub/private keys
	i. 	ssh-keygen
		press return x4
	ii. 	./set-knownhost.sh                      # add list of server alias to knowhost on mgmt server
	iii. 	ansible-playbook -i hosts ssh-addkey.yml  --ask-pass 
	iv.     password = vagrant
	
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
	
step 4  Doing some site tests    ansible-playbook -i hosts site.yml		 # from your local machine please/ ubuntu64 please with Pythin installed
	i. 	./bootstrap-local						# setup environment 
	ii. 	git clone https://github.com/michaelJava69/project.git
	ii. 	nosetests --verbosity=2 project      # https://realpython.com/testing-third-party-apis-with-mocks/
		This should report a fal on one of the tests looking for web1 50% of the time



======================================================
Recommendations
======================================================

I can easily setup a rolling update facility that can be used to update the website in seres so that no loss of service happens


==========================================================================================================================
	
Note
====
The reason you are able to view server details is curtesy to the Ansible Gather facts command being turend on which provides following details in index.html file

	<p>Served by {{ ansible_hostname }} ({{ ansible_eth1.ipv4.address }}).</p>
	
Increase number of websites
	I. alter hosts
	ii. update vagrant file web loop
	ii. update set-knownhost.sh  
	
========================================================================================
For solution to a Load balancer problem see Problem solving Operational Issues README.md
========================================================================================