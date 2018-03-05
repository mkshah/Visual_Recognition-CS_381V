#!/usr/bin/env sh
# Compute the mean image from the imagenet training lmdb
# N.B. this is available in data/ilsvrc12

EXAMPLE=/work/04441/mkshah/files
DATA=/work/04441/mkshah/files
TOOLS=/work/04441/mkshah/caffe/build/tools

$TOOLS/compute_image_mean $EXAMPLE/scene_train_lmdb \
  $DATA/scene_mean.binaryproto

echo "Done."
