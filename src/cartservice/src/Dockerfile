# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS builder

WORKDIR /app

COPY src/cartservice.csproj ./src/
RUN dotnet restore src/cartservice.csproj

COPY src/ ./src/
RUN dotnet publish src/cartservice.csproj -c Release -o /app/publish --no-restore

# Stage 2: Run
FROM mcr.microsoft.com/dotnet/aspnet:10.0

WORKDIR /app

COPY --from=builder /app/publish ./

EXPOSE 7070

ENTRYPOINT ["dotnet", "cartservice.dll"]
