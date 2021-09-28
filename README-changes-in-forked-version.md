## Changing the version of CDP in use
```
Ansible variables were used in a new version of ./config/stock.cluster.krb.yml

Now, you can specify the versions of CDP and CM desired at the command line by:

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

```

## Dockerfile added
```
It was time consuming to update Fedora and install pip and Python3 dependencies every time an image was created.
So, a custom image was built extending from the base Fedora image.

Environment variables are used in the AWS version of the image to ease referencing access keys and secrets.

To build the image (as one example):

git clone or download the repository.

% cd CDP7_MultinodeDeployment

% docker build -t cdp-ansible:latest .

% docker run --name cdp-ansible -d -it --volume $HOME:/home/kdavis cdp-ansible:latest /bin/bash

Note, you no longer need to pin the instance id that comes back from the docker run as was the case in the previous 
version. Instead, you can 'name' the container that runs.

Then, you can exec into the named container:

% docker exec -it cdp-ansible /bin/bash
```

