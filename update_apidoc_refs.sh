#! /bin/bash

# Small utility script used to update the links to the API documentation.
# The manual.rst file *must* be excluded, however, and updated manually.
#
# usage: update_apidoc_refs 2.0
#
# where the argument given, i.e., 2.0 in this example, is the current project version.

release=$1
if [ -z "${release}" ]; then
    echo "No release version specified, e.g., 2.0!" 1>&2
    exit 1
fi
[[ ${release} == 'latest' ]] || release=v${release}

if [[ `uname` == Darwin ]]; then
    find doc -type f \( -name '*.rst' ! -name manual.rst \) -exec sed -i '' "s:/apidoc/v[0-9][0-9]*\.[0-9][0-9]*/:/apidoc/$release/:g;s:/apidoc/latest/:/apidoc/$release/:g" {} \;
    for f in README.*; do
        sed -i '' "s:/apidoc/v[0-9][0-9]*\.[0-9][0-9]*/:/apidoc/$release/:g;s:/apidoc/latest/:/apidoc/$release/:g" "${f}"
    done
else
    find doc -type f \( -name '*.rst' ! -name manual.rst \) -exec sed -i'' "s:/apidoc/v[0-9][0-9]*\.[0-9][0-9]*/:/apidoc/$release/:g;s:/apidoc/latest/:/apidoc/$release/:g" {} \;
    for f in README.*; do
        sed -i'' "s:/apidoc/v[0-9][0-9]*\.[0-9][0-9]*/:/apidoc/$release/:g;s:/apidoc/latest/:/apidoc/$release/:g" "${f}"
    done
fi
