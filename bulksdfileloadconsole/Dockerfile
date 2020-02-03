FROM mcr.microsoft.com/dotnet/core/sdk:3.1


COPY publish/ /app

COPY sdfile/ /app

COPY chemrpslibrary.dll.config /app
COPY chemrpsbulksdfileloadconsole.dll.config /app
#COPY pubchemstructures_7records.sdf /app

COPY .env /app
COPY config /app
COPY env-entrypoint.sh /app



RUN chmod +x /app/env-entrypoint.sh
  
RUN /app/env-entrypoint.sh

#CMD [/app/env-entrypoint.sh]

WORKDIR /app

ENTRYPOINT ["dotnet", "chemrpsbulksdfileloadconsole.dll"]