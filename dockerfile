# Use Windows Server Core as base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Metadata
LABEL maintainer="https://github.com/GeckoGamer"
LABEL org.opencontainers.image.source="https://github.com/GeckoGamer/POT"
LABEL org.opencontainers.image.description="Path of Titans Dedicated Server (Windows)"

# Environment variables with defaults
ENV USERNAME="" `
    PASSWORD="" `
    GUID="" `
    AUTHTOKEN="" `
    BRANCH="production" `
    PORT="7777" `
    DATABASE="Local" `
    ADDITIONAL_COMMANDS="" `
    SERVER_DIR="C:\\pot-server"

# Install required dependencies
RUN cmd -Command `
    Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vc_redist.x64.exe" -OutFile "C:\\vc_redist.x64.exe" ; `
    Start-Process "C:\\vc_redist.x64.exe" -ArgumentList '/install', '/quiet', '/norestart' -Wait ; `
    Remove-Item "C:\\vc_redist.x64.exe" -Force

# Create server directory
RUN mkdir %SERVER_DIR%

# Copy server start script (converted to .ps1 for Windows)
COPY ./serverstart.bat %SERVER_DIR%\\serverstart.bat

# Expose ports
EXPOSE 7777/udp  # Game port (UDP)
EXPOSE 7778/tcp  # RCON/Admin port (TCP)
EXPOSE 7780/tcp  # Additional port (TCP)

# Set working directory
WORKDIR %SERVER_DIR%

# Entry point
CMD ["cmd.exe", "-ExecutionPolicy", "Bypass", "-File", "C:\\pot-server\\serverstart.bat"]