#!/bin/bash

source scripts/set-env.sh

kops delete cluster --name ${NAME} --yes
