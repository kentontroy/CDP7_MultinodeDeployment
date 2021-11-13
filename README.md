# Cloudera CDH Multinode Deployment
Automation for Cloudera Data Platform 7.x multinode deployment with Kerberos, KMS and TLS

CDP Multinode script using Docker on Mac/Windows 10
This will create brand new 5 instances on AWS( 1  master and 3  worker nodes and 1 gateway node)
The instance types can be customized
CDP DC will be installed with full security (Kerberos,TLS and KMS)

See the following guides for forked updates -- <br>
README-changes-in-forked-version.md <br>
README-troubleshooting.md <br>
README-aws-example.md <br>


## **Assumptions**:


 1. This document assumes that you have access to an AWS account
 2. Partners or their IT Dept can create their own VPC, Subnet, key-pair and security group in the same availability zone that will be used to create multi node instances in the script below.
 3. Request cloudera license from partner portal  
 4. Access to valid cloudera.com credentials to download binaries
 5. Access to the relevant script from partner portal here.
 6. Access to the following versions of docker are used for Mac OS and Windows 10 Pro. 
		https://hub.docker.com/editions/community/docker-ce-desktop-mac/
		https://hub.docker.com/editions/community/docker-ce-desktop-windows/

## AWS Dependencies:

 1. AWS keypair (e.g. “.pem”) files to use with the scripts
 2. Decide on AWS region/AZ (us-east-1 used in this example)
 3. Ensure an equivalent CentOS image is available in your AZ,Example: ami-02eac2c0129f6376b #CentOS-7x86_64 
 4. Create a VPC(or use default), subnet and Security Group (SG) where these nodes are in the same AZ. 
 5. Record the SG to be used in the config files. Make sure the SG is open to all hosts in security group.
		

## Download scripts, CDP DC bits and license info:

 
 1. Download this Github repo and save the files to your home directory (e.g. Users/hshah) *NOTE: For Windows, avoid using space in folder-names.* 
 2. Copy the license file to this directory. You should have requested a trial license from the partner portal. 
 3. Copy the AWS  ".pem" file into a home directory
 4. Create a directory for the Github repo, eg: mn-script. unzip the files here.
		

### Docker Setup:

On both Windows and Mac OS, Following commands are used to setup the environment --
	
We will execute the scripts to setup the 6-node cluster with all the relevant services. Kerberos,KMS and TLS will be setup by default. 
	

 1. Ensure docker desktop has been installed and is running without any issues on your laptop.
 2. Open a terminal on mac and command prompt on a windows machine. The set of instructions work on both Mac OS and Windows.
 3. git clone https://github.com/kentontroy/CDP7_MultinodeDeployment
 4. cd CDP7_MultinodeDeployment
 5. docker build -t cdp-ansible:latest .
 6. docker run --name cdp-ansible -d -it --volume $HOME:<YOUR DIR NAME> cdp-ansible:latest /bin/bash
 7. docker exec -it cdp-ansible /bin/bash
	
In Docker --
	
 8. $[root@2e3f9e83cf7a  ~]# eval 'ssh-agent -s'
		  
    SSH_AUTH_SOCK=/var/folders/3m/xs2m6r7x7_qg8wp11ggy8l000000gp/T//ssh-ASHkKOqJ6PpS/agent.51910; export SSH_AUTH_SOCK;
    SSH_AGENT_PID=51911; export SSH_AGENT_PID;
    echo Agent pid 51911;
	
 9.  Adding key-vault : Create the ansible vault file in the root directory to store the private key. 
     Note:It will ask for password to create vault, remember the password as we will store this in a password file as the next step
        
     [root@2e3f9e83cf7a  ~]# ansible-vault create keys.vault

 10. This will open up an editor similar to vi. Copy and paste your .pem contents, pay close attention at the indentation. Give the key name and space for " **|** ", **add 2 spaces for each line below key name** 
      
       For Example: keys.vault, give a \<name>_key ex: my_key: | as shown below
	
	 my_key: |
  	   -----BEGIN RSA PRIVATE KEY-----
  	   Madsfdasagafgfdgfdsgadhdjasvfgaertqrecsf
  	  [...]
  	  dfasdgretwreaqghaduogihafdkghareoighfdk=
  	  -----END RSA PRIVATE KEY-----
   
     NOTE: Record the private key name (eg: my_key) which will be used later in the config files
	
     You will be asked to enter a password. Save the password. You can use this password in case you want to view or edit the file at a later stage. Use ansible-        vault view or ansible-vault edit to make changes

     First verify if the vault file was created:

	 [root@2e3f9e83cf7a  ~]# ls -ltr /home/hshah/keys.vault

     You can use the following command to edit the ansible key vault file:

	 [root@373dab68775b  ~]# ansible-vault edit keys.vault
	   

 11. On docker, let's now create a simple file to store the Vault password, so you won't be prompted at runtime, create the file under your home directory
		
	[root@2e3f9e83cf7a  ~]# echo "YourPassword" > vault-password-file	
	[root@2e3f9e83cf7a  ~]# chmod 400 vault-password-file
		
      NOTE: Record the file path and file name. We will use it in the config files


 12. On docker, export the variables for the AWS keys as below:
            
		 export AWS_ACCESS_KEY_ID=AKIAQxxxxxx
	  	 export AWS_SECRET_ACCESS_KEY=uOI3N5KQZ8zbxxxxxxxxxx
	  	 


