FROM microsoft/dotnet:2.2-aspnetcore-runtime AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443
EXPOSE 5003

FROM microsoft/dotnet:2.2-sdk AS build
WORKDIR /src
COPY ["ecrsapi/ecrsapi.csproj", "ecrsapi/"]
COPY ["ecrslibrary/ecrslibrary.csproj", "ecrslibrary/"]



RUN dotnet restore "ecrsapi/ecrsapi.csproj"
COPY . .
WORKDIR "/src/ecrsapi"
RUN dotnet build "ecrsapi.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "ecrsapi.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .


COPY ecrslibrary.dll.config .
ENTRYPOINT ["dotnet", "ecrsapi.dll"]