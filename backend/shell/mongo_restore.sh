unzip backup.zip

mongorestore -d CUMap ./backup/CUMap --drop

rm -rf backup

rm backup.zip