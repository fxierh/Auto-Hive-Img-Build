#! /bin/bash

# Later commands in a pipeline does not wait for earlier commands to finish.
# This causes pipelines like
# git ls-remote -q | sed -n '1p;1q'
# to return a non-zero exit status, even though the output may still be correct.
# As a result, specifying set -o pipefail leads to a stoppage of script execution.
set -eux

cd /home/cloud-user/hive
# Hash of the latest master commit in the remote and local repo respectively
remote_hash=$(git ls-remote -q | grep master | awk '{print $1}' | cut -c 1-7)
local_hash=$(git log -n 1 master | head -n 1 | awk '{print $2}' | cut -c 1-7)

# shellcheck disable=SC2086
if [ "${remote_hash}" != ${local_hash} ]; then
    echo "Latest master commit of remote ($remote_hash) != latest master commit of local ($local_hash), pulling:"
    git pull

    echo "Building new Hive image:"
    # shellcheck disable=SC2154
    podman login quay.io --username ${quay_username} --password ${quay_password}
    IMG=quay.io/fxierh/hive:${remote_hash} make buildah-dev-push
else
    echo "Latest master commit of remote ($remote_hash) == latest master commit of local ($local_hash), doing nothing. "
fi
