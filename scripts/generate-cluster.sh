#!/bin/bash

echo "Generating cluster config..."

kops create cluster \
  --name=${NAME} \
  --state=${KOPS_STATE_STORE} \
  --cloud=aws \
  --zones=eu-west-3a,eu-west-3b,eu-west-3c \
  --control-plane-zones=eu-west-3a,eu-west-3b,eu-west-3c \
  --node-count=3 \
  --node-size=t3.medium \
  --control-plane-size=t3.medium \
  --topology=private \
  --networking=calico \
  --dns-zone=oparatechstack.com \
  --kubernetes-version=1.28.11 \
  --dry-run \
  -o yaml > ../kops/cluster.yaml
