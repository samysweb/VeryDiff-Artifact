#! /bin/bash

docker build ./docker/ -t samweb/verydiff:artifact

docker tag samweb/verydiff:artifact samweb/verydiff:latest

docker push samweb/verydiff:artifact
docker push samweb/verydiff:latest

docker save samweb/verydiff:artifact | gzip > verydiff_artifact.tar.gz