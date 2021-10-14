#!/bin/bash -vex

set -o verbose
set -o errexit
set -o xtrace

version=$1
ver=$(printf "%.4s" $version | sed -e 's/\.//g')

dnf="dnf"
if [ $(cat /etc/centos-release |  awk '{gsub("[^[:digit:]]+", " "); print $1}') = '7' ]; then
  dnf="yum"
fi
${dnf} -y install gcc make rpm-build ${dnf}-utils
${dnf} clean all
test ! -d /build/rpms && mkdir -p /build/rpms

sed "s/PYTHON_VERSION/$version/" clean_python.spec.template | \
  sed "s/PYVER/$ver/" > "clean_python${ver}.spec"

cp "clean_python${ver}.spec" "`pwd`/rpms"

curl -k -O "https://www.python.org/ftp/python/${version}/Python-${version}.tgz"

spec_path="$(tar -t -f Python-${version}.tgz | grep -e '\.spec$' || true)"

gzip -f -d Python-${version}.tgz

if [ -n "$spec_path" ]; then
  printf "spec_path: %s\n" "$spec_path"
  tar --delete "$spec_path" -f Python-$version.tar
fi

tar -u -f Python-$version.tar "clean_python${ver}.spec"

gzip -c Python-$version.tar > Python-${version}.tgz

rpmbuild -ts --nodeps --define "_sourcedir `pwd`" \
                      --define "_srcrpmdir `pwd`/rpms" \
                      Python-${version}.tgz

for src_rpm_file in `ls -1 rpms/clean_python*.src.rpm`; do
  if [ $dnf = 'yum' ]; then
    ${dnf}-builddep -y $src_rpm_file
  else
    ${dnf} builddep -y $src_rpm_file
  fi
done

for src_rpm_file in `ls -1 rpms/clean_python*.src.rpm`; do
  rpmbuild --rebuild --define "_rpmdir `pwd`/rpms" $src_rpm_file
done


