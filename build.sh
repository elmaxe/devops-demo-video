#! /bin/bash
##remove previous dist if exists
rm -rf dist
##compile Typscript
mkdir dist
cp appspec.yml dist
cp package.json dist
cp package-lock.json dist
cp devops-demo.service dist
cp server.js dist
cp -r src dist
cp -r public dist
cp -r shScripts dist

npm install
npm run build
cp -r build dist

cd ./dist
## Zip evertyhing within the dist folder, excluding any hidden macOs files (-X)
zip -r -X devops-demo-dist.zip *
##upload to s3. AWS CLI must be installed
aws s3 cp devops-demo-dist.zip s3://devops-demo-video/