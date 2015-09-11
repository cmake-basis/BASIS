#! /bin/bash

# Small utility script used to update the links to external web pages.
#
# usage: update_doc_urls www.rad.upenn.edu www.cbica.upenn.edu

old_url_prefix=$1
new_url_prefix=$2
if [ -z "${old_url_prefix}" -o -z "${new_url_prefix}" ]; then
    echo "usage: $0 <old_url_prefix> <new_url_prefix>" 1>&2
    exit 1
fi

if [[ `uname` == Darwin ]]; then
    find doc -type f -name '*.rst' -exec sed -i '' "s:$old_url_prefix:$new_url_prefix:g" {} \;
else
    find doc -type f -name '*.rst' -exec sed -i'' "s:$old_url_prefix:$new_url_prefix:g" {} \;
fi
