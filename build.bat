

copy .env api /Y

copy .env bulksdfileloadconsole /Y


copy .env web /Y

copy .env database /Y

copy .env php /Y






docker-compose -f ./chemrps.yml build