mongodump -d CUMap -o backup

zip -r backup.zip backup

sshpass -p "Sspark0328" scp ./backup.zip root@42.194.159.158:~/

sshpass -p "Sspark0328" ssh root@42.194.159.158 'bash -s' < mongo_restore.sh

# clean
rm -rf backup
rm backup.zip