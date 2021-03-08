sshpass -p "Sspark0328" ssh root@42.194.159.158 'bash -s' < mongo_dump.sh

sshpass -p "Sspark0328" scp root@42.194.159.158:~/backup.zip ./

sshpass -p "Sspark0328" ssh root@42.194.159.158 'rm -r -f backup.zip backup'

./mongo_restore.sh