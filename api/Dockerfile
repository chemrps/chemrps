FROM mcr.microsoft.com/dotnet/core/sdk:3.1

COPY publish/ /app

COPY chemrpslibrary.dll.config /app




COPY .env /app
COPY env-entrypoint.sh /app

RUN chmod +x /app/env-entrypoint.sh

RUN /app/env-entrypoint.sh

WORKDIR /app
ENTRYPOINT ["dotnet", "chemrpsapi.dll"]