# Ansible WireGuard VPN Setup

A production-ready Ansible playbook for automated WireGuard VPN server deployment on Ubuntu 24.04 LTS and compatible systems.

## Features

- **Automated WireGuard Installation**: Complete server setup and configuration
- **Multi-Client Support**: Generate configurations for multiple VPN clients
- **Security Enhancements**:
  - Preshared keys for additional security
  - Proper file permissions (0600) for all keys
  - UFW firewall configuration with NAT rules
- **Network Auto-Detection**: Automatically detects the primary network interface
- **Idempotent Operations**: Safe to run multiple times without side effects
- **Ubuntu 24.04 Compatible**: Tested and optimized for the latest Ubuntu LTS
- **Ansible Best Practices**:
  - Full namespace usage (`ansible.builtin.*`)
  - Proper handlers for service management
  - Variable validation and defaults
  - Tags for selective execution

## Prerequisites

- **Control Machine** (your local computer):
  - Ansible 2.14+ installed
  - SSH access to the target server

- **Target Server** (VPS/Cloud instance):
  - Ubuntu 22.04/24.04 LTS (or Debian 11/12)
  - Python 3 installed
  - Root or sudo access
  - Public IP address

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/ansible-wg.git
cd ansible-wg
```

### 2. Install Ansible Collections

```bash
ansible-galaxy collection install -r requirements.yml
```

### 3. Configure Inventory

Edit the `inventory` file with your server details:

```ini
[vps]
your-server-hostname ansible_host=YOUR_SERVER_IP ansible_user=root
```

Or if using SSH key authentication with a non-root user:

```ini
[vps]
your-server ansible_host=YOUR_SERVER_IP ansible_user=ubuntu ansible_become=yes
```

### 4. Customize Variables (Optional)

Edit `group_vars/all/wireguard.yml` to customize:

- `wireguard_port`: VPN listening port (default: 51820)
- `wireguard_network`: VPN network range (default: 10.0.0.0/24)
- `wireguard_client_count`: Number of client configs to generate (default: 5)
- `wireguard_dns`: DNS servers for clients (default: Cloudflare 1.1.1.1)

### 5. Validate Configuration

Run the validation script to check your setup:

```bash
./validate.sh
```

### 6. Deploy WireGuard

```bash
ansible-playbook -i inventory wg-setup.yml
```

For a dry run (check mode):

```bash
ansible-playbook -i inventory wg-setup.yml --check
```

### 7. Retrieve Client Configurations

After successful deployment, client configuration files will be automatically downloaded to `./wireguard_clients/` directory.

## File Structure

```
ansible-wg/
├── ansible.cfg              # Ansible configuration
├── requirements.yml         # Ansible collection dependencies
├── inventory               # Server inventory file
├── wg-setup.yml           # Main playbook
├── generate_client.yml    # Client generation tasks
├── validate.sh            # Validation script
├── group_vars/
│   └── all/
│       └── wireguard.yml  # WireGuard variables
├── templates/
│   ├── wg0.conf.j2       # Server config template
│   └── client.conf.j2    # Client config template
└── wireguard_clients/     # Downloaded client configs (created after run)
```

## Advanced Usage

### Using Tags

Run specific parts of the playbook:

```bash
# Only install packages
ansible-playbook -i inventory wg-setup.yml --tags packages

# Only configure firewall
ansible-playbook -i inventory wg-setup.yml --tags firewall

# Generate client configs only
ansible-playbook -i inventory wg-setup.yml --tags clients

# Skip firewall configuration
ansible-playbook -i inventory wg-setup.yml --skip-tags firewall
```

### Available Tags

- `packages` - Install WireGuard and dependencies
- `networking` - Configure network interfaces and IP forwarding
- `keys` - Generate server keys
- `clients` - Generate client configurations
- `firewall` - Configure UFW firewall rules
- `service` - Manage WireGuard service
- `config` - Deploy WireGuard configuration
- `verify` - Verify WireGuard is running

### Adding More Clients

To add more clients after initial setup, increase `wireguard_client_count` in `group_vars/all/wireguard.yml` and re-run:

```bash
ansible-playbook -i inventory wg-setup.yml --tags clients,config,service
```

## Client Setup

### Mobile Devices (iOS/Android)

1. Install the official WireGuard app
2. Scan the QR code or import the `.conf` file
3. Enable the VPN connection

### Desktop (Linux/macOS/Windows)

1. Install WireGuard client
2. Import the client configuration file
3. Activate the VPN connection

### Linux Command Line

```bash
# Copy client config to /etc/wireguard/
sudo cp client1.conf /etc/wireguard/wg0.conf

# Start WireGuard
sudo wg-quick up wg0

# Enable on boot (optional)
sudo systemctl enable wg-quick@wg0
```

## Security Considerations

- **Key Security**: All private keys are generated on the server with restricted permissions (0600)
- **Preshared Keys**: Additional layer of quantum-resistant security
- **Firewall**: UFW is configured to allow only necessary ports
- **IP Forwarding**: Enabled only for the WireGuard interface
- **DNS**: Clients use Cloudflare's privacy-focused DNS by default

## Troubleshooting

### Validation Issues

If `./validate.sh` fails:

1. Ensure Ansible is installed: `ansible --version`
2. Check inventory syntax: `ansible-inventory -i inventory --list`
3. Verify SSH connectivity: `ansible all -i inventory -m ping`

### Connection Issues

If clients can't connect:

1. **Check WireGuard service**:
   ```bash
   ssh your-server "sudo systemctl status wg-quick@wg0"
   ```

2. **Verify firewall rules**:
   ```bash
   ssh your-server "sudo ufw status verbose"
   ```

3. **Check interface**:
   ```bash
   ssh your-server "sudo wg show"
   ```

4. **Review logs**:
   ```bash
   ssh your-server "sudo journalctl -u wg-quick@wg0 -n 50"
   ```

### Network Issues

If clients connect but can't access the internet:

1. **Verify IP forwarding**:
   ```bash
   ssh your-server "sysctl net.ipv4.ip_forward"
   ```

2. **Check NAT rules**:
   ```bash
   ssh your-server "sudo iptables -t nat -L POSTROUTING"
   ```

## Version Compatibility

- **Ubuntu**: 22.04 LTS, 24.04 LTS
- **Debian**: 11 (Bullseye), 12 (Bookworm)
- **Ansible**: 2.14+
- **Python**: 3.8+

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test your changes with `./validate.sh`
4. Submit a pull request

## License

MIT License - See LICENSE file for details

## Changelog

### v2.0.0 (2024)
- Complete rewrite for Ubuntu 24.04 compatibility
- Added automatic network interface detection
- Implemented Ansible best practices
- Added preshared keys for enhanced security
- Improved idempotency and error handling
- Added validation script
- Added comprehensive variable management

### v1.0.0 (Initial)
- Basic WireGuard setup functionality
- Manual network interface configuration
- Simple client generation