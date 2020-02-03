

copy .env chemrpsapi /Y




copy .env chemrpsweb /Y

copy .env database /Y

copy .env php /Y






docker-compose -f ./chemrps.yml build