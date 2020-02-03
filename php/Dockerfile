FROM php:fpm

 COPY code /code
  
 RUN chown -R www-data:www-data /code
 
 
 #RUN /code/env-entrypoint.sh
 
 #ADD env-entrypoint.sh /tmp/makedir.sh
 
 #RUN chmod +x /tmp/makedir.sh
 
 #RUN /tmp/makedir.sh
 
 RUN mkdir /sdfilefolder
 
 RUN chown -R www-data:www-data /sdfilefolder
 
 COPY .env /code
 COPY env-entrypoint.sh /code
 
 RUN chmod +x /code/env-entrypoint.sh
 
 RUN /code/env-entrypoint.sh
  
  
 
