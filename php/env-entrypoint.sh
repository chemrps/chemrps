#!/bin/bash


#mkdir mysdfilefolder
#chown -R www-data:www-data mysdfilefolder

source /code/.env


sed -i "s#SERVERNAME#$SERVERNAME#g" /code/registersdfile.html
sed -i "s#WEBPORT#$WEBPORT#g" /code/registersdfile.html

sed -i "s#SERVERNAME#$SERVERNAME#g" /code/chemrpssearch.js
sed -i "s#SERVERNAME#$SERVERNAME#g" /code/registersdfile.js
sed -i "s#SDFILEUPLOADFOLDER#/sdfilefolder/#g" /code/uploadsdfile.php
