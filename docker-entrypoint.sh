#! /bin/sh

echo "Begining the Hyperledger Fabric Docs Build Process."

ROOT_PATH=$PWD
cd docs/locale/$TRANSLATION

echo "Checking for previous build for *** $TRANSLATION ***"
if [ ! -d "$ROOT_PATH/docs/locale/$TRANSLATION/build" ] 
then
  echo "Previous build NOT found"
  pipenv install
else
  echo "Previous build found"
fi

echo "Run Make html"
pipenv run make html