#!/bin/bash
set -ev

if [[ $TRAVIS_OS_NAME == linux ]]; then
  sudo apt-get update -qq
else
  #brew update
fi
