#!/bin/bash

set -e

echo "Initialization of base container using UID : $CHEMRPS_UID : $CHEMRPS_GID"

if id "chemrps" >/dev/null 2>&1; then
    echo "User exists, skipping creation."
else
    echo "Creating app user ..." && \
    #groupadd  chemrps && \
    #useradd --shell /bin/bash chemrps && \
    #export HOME=/app && \
    useradd chemrps
    echo "Done."
fi


source /app/.env


chown -R chemrps:chemrps /app

sed -i "s#SERVERNAME#$SERVERNAME#g" /app/chemrpslibrary.dll.config
sed -i "s#DATABASENAME#$DATABASENAME#g" /app/chemrpslibrary.dll.config
sed -i "s#BCF_AUTHENTICATORPASSWORD#$BCF_AUTHENTICATORPASSWORD#g" /app/chemrpslibrary.dll.config
#sed -i "s#SDFILEPATH#$SDFILEPATH#g" /app/chemrpslibrary.dll.config
