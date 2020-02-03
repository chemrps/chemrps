from nginx
  COPY site/site.conf /etc/nginx/conf.d/default.conf
  #COPY code /code
  
  #RUN chown -R www-data:www-data /code
  
  COPY .env /tmp
  COPY env-entrypoint.sh /tmp
 
  RUN chmod +x /tmp/env-entrypoint.sh
 
  RUN /tmp/env-entrypoint.sh
  #COPY site/site.conf /etc/nginx/conf.d/default.conf
  
  #COPY .env /code
  
  #COPY env-entrypoint.sh /tmp
  #COPY env-entrypoint.sh /code
  #ENV TEST1="11" TEST2="12"
  
  #RUN mkdir /code/sdfileuploads
  
  #RUN chown -R www-data:www-data /code/sdfileuploads

  #RUN chmod -R 755 /code/sdfileuploads
  
  #RUN chown -R root:root /code/sdfileuploads

  #RUN chmod -R 755 /code/sdfileuploads
  
  
  #RUN sed -i "s/TEST/${TEST1}/g" /code/chemrpssearch.js
  #RUN sed -i "s/NEWVARIABLE/${TEST2}/g" /code/chemrpssearch.js
  
  
  
  #CMD ["chmod +x /code/env-entrypoint.sh"]
  
  
  #COPY env-entrypoint.sh /code
  
  #CMD ["chmod +x /code/env-entrypoint.sh"]
  
  #CMD ["./code/env-entrypoint.sh"]
  
  #COPY env-entrypoint.sh env-entrypoint.sh
  
  #CMD [env-entrypoint.sh]
  
  #RUN chmod +x /code/env-entrypoint.sh
  
  #ENTRYPOINT [/code/env-entrypoint.sh]

  #CMD ["./code/env-entrypoint.sh"]
  
  #CMD [/code/env-entrypoint.sh]
  
  #RUN chmod +x /code/env-entrypoint.sh
  #RUN chmod +x /tmp/env-entrypoint.sh
  
  #RUN /code/env-entrypoint.sh
  #RUN /tmp/env-entrypoint.sh
  
  #RUN mkdir /code
 
  #RUN chown -R www-data:www-data /code