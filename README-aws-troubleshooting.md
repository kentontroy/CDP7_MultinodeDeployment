```
You may encounter this error when running:


ansible-playbook site.yml -e "infra=config/stock.infra.aws.yml" \
  -e "cluster=config/stock.cluster.krb.yml" \
  -e "vault=/home/kdavis/keys.vault" \
  -e "cdpdc_teardown=kdavis-10042021" \
  -e "public_key=kdavis-key-for-ansible" \
  -e "repo_username=70225f50-3c5b-43e7-b8f3-01cff397defa" \
  -e "repo_password=e8501e20dc14"


TASK [install_mariadb : install PyMySQL] *********************************************************************************************************************
fatal: [184.72.149.161]: FAILED! => {"changed": false, "cmd": ["/bin/pip2", "install", "PyMySQL"], "msg": "stdout: Collecting PyMySQL\n  Using cached
https://files.pythonhosted.org/packages/60/ea/33b8430115d9b617b713959b21dfd5db1df77425e38efea08d121e83b712/PyMySQL-1.0.2.tar.gz\n    Complete output from
command python setup.py egg_info:\n    Traceback (most recent call last):\n      File \"<string>\", line 1, in <module>\n      
File \"/tmp/pip-build-ig2F1b/PyMySQL/setup.py\", line 6, in <module>\n        with open(\"./README.rst\", encoding=\"utf-8\") as f:\n    
TypeError: 'encoding' is an invalid keyword argument for this function\n    \n    ----------------------------------------\n\n:stderr: 
Command \"python setup.py egg_info\" failed with error code 1 in /tmp/pip-build-ig2F1b/PyMySQL/\nYou are using pip version 8.1.2, however version 21.2.4 
is available.\nYou should consider upgrading via the 'pip install --upgrade pip' command.\n"}

SSH to the MariaDB target EC2 instance created by Ansible during setup. Provide the proper location to the correct PEM file (e.g per my environment below):

% ssh -i $HOME/Documents/Demos/creds/kdavis-key-for-ansible.pem centos@184.72.149.161

Within the EC2

$ sudo yum install -y python3-pip
$ sudo rm -rf /usr/bin/python
$ sudo ln -s /usr/bin/python3 /usr/bin/python
$ python --version
Python 3.6.8


```
