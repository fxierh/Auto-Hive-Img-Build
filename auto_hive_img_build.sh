#! /bin/bash

# Later commands in a pipeline does not wait for earlier commands to finish.
# This causes pipelines like
# git ls-remote -q | sed -n '1p;1q'
# to return a non-zero exit status, even though the output may still be correct.
# As a result, specifying set -o pipefail leads to a stoppage of script execution.
set -eux

cd /home/cloud-user/hive

# Hash of the latest master commit of the remote repo
git pull
local_hash=$(git log -n 1 master | head -n 1 | awk '{print $2}' | cut -c 1-7)
# remote_hash=$(git ls-remote -q | grep master | awk '{print $1}' | cut -c 1-7)

# Hash of the latest image tag on quay.io (using quay's api)
# shellcheck disable=SC2154
quay_latest=$(curl -s -X GET https://quay.io/api/v1/repository/"$quay_username"/"$quay_repo"/tag/ | jq -rs '.[].tags | map(select(.expiration | not)) | sort_by(.start_ts) | reverse | .[0].name')

# shellcheck disable=SC2086
if [ "${local_hash}" != ${quay_latest} ]; then
    echo "Latest master commit ($local_hash) != latest image tag on quay.io ($quay_latest), building & pushing new Hive image:"

    # shellcheck disable=SC2154
    podman login quay.io --username "${quay_username}" --password "${quay_password}"
    IMG=quay.io/fxierh/hive:"${local_hash}" make buildah-dev-push
else
    echo "Latest master commit ($local_hash) == latest image tag on quay.io ($quay_latest), doing nothing. "
fi
