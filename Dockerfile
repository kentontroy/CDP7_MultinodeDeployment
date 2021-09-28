FROM fedora

LABEL Remarks="This is a Dockerfile for multinode deployment of CDP"

RUN dnf update -y && dnf install -y ansible python3-pip git

RUN pip3 install boto boto3

ENV AWS_ACCESS_KEY_ID=<enter AWS access key id>

ENV AWS_SECRET_ACCESS_KEY=<enter AWS access key>
