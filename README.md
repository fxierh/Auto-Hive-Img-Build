# Auto-Hive-Img-Build

Usage: 
1. Copy auto_hive_img_build.sh to server
2. Add a (root) Cron job like the following:

   0 18 * * * quay_username=USERNAME quay_password=PASSWORD bash path_to_auto_hive_img_build.sh
