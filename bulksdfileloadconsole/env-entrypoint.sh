#!/bin/bash

set -e



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
source /app/config


chown -R chemrps:chemrps /app



sed -i "s#DATABASEPORT#$DATABASEPORT#g" /app/chemrpslibrary.dll.config
sed -i "s#DATABASENAME#$DATABASENAME#g" /app/chemrpslibrary.dll.config
sed -i "s#BCF_AUTHENTICATORPASSWORD#$BCF_AUTHENTICATORPASSWORD#g" /app/chemrpslibrary.dll.config
#sed -i "s#SDFILEPATH#$SDFILEPATH#g" /app/chemrpslibrary.dll.config
sed -i "s#SERVERNAME#$SERVERNAME#g" /app/chemrpslibrary.dll.config

sed -i "s#SDFILENAME#$SDFILENAME#g" /app/chemrpsbulksdfileloadconsole.dll.config
sed -i "s#COMPOUNDIDFIELDNAME#$COMPOUNDIDFIELDNAME#g" /app/chemrpsbulksdfileloadconsole.dll.config
