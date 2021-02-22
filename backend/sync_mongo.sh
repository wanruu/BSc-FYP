# ssh to cloud server
sshpass -p "Sspark0328" ssh root@42.194.159.158 'bash -s' < backup.sh

sshpass -p "Sspark0328" scp root@42.194.159.158:~/backup.zip ./

unzip backup.zip

mongorestore -d CUMap ./backup/CUMap --drop

rm -rf backup

rm backup.zip