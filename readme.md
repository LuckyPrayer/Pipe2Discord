# Pipe2Discord (P2D.sh)

Pipe2Discord is a Bash script that reads input lines and sends them to a Discord webhook. It supports rate limiting and asynchronous processing to ensure that messages are sent efficiently.

## Features

- Reads input lines and sends them to a Discord webhook.
- Supports rate limiting to avoid hitting Discord's rate limits.
- Asynchronous processing to collect and send messages every 3 seconds.
- Configurable via a configuration file.

## Requirements

- Bash
- `curl` command-line tool

## Usage
```bash
echo "Hello, Discord!" | ./P2D.sh

## Configuration

Create a configuration file named `P2D.cfg` in the same directory as the script. The configuration file should contain the following variables:

```bash
# P2D.cfg
WEBHOOK_URL="https://discord.com/api/webhooks/your_webhook_id/your_webhook_token"
TIMEOUT=5  # Optional timeout for curl requests