#!/bin/bash

source /code/.env


sed -i "s#GETCHEMRPSAPIPREFIXURL#$GETCHEMRPSAPIPREFIXURL#g" /code/chemrpssearch.js
sed -i "s#GETCHEMRPSAPIPREFIXURL#$GETCHEMRPSAPIPREFIXURL#g" /code/registersdfile.js
sed -i "s#SDFILEUPLOADFOLDER#$SDFILEUPLOADFOLDER#g" /code/uploadsdfile.php

sed -i "s#SERVERNAME#$SERVERNAME#g" /etc/nginx/conf.d/default.conf
