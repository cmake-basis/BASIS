#!/bin/bash
set -e

## Travis script to install Jython

version=${1:-2.7.0}
prefix=${2:-/opt/jython-$version}

# Install from binary package if possible
if [[ $version == any ]]; then
  if [[ $TRAVIS_OS_NAME == linux ]]; then
    sudo apt-get install -qq jython
    exit 0
  elif [[ $TRAVIS_OS_NAME == osx ]]; then
    brew install jython
    exit 0
  fi
  version=2.7.0
fi

# Download and run installer
wget -O jython-installer-${version}.jar http://search.maven.org/remotecontent?filepath=org/python/jython-installer/$version/jython-installer-${version}.jar
java -jar jython-installer-${version}.jar -s -d "$prefix" -t minimum
rm -f jython-installer-${version}.jar
