#!/bin/bash

source scripts/set-env.sh

kops create -f kops/cluster.yaml
kops update cluster --name ${NAME} --yes
