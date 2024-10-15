#!/bin/bash

cd /home/ubuntu

sudo mv daemon.json /etc/docker

sudo sed -i "s/ExecStart=\/usr\/bin\/dockerd\ -H fd:\/\/\ --containerd=\/run\/containerd\/containerd.sock/ExecStart=\/usr\/bin\/dockerd\ --containerd=\/run\/containerd\/containerd.sock/g" /lib/systemd/system/docker.service

sudo systemctl daemon-reload
sudo systemctl restart docker
