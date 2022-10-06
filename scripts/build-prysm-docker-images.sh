#!/bin/sh

# create a dockerfile to build images
cat <<EOF > Dockerfile
FROM ubuntu:latest
#ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -yy git python2 python3 build-essential
WORKDIR /root
RUN git clone https://github.com/prysmaticlabs/prysm
COPY ./rootfs/bin/* /bin/
WORKDIR /root/prysm
ENTRYPOINT ["/bin/entrypoint"]
EOF

# build image
docker build -t prysm-docker-img-builder:latest .

# run container with mount point
mkdir -p docker-images/
docker run -it --rm --name prysm-img-builder -v $(pwd)/docker-images:/docker-images prysm-docker-img-builder:latest

# print tar archives path
ls -lah --color=auto docker-images

cat <<EOF > Dockerfile.prysmctl
FROM ubuntu:latest
ADD ./docker-images/prysmctl.tar /
ENTRYPOINT ["/app/cmd/prysmctl/prysmctl"]
EOF

cat <<EOF > Dockerfile.beacon-chain
FROM ubuntu:latest
ADD ./docker-images/beacon-chain.tar /
ENTRYPOINT ["/app/cmd/beacon-chain/beacon-chain"]
EOF

cat <<EOF > Dockerfile.validator
FROM ubuntu:latest
ADD ./docker-images/validator.tar /
ENTRYPOINT ["/app/cmd/validator/validator"]
EOF

# build 
docker build -t prysmctl:latest -f Dockerfile.prysmctl .
docker build -t beacon-chain:latest -f Dockerfile.beacon-chain .
docker build -t validator:latest -f Dockerfile.validator .
