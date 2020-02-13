# Build a python rpm in docker

```
docker build -t builder -f centos7.Dockerfile .
docker run -v `pwd`:/build/rpms -it builder 3.7.5
```
