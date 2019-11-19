#!/bin/bash
# https://tynick.com/blog/11-18-2019/blue-iris-automated-snapshots-with-aws-s3-and-slack-integration/
# this is a wrapper script to run the snap.sh script
# enter all of the blue iris camera shortnames as in the examples below

# get the absolute path of this script
my_dir="$( cd "$(dirname "$0")" ; pwd -P )"

# run for each camera you want a snapshot of
"${my_dir}"/cam_snap.sh backyard-03
"${my_dir}"/cam_snap.sh backpatio-01
