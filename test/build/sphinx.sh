#!/bin/bash
set -e

## Travis script to install Sphinx

version=${1:-any}
prefix=${2:-unused}
latex=${3:-yes}
 
if [[ $version != any ]]; then
  echo "Can only use latest Sphinx version provided by PyPI (i.e., version argument must be 'any')" 1>&2
  exit 1
fi

# Install TeX distribution if needed for user manual build (PDF output)
if [[ $latex == yes ]]; then
  if [[ $TRAVIS_OS_NAME == linux ]]; then
    sudo apt-get install -y texlive-latex-base texlive-latex-recommended ttf-linux-libertine
  elif [[ $TRAVIS_OS_NAME == osx ]]; then
    brew tap caskroom/cask
    brew cask install mactex
  fi
fi

# Install Sphinx
sudo pip install -U Sphinx