### Modify the configuration file:

At this point, you should have the scripts/repo under a folder called mn-script. If you don't already have it within the mn-script folder under the home directory then download/clone this repo and move it under the home directory so that is accessible via the docker container.

We will also need access to the vault, pem and password files that are stored in the home directory.

The home directory should be accessible via docker mapping of the folders. 


 13. Open ../config/stock.infra.aws.yml file
 14. Make changes to parameters in stock.infra.aws.krb.yml where it says \<replace me>. eg Owner,project,enddate,vpc,region,subnet and security group.

		#defaults for all instance groups
		region: <replace me> #provide AWS availability zone
		subnet: <replace me> #provide subnet ID
		security_group: <replace me> #provide security group ID
		image: ami-02eac2c0129f6376b  # CentOS-7 x86_64 #optional: replace with another AMI ID
		user: centos
		public_key_id: "{{ public_key }}"
		bootstrap: ""
		tags:
			owner: <replace me>
			enddate: <replace me>
			project: <replace me>
  
	  Example of what it should look like below:

		#defaults for all instance groups
		region: us-east-1
		subnet: subnet-12345abc78
		security_group: sg-12345abc78
		image: ami-02eac2c0129f6376b  # CentOS-7 x86_64
		user: centos
		public_key_id: "{{ public_key }}"
		bootstrap: ""
		tags:
			owner: hshah
			enddate: "06102020"
			project: ansible-hshah-test

 15. Open and modify filepath for license in stock.cluster.krb.yml. where it says **\<replace me>**

	See below:

		**Example:**
		  
		license:
		type: enterprise
		filepath: <replace me> eg path: /test_2019_2020_Licenseinfo/test_2019_2020_cloudera_license.txt

 16. Change the following information in config/stock.cluster.krb.yml

	 Add the private_key value eg: {{ my_key }}
	
	Example: from the vault file , replace "replace_key" it with your own key  
	  		private_key: "{{ replace_key }}"
  		

 17. Open /etc/ansible/ansible.cfg  make the following changes and save.

	a) uncomment record_host_key
	
		# host key checking setting above.
		record_host_keys=False
			
	b) uncomment value_password_file and specify the location of your vault password file.
	
		 # specifying --vault-password-File on the command line.
		   vault_password_file = /home/hshah/vault-password-file
	

 18. Open /etc/ansible/hosts, add following 2 lines as below and save:

		[local]
		localhost
	

Now are ready to execute the ansible playbook from mn-script folder.

	$ansible-playbook site.yml -e "infra=config/stock.infra.aws.yml" -e "cluster=config/stock.cluster.krb.yml"  -e "vault= <path-to-keys.vault-file>" -e "cdpdc_teardown=<userid-date>" -e "public_key=<name_of_public_key_AWS>" -e "repo_username=<username for archive.cloudera.com>" -e "repo_password=<password for archive.cloudera.com>" 

Example:

	ansible-playbook site.yml -e "infra=config/stock.infra.aws.yml" -e "cluster=config/stock.cluster.krb.yml" -e "vault=/home/hshah/keys.vault" -e "cdpdc_teardown=hshah-06102020" -e "public_key=my_key" -e "repo_username=abcd-1234-wxyz-6789" -e "repo_password=abcd1234"

After End of Successful Execution, You will see something like below as a Recap:

	TASK [cdpdc_cm_server : reset var _api_command] ***********************************************************************************************************************************************
	ok: [3.235.57.178]

	PLAY RECAP ************************************************************************************************************************************************************************************
	3.235.151.211              : ok=31   changed=17   unreachable=0    failed=0    skipped=0    rescued=0    ignored=1
	3.235.57.178               : ok=114  changed=43   unreachable=0    failed=0    skipped=6    rescued=0    ignored=1
	34.239.93.193              : ok=31   changed=17   unreachable=0    failed=0    skipped=0    rescued=0    ignored=1
	54.236.38.17               : ok=31   changed=17   unreachable=0    failed=0    skipped=0    rescued=0    ignored=1
	localhost                  : ok=17   changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   


Use cm node ( 4xlarge ) to get into CM to verify the cluster status above, Ex: 3.235.57.178 as cm server

	https://3.235.57.178:7183/cmf/login
	Pwd: admin/admin

Login into AWS, check AWS EC2 instance , you will be able to see following instances created has 3 Worker nodes(2xlarge+100gb) and 1 (4xlarge+100gb) master nodes

You can vew the hosts that were created (i.e. their public IPs, local IPs, and roles) by looking at the ansible_hosts.yml produced in the mn-script directory.
