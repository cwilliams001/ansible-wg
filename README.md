# Ansible WireGuard VPN Setup

This project uses Ansible to automate the setup of a WireGuard VPN server and generate client configurations.

## Overview

This Ansible playbook sets up a WireGuard VPN server on a remote host and generates configuration files for multiple clients. It handles the installation of WireGuard, configuration of the server, setting up firewall rules, and generating client configuration files.

## Prerequisites

- Ansible installed on your local machine
- A remote server with SSH access
- Python installed on the remote server

## Files in this project

- `wg-setup.yml`: Main Ansible playbook
- `generate_client.yml`: Task file for generating client configurations
- `inventory`: Ansible inventory file
- `wg0.conf.j2`: Jinja2 template for server configuration
- `client.conf.j2`: Jinja2 template for client configuration

## Usage

1. Update the `inventory` file with your server details.

2. Run the playbook:

```bash
ansible-playbook -i inventory wg-setup.yml

```

3. After successful execution, client configuration files will be available in the `wireguard_clients` directory.

## Features

- Installs WireGuard on the server
- Generates server and client keys
- Configures the WireGuard interface
- Sets up UFW (Uncomplicated Firewall) rules
- Enables IP forwarding
- Configures NAT for VPN traffic
- Generates and fetches client configuration files

## Customization

You can customize the following variables in the `wg-setup.yml` file:

- `wireguard_port`: The port WireGuard will listen on (default: 51820)
- `wireguard_address`: The IP address range for the WireGuard interface (default: "10.0.0.1/24")
- `client_count`: The number of client configurations to generate (default: 5)

## Security Notes

- Ensure that your server's SSH port is properly secured.
- Review and adjust UFW rules as needed for your specific security requirements.
- Keep the generated private keys secure.

## Troubleshooting

If clients can't connect:
1. Check the server's firewall settings
2. Verify that IP forwarding is enabled
3. Ensure NAT is correctly configured
4. Check the WireGuard service status on the server


