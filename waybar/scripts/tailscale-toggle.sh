#!/bin/bash
status=$(systemctl is-active tailscaled.service)

if [ "$status" = "active" ]; then
    sudo systemctl stop tailscaled.service
else
    sudo systemctl start tailscaled.service
fi
