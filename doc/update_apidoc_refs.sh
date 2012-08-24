#! /bin/bash

# Small utility script used to update the links to the API documentation.
# The documentation.rst file *must* be excluded, however, and updated manually.
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

if [[ `printf ${BASH_VERSION} | grep 'apple'` ]]; then
    find . -type f \( -name '*.rst' ! -name documentation.rst \) -exec sed -i'' "s:/apidoc/v[0-9][0-9]*\.[0-9][0-9]*/:/apidoc/$release/:g;s:/apidoc/latest/:/apidoc/$release/:g" {} \;
else
    find . -type f \( -name '*.rst' ! -name documentation.rst \) -exec sed -i '' "s:/apidoc/v[0-9][0-9]*\.[0-9][0-9]*/:/apidoc/$release/:g;s:/apidoc/latest/:/apidoc/$release/:g" {} \;
fi
