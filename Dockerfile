FROM mcr.microsoft.com/dotnet/aspnet:5.0-focal AS base
WORKDIR /app
EXPOSE 80

ENV ASPNETCORE_URLS=http://+:80

FROM mcr.microsoft.com/dotnet/sdk:5.0-focal AS build
WORKDIR /src
COPY ["retailonks.csproj", "./"]
RUN dotnet restore "retailonks.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "retailonks.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "retailonks.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "retailonks.dll"]
