#!/bin/bash

systemctl --user enable --now gcr-ssh-agent.socket

# This stores the password securely in your login keyring
secret-tool store --label="SSH Key: id_ed25519" unique "ssh-store:$HOME/.ssh/id_ed25519"

