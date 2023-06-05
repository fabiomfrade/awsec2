#!/bin/bash
yum update -y 
yum upgrade -y
yum install docker -y
systemctl enable --now docker