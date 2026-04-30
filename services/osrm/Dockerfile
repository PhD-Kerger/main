FROM osrm/osrm-backend:latest

# Expose port
EXPOSE 5000

# Copy the startup script
COPY data/scripts/start-osrm.sh /usr/local/bin/start-osrm.sh

# Make the script executable
RUN chmod +x /usr/local/bin/start-osrm.sh

# Set the script as the default command
CMD [ "/usr/local/bin/start-osrm.sh" ]