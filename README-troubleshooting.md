## Variable naming
```
Ansible use Jinja2 templating for variables and dynamic expressions.

Jinja2 doesn't behave very well with variables containing dashes. For example, over an hour was lost
trying to understand the reason behind an undefined variable. See how to debug below. The ultimate reason 
was due to a PEM file being used that had dashes in the name.
```

## Debugging
```
Debugging distributed processes is not an easy task. Consider the following environment variables to make 
it easier in Ansible. Also see for reference: 
https://docs.ansible.com/ansible/latest/user_guide/playbooks_debugger.html#enabling-the-debugger-with-the-debugger-keyword

export ANSIBLE_ENABLE_TASK_DEBUGGER=True
export ANSIBLE_DEBUG=true 
export ANSIBLE_VERBOSITY=4

In side of an Ansible task, you can also enable the debugger for more granularity:

Inside of site.yml, for a specific module:
- name: INSTALL MIT KDC CLIENT
  hosts: cdpdc
  become: yes
  debugger: on_failed 
```

##  pip Encoding parameter not recognized
```
You may encounter a failure of the Python 2.7 pip package to recognize an encoding paramater for UTF-8 in 
I/O methods:

% ansible-playbook site.yml -e "infra=config/stock.infra.aws.yml" \
  -e "cluster=config/stock.cluster.krb.yml" \
  -e "vault=/home/kdavis/keys.vault" \
  -e "cdpdc_teardown=kdavis-10052021" \
  -e "public_key=kdavis" \
  -e "repo_username=<CHANGE ME>" \
  -e "repo_password=<CHANGE ME>" \
  -e "cm_major_version=7" \
  -e "cm_full_version=7.4.4" \
  -e "cdh_major_version=7" \
  -e "cdh_full_version=7.1.7" \
  -e "cdh_abbreviated_parcel=7.1.7-1.cdh7.1.7.p0.15945976"

TASK [install_mariadb : install PyMySQL] 
*********************************************************************************************************************
fatal: [54.242.238.240]: FAILED! => {"changed": false, "cmd": ["/bin/pip2", "install", "PyMySQL"], "msg": "stdout: Collecting PyMySQL\n  Using cached
https://files.pythonhosted.org/packages/60/ea/33b8430115d9b617b713959b21dfd5db1df77425e38efea08d121e83b712/PyMySQL-1.0.2.tar.gz\n    Complete output from
command python setup.py egg_info:\n    Traceback (most recent call last):\n      File \"<string>\", line 1, in <module>\n      
File \"/tmp/pip-build-ig2F1b/PyMySQL/setup.py\", line 6, in <module>\n        with open(\"./README.rst\", encoding=\"utf-8\") as f:\n    
TypeError: 'encoding' is an invalid keyword argument for this function\n    \n    ----------------------------------------\n\n:stderr: 
Command \"python setup.py egg_info\" failed with error code 1 in /tmp/pip-build-ig2F1b/PyMySQL/\nYou are using pip version 8.1.2, however version 21.2.4 
is available.\nYou should consider upgrading via the 'pip install --upgrade pip' command.\n"}

To resolve: SSH to the MariaDB target EC2 instance created by Ansible during setup

% ssh centos@54.242.238.240
[centos@ip-10-0-18-195 ~]$ sudo su 
[root@ip-10-0-18-195 centos]# yum install -y wget
[root@ip-10-0-18-195 centos]# wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
[root@ip-10-0-18-195 centos]# python get-pip.py
Collecting pip<21.0
  Downloading pip-20.3.4-py2.py3-none-any.whl (1.5 MB)
     |################################| 1.5 MB 43.9 MB/s 
Collecting wheel
  Downloading wheel-0.37.0-py2.py3-none-any.whl (35 kB)
Installing collected packages: pip, wheel
  Attempting uninstall: pip
    Found existing installation: pip 8.1.2
    Uninstalling pip-8.1.2:
      Successfully uninstalled pip-8.1.2
Successfully installed pip-20.3.4 wheel-0.37.0

```

## Turn off SSH Host Key checking
```
Inside of: /etc/ansible/ansible.cfg

host_key_checking = False

When the Kerberos client installation task is running, the messages can rapidly stream to the screen preventing you from 
being able to accept the SSH fingerprint to register a known host. It's easier just to turn off Host checking since the 
installation is a well confined process w/o any security concerns of doing so.

TASK [install_krb5/client : install krb5] 
**********************************************************************************************************************
The authenticity of host '34.224.212.186 (34.224.212.186)' can't be established.
ED25519 key fingerprint is SHA256:HJURd0uGTQKgGGAat/vHWlFPFsFIcqgvC/bI4VNTF2I.
This key is not known by any other names
The authenticity of host '54.197.60.47 (54.197.60.47)' can't be established.
ED25519 key fingerprint is SHA256:1p53QBG3f4WupN1fFdiKuQfUyKBiZsYiER5wSJtxa2s.
Are you sure you want to continue connecting (yes/no/[fingerprint])? 
```

```
sudo wget https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
rpm -ivh pgdg-redhat-repo-latest.noarch.rpm
ls -al /etc/yum.repos.d

Change /etc/yum.conf to include:
sslverify=false

pgsql script
ignore_errors: yes


$ wget https://3338b69d-d915-4f9b-af74-15593343f6d3:fb8980e42c4e@archive.cloudera.com/p/cm7/7.4.4/redhat7/yum/RPMS/x86_64/cloudera-manager-daemons-7.4.4-15850731.el7.x86_64.rpm

sudo rpm -ivh cloudera-manager-daemons-7.4.4-15850731.el7.x86_64.rpm 

vi roles/cdpdc_cm_server/tasks/redhat.yml
---
- name: Download CM repo file
  get_url:
    url: "{{ cdpdc.cm.repo_file }}"     dest: /etc/yum.repos.d/   tags:     - skip - name: Install the Cloudera Manager Server packages   yum:     name:        - cloudera-manager-agent        - cloudera-manager-daemons        - cloudera-manager-server     state: latest --skip=




