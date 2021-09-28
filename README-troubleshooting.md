```
For reference: https://docs.ansible.com/ansible/latest/user_guide/playbooks_debugger.html#enabling-the-debugger-with-the-debugger-keyword

export ANSIBLE_ENABLE_TASK_DEBUGGER=False
export ANSIBLE_DEBUG=true 
export ANSIBLE_VERBOSITY=4

Inside of site.yml, for a specific module:
- name: INSTALL MIT KDC CLIENT
  hosts: cdpdc
  become: yes
  debugger: on_failed


'kdavis' is undefined\n\nThe error appears to be in '/home/kdavis/Documents/Ansible/CDP7_MultinodeDeployment/mn-script/site.yml': line 42, column 7, but may\nbe elsewhere in the file depending on the exact syntax problem.\n\nThe offending line appears to be:\n\n\n    - name: install MIT KDC client\n      ^ here\n"}

[54.242.238.240] TASK: install MIT KDC client (debug)> p task
TASK: install MIT KDC client
[54.242.238.240] TASK: install MIT KDC client (debug)> p task.args
{'name': 'install_krb5/client'}
[54.242.238.240] TASK: install MIT KDC client (debug)> p task_vars
{'ansible_all_ipv4_addresses': ['10.0.18.195'],
 'ansible_all_ipv6_addresses': ['fe80::8ee:7fff:feb9:d875'],
 'ansible_apparmor': {'status': 'disabled'},
 .....
 
 
 
```

```
You may encounter a failure of the Python 2.7 pip package to recognize an encoding paramater for UTF-8 in I/O methods:

ansible-playbook site.yml -e "infra=config/stock.infra.aws.yml" \
  -e "cluster=config/stock.cluster.krb.yml" \
  -e "vault=/home/kdavis/keys.vault" \
  -e "cdpdc_teardown=kdavis-10042021" \
  -e "public_key=kdavis-key-for-ansible" \
  -e "repo_username=70225f50-3c5b-43e7-b8f3-01cff397defa" \
  -e "repo_password=e8501e20dc14"


TASK [install_mariadb : install PyMySQL] *********************************************************************************************************************
fatal: [54.242.238.240]: FAILED! => {"changed": false, "cmd": ["/bin/pip2", "install", "PyMySQL"], "msg": "stdout: Collecting PyMySQL\n  Using cached
https://files.pythonhosted.org/packages/60/ea/33b8430115d9b617b713959b21dfd5db1df77425e38efea08d121e83b712/PyMySQL-1.0.2.tar.gz\n    Complete output from
command python setup.py egg_info:\n    Traceback (most recent call last):\n      File \"<string>\", line 1, in <module>\n      
File \"/tmp/pip-build-ig2F1b/PyMySQL/setup.py\", line 6, in <module>\n        with open(\"./README.rst\", encoding=\"utf-8\") as f:\n    
TypeError: 'encoding' is an invalid keyword argument for this function\n    \n    ----------------------------------------\n\n:stderr: 
Command \"python setup.py egg_info\" failed with error code 1 in /tmp/pip-build-ig2F1b/PyMySQL/\nYou are using pip version 8.1.2, however version 21.2.4 
is available.\nYou should consider upgrading via the 'pip install --upgrade pip' command.\n"}

SSH to the MariaDB target EC2 instance created by Ansible during setup. Provide the proper location to the correct PEM file (e.g per my environment below):

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

```
TASK [install_krb5/client : install krb5] 
**********************************************************************************************************************
The authenticity of host '34.224.212.186 (34.224.212.186)' can't be established.
ED25519 key fingerprint is SHA256:HJURd0uGTQKgGGAat/vHWlFPFsFIcqgvC/bI4VNTF2I.
This key is not known by any other names
The authenticity of host '54.197.60.47 (54.197.60.47)' can't be established.
ED25519 key fingerprint is SHA256:1p53QBG3f4WupN1fFdiKuQfUyKBiZsYiER5wSJtxa2s.
Are you sure you want to continue connecting (yes/no/[fingerprint])? 

TASK [cdpdc_cm_server : check until _api_command exits] **********************************************************************************************************************
PLAY RECAP 
34.224.212.186             : ok=30   changed=16   unreachable=0    failed=0    skipped=0    rescued=0    ignored=1   
54.162.205.115             : ok=3    changed=0    unreachable=1    failed=0    skipped=0    rescued=0    ignored=0   
54.197.60.47               : ok=30   changed=17   unreachable=0    failed=0    skipped=0    rescued=0    ignored=1   
54.204.116.225             : ok=88   changed=12   unreachable=0    failed=1    skipped=9    rescued=0    ignored=3   
54.227.12.51               : ok=30   changed=16   unreachable=0    failed=0    skipped=0    rescued=0    ignored=1   
localhost                  : ok=24   changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  

```

```
TASK [cdpdc_cm_server : check until _api_command exits] ****************************************************************************************************************************************************
FAILED - RETRYING: check until _api_command exits (60 retries left).
fatal: [54.204.116.225]: FAILED! => {"attempts": 2, "cache_control": "no-cache, no-store, max-age=0, must-revalidate", "changed": false, "connection": "close", "content_type": "application/json;charset=utf-8", "cookies": {"SESSION": "8d96c202-b230-409a-82e0-e45af17606d9"}, "cookies_string": "SESSION=8d96c202-b230-409a-82e0-e45af17606d9", "date": "Tue, 28 Sep 2021 12:54:32 GMT", "elapsed": 0, "expires": "Thu, 01 Jan 1970 00:00:00 GMT", "failed_when_result": true, "json": {"active": false, "canRetry": true, "children": {"items": []}, "endTime": "2021-09-28T12:54:25.601Z", "id": 31, "name": "GlobalHostInstall", "resultDataUrl": "https://ip-10-0-22-86.ec2.internal:7183/cmf/command/31/download", "resultMessage": "Failed to complete installation.", "startTime": "2021-09-28T12:54:20.579Z", "success": false}, "msg": "OK (unknown bytes)", "pragma": "no-cache", "redirected": false, "set_cookie": "SESSION=8d96c202-b230-409a-82e0-e45af17606d9;Path=/;Secure;HttpOnly", "status": 200, "strict_transport_security": "max-age=31536000 ; includeSubDomains", "url": "https://localhost:7183/api/v40/commands/31", "x_content_type_options": "nosniff", "x_frame_options": "DENY", "x_xss_protection": "1; mode=block"}

No provider available for Unknown key file

scp /home/kdavis/Documents/Demos/creds/kdavis-key-for-ansible.pem centos@54.163.28.224:/home/centos/.ssh/id_rsa

```
