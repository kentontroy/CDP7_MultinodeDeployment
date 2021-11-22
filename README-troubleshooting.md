## Variable naming
```
Ansible use Jinja2 templating for variables and dynamic expressions.

Jinja2 doesn't behave very well with variables containing dashes. Avoid PEM files with dashes in the name.
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

## Failure to get the latest certificate for Yum repo for PostgreSQL
```
 "msg": "Failure downloading https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm, Request failed: <urlopen error [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed (_ssl.c:618)>"

If a certificate does not download or if a Yum repository needs to be manually installed on the Master node, consider:

% ssh centos@54.242.238.240
[centos@ip-10-0-18-195 ~]$ sudo su 
[root@ip-10-0-18-195 centos]# wget --no-check-certificate https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
[root@ip-10-0-18-195 centos]# rpm -ivh pgdg-redhat-repo-latest.noarch.rpm
[root@ip-10-0-18-195 centos]# vi /etc/yum.conf
Add the following line:
sslverify=false

Then, inside of the Docker container, ensure that you are in the CDP7_MultinodeDeployment/mn-script directory.
Add a tag called "skipped_manually_done" to force the Ansible script to bypass the installation of the Yum repo
because it was done manually:

% vi scripts/pgsql.yml
- name: install PGSQL server
  yum:
    name: https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
    state: latest
  tags:
    - skipped_manually_done
  
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
  -e "cdh_abbreviated_parcel=7.1.7-1.cdh7.1.7.p0.15945976" \
  --skip-tags "skipped_manually_done"
  
Essentially, when failures occur in downloading an RPM, you manually install the RPM and then find the scripts where
Ansible performs this action. Once found, use a tag to skip the Ansible task (or, ignore_errors: yes). 

As another example,for one deployment the Cloudera Manager packages failed to download on one of the cluster nodes due 
to a network issue.  The problem was identified by using DEBUG mode as described above and by downloading the errors that 
Cloudera Manager producers for each node during install. 
.....
        "resultDataUrl": "https://ip-10-0-0-200.ec2.internal:7183/cmf/command/15/download",
        "resultMessage": "Failed to complete installation.",
        "startTime": "2021-10-04T18:45:56.546Z",
        "success": false
    },
    "msg": "OK (unknown bytes)",
    "pragma": "no-cache",
    "redirected": false,
    "set_cookie": "SESSION=eb66c4c3-2d40-4f1e-af17-9be7410e13c3; Path=/; Secure; HttpOnly",
    "status": 200,
    "strict_transport_security": "max-age=31536000 ; includeSubDomains",
    "url": "https://localhost:7183/api/v40/commands/15",
    "x_content_type_options": "nosniff",
    "x_frame_options": "DENY",
    "x_xss_protection": "1; mode=block"
}
[54.242.238.240] TASK: cdpdc_cm_server : check until _api_command exits (debug)>
......

For this case, you could SSH into the specific cluster node:

$ sudo wget --user <USERNAME> --password <PASSWORD> https://archive.cloudera.com/p/cm7/7.4.4/redhat7/yum/cloudera-manager.repo -P /etc/yum.repos.d/

$ sudo vi /etc/yum.repos.d/cloudera-manager.repo

[cloudera-manager]
name=Cloudera Manager 7.4.4
# Replace changeme:changeme with your paywall username and password below.
baseurl=https://<USERNAME>:<PASSWORD>@archive.cloudera.com/p/cm7/7.4.4/redhat7/yum/
gpgkey=https://changeme:changeme@archive.cloudera.com/p/cm7/7.4.4/redhat7/yum/RPM-GPG-KEY-cloudera
gpgcheck=0
enabled=1
autorefresh=0
type=rpm-md


Then, in the Docker container, add a tag so that Ansible skips this task when re-run.

vi roles/cdpdc_cm_server/tasks/redhat.yml

- name: Download CM repo file
  get_url:
    url: "{{ cdpdc.cm.repo_file }}"
    dest: /etc/yum.repos.d/
  tags:
    - skipped_manually_done

- name: Install the Cloudera Manager Server packages
  yum:
    name:
      - cloudera-manager-agent
      - cloudera-manager-daemons
      - cloudera-manager-server
    state: latest  
```
## Ensure that private DNS is enabled for the VPC
```
enableDnsHostnames and enableDnsSupport should be checked when creating the VPC in use

This creates a private hosted zone with resolution occurring within the VPC.
e.g. if the VPC subnet is 10.0.0.0/19, then nslookup resolves to:
Server:         10.0.0.2
Address:        10.0.0.2#53
```

## After installation, warnings within the CM Console
```
To support Phoenix, HBase Write-Ahead Log Codec Class should be set to:
"org.apache.hadoop.hbase.regionserver.wal.IndexedWALEditCodec"

Kafka is only installed on one node by default. If this is acceptable, then
change the transaction and offset topics' replication factor to 1 since
there is only one broker. Then, suppress the warning about doing so.

For performance reasons, you may want to avoid enabling authentication and 
integrity checks for DataNode Transfers. Since the cluster uses Auto TLS
as part of the Ansible configuration, CM reports a warning about having
a Secure Node configuration without using DataNode Transfer protection.
You may consider simply disabling this warning.

The Ansible setup configures a KDC server running on the Cloudera
Manager / Master node by default. CM will always report this node as 
having a stale Kerberos configuration since it's services can't be turned
off in order for the krb5.conf redployment to occur. In reality, the Kerberos 
config does not have to redeployed because it obviusly originates from the Master
node where the KDC server is itself installed. CM is naive to this, so the warning
can be disregarded.

```
