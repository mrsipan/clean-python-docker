# Build a python rpm in docker

To build a python rpm for _centos 7_:

```bash
docker run -w /build -v $PWD:/build --rm -it centos:7 /build/build.sh 3.10.0
```

To build a python rpm for _centos 8_:

```bash
docker run -w /build -v $PWD:/build --rm -it centos:8 /build/build.sh 3.10.0
```
