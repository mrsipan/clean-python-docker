FROM centos:7

RUN yum -y install gcc make rpm-build
RUN yum clean all
RUN mkdir -p /build/rpms

COPY build.sh /build
COPY clean_python.spec.template /build

WORKDIR /build

ENTRYPOINT ["/build/build.sh"]
CMD ["3.7.9"]


