#!/bin/bash

version="$1"
if [ -z "$version" ] ; then
  echo "Usage: $0 <version>"
  exit 1
fi

set -e

tbversion=${version//./_}
topdir=$(cd $(dirname $0)/.. ; pwd)
tmpdir=
trap cleanup EXIT

cleanup()
{
    set +e
    [ -z "$tmpdir" -o ! -d "$tmpdir" ] || rm -rf "$tmpdir"
}

tmpdir=$(mktemp -d /tmp/validator.XXXXXX)
mkdir -p $tmpdir/validator-$version
cp -pR $topdir/{htdocs,httpd,misc,README.cvs} $tmpdir/validator-$version

cd $tmpdir

find validator-$version -type d -name CVS | xargs -r rm -rf
find validator-$version -name .cvsignore | xargs -r rm -rf

find . -type d | xargs -r chmod 755
find . -type f | xargs -r chmod 644
chmod 755 validator-$version/httpd/cgi-bin/check

# sgml-lib tarball
tar zc --owner=0 --group=0 -f $topdir/sgml-lib-$tbversion.tar.gz \
  validator-$version/htdocs/sgml-lib

# Validator tarball
rm -rf validator-$version/htdocs/sgml-lib
tar zc --owner=0 --group=0 -f $topdir/validator-$tbversion.tar.gz \
  validator-$version