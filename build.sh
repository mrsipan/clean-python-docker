#!/bin/bash -vex

version=$1

sed "s/PYTHON_VERSION/$version/" clean_python.spec.template > clean_python.spec

curl -O "https://www.python.org/ftp/python/${version}/Python-${version}.tgz"

spec_path="$(tar -t -f Python-${version}.tgz | grep -e '\.spec$' || true)"

gzip -d Python-${version}.tgz

if [ -n "$spec_path" ]; then
  printf "spec_path: %s\n" "$spec_path"
  tar --delete "$spec_path" -f Python-$version.tar
fi

tar -u -f Python-$version.tar clean_python.spec

gzip -c Python-$version.tar > Python-${version}.tgz

rpmbuild -ts --nodeps --define "_sourcedir `pwd`" --define "_srcrpmdir `pwd`" Python-${version}.tgz

yum-builddep -y clean_python*.src.rpm

rpmbuild --rebuild --define "_rpmdir `pwd`/rpms" clean_python*.rpm

