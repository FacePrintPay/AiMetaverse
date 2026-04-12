find ~/repos -name "package.json" -execdir npm install \;
find ~/repos -name "requirements.txt" -execdir pip install -r {} \;
