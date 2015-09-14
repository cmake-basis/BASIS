#!/bin/bash
set -e

## Travis script to install Jython

version=${1:-any}
prefix=${2:-/opt/jython-$version}

# Install from binary package if possible
if [[ $version == any ]]; then
  [[ $TRAVIS_OS_NAME != linux ]] || exec sudo apt-get install -qq jython
  [[ $TRAVIS_OS_NAME != osx   ]] || exec brew install jython
fi

# Download installer
wget -O jython-installer-${version}.jar \
     http://search.maven.org/remotecontent?filepath=org/python/jython-installer/$version/jython-installer-${version}.jar

# Install Jython
java -jar jython-installer-${version}.jar -s -d "$prefix" -t minimum
