echo "Installing mavlink-router..."

# Create the directory for the binary if it doesn't exist
sudo mkdir -p /usr/bin

# Copy the mavlink-routerd binary from the current directory
echo "Copying the mavlink-routerd binary to /usr/bin"
sudo cp "$(pwd)/mavlink-routerd" /usr/bin/

# Make sure the binary is executable
sudo chmod +x /usr/bin/mavlink-routerd

# Create the directory for the config file if it doesn't exist
sudo mkdir -p /etc/mavlink-router

# Write the config file contents
sudo tee /etc/mavlink-router/main.conf > /dev/null <<EOL
[General]
   TcpServerPort=5760
   ReportStats=false
   BlockMsgIdIn=66
   BlockMsgIdOut=66
   LimitAttitudeRate=true

[UartEndpoint serial0]
   Device=/dev/serial0
   Baud=921600

[UdpEndpoint attitudeListener]
   Mode=normal
   Address=127.0.0.1
   Port=14550

[UdpEndpoint missionPlanner]
   Mode=normal
   Port=15600
   Address=192.168.1.66
   BlockMsgIdIn=66
   BlockMsgIdOut=66
   LimitAttitudeRate=true
EOL

# Create the systemd service file
sudo tee /etc/systemd/system/mavlink-router.service > /dev/null <<EOL
[Unit]
Description=MAVLink Router
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/mavlink-routerd
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the MAVLink Router service
echo "Enabling and starting mavlink-router service..."
sudo systemctl daemon-reload
sudo systemctl enable mavlink-router.service
sudo systemctl start mavlink-router.service
