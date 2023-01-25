# Auto-Hive-Img-Build

Prerequisites:
* Golang
* jq (command line utility)

Usage: 
1. Copy auto_hive_img_build.sh to server
2. Install a Cron job by adding the following line to the Crontab:

   0 18 * * * source PATH_TO_BASHRC; quay_username=USERNAME quay_password=PASSWORD quay_repo=REPO bash path_to_auto_hive_img_build.sh
