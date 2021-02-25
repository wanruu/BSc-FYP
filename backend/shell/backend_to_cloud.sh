# copy files to ./tmp
mkdir ./tmp
cp ../back.js ./tmp
mkdir ./tmp/src
cp ../src/* ./tmp/src

# zip
zip -r tmp.zip tmp

sshpass -p "Sspark0328" scp tmp.zip root@42.194.159.158:~/
sshpass -p "Sspark0328" ssh root@42.194.159.158 'bash -s' < replace_backend.sh


# clean
rm tmp.zip
rm -rf tmp