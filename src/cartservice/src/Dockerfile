# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS builder

WORKDIR /app

COPY cartservice.csproj ./
RUN dotnet restore cartservice.csproj

COPY . ./
RUN dotnet publish cartservice.csproj -c Release -o /app/publish --no-restore

# Stage 2: Run
FROM mcr.microsoft.com/dotnet/aspnet:10.0

WORKDIR /app

COPY --from=builder /app/publish ./

EXPOSE 7070

ENTRYPOINT ["dotnet", "cartservice.dll"]
