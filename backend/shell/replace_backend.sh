unzip tmp.zip

sudo mv tmp/back.js backend/
sudo mv tmp/src/* backend/src

rm -rf tmp
rm tmp.zip