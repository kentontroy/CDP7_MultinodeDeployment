## Example config for testing the deployment in AWS
```
Note, tenant VPCs are not public so ensure that cluster nodes have a publicly accessible route 
via an IGW (i.e. if relevant to your setup)

Ensure that you use the id's not the alias names in the Ansible script.

In this example, the kdavis-vpc has a subnet which contains a route table having the following
entries for destination and target:

10.0.0.0/16	local
0.0.0.0/0	igw-0ea7a2aff7a0f30c1

AWS IAM Console
---------------
Create a user
Grant permissions to the user (i.e. PowerUserAccess role)
Create an access key for the user

AWS Region
----------
us-east-1

AWS VPC
-------
Sandbox tenant
vpc-0d5b3e9226632d04d / kdavis-vpc
10.0.0.0/16

Refer to: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_DHCP_Options.html#AmazonDNS
Enable the options for DNS Host naming and DNS Resolution for the VPC

AWS Subnet
----------
kdavis-subnet-1 10.0.0.0/19, subnet-0575887bb905ccf04
kdavis-subnet-2 10.0.160.0/19
kdavis-subnet-3 10.0.64.0/19


AWS Security Group
--------------
sg-0c9ed91abcad3ef35 - kdavis-sg

AWS IGW
-------
igw-0ea7a2aff7a0f30c1 / kdavis-igw
```

```
Region-specific AMI ids:
------------------------

The AMI id for the CentOS image used is region specific
Check: https://www.centos.org/download/aws-images/
Note: The AMI id is specified as a variable when invoking the Ansible playbook
```

```
Generate a Windows *.ppk from the *.pem file used by the EC2 instances
--------------------------------------------------------------------

sudo yum install putty
sudo puttygen <PEM file> -o <PPK file> -O private
```
