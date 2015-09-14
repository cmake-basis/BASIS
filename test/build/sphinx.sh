#!/bin/bash
set -e

## Travis script to install Sphinx

version=${1:-any}
 
if [[ $version != any ]]; then
  echo "Can only use Sphinx version provided by PyPI or Ubuntu (i.e., version argument must be 'any')" 1>&2
  exit 1
fi

# Install prerequisites
if [[ $TRAVIS_OS_NAME == linux ]]; then
  sudo apt-get install -y python-docutils python-jinja2 python-pygments 
elif [[ $TRAVIS_OS_NAME == osx ]]; then
  wget http://tug.org/cgi-bin/mactex-download/BasicTeX.pkg
  sudo installer -pkg BasicTeX.pkg -target /
fi

# Install Sphinx
which pip
if [ $? -eq 0 ]; then
  sudo pip install -U Sphinx
elif [[ $TRAVIS_OS_NAME == linux ]]; then
  sudo apt-get install -y python-sphinx
else
  echo "pip required for installation of Sphinx"
  exit 1
fi
