#!/bin/bash

echo "==================================="
echo "Ansible WireGuard Playbook Validator"
echo "==================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if ansible is installed
if ! command -v ansible &> /dev/null; then
    echo -e "${RED}✗ Ansible is not installed${NC}"
    exit 1
fi

echo "Ansible version:"
ansible --version | head -1
echo ""

# Install required collections
echo "Installing required Ansible collections..."
ansible-galaxy collection install -r requirements.yml --force 2>/dev/null || {
    echo -e "${YELLOW}⚠ Warning: Could not install collections${NC}"
}
echo ""

# Validate playbook syntax
echo "Validating playbook syntax..."
ansible-playbook wg-setup.yml --syntax-check
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Playbook syntax is valid${NC}"
else
    echo -e "${RED}✗ Playbook syntax validation failed${NC}"
    exit 1
fi
echo ""

# Lint the playbook (if ansible-lint is installed)
if command -v ansible-lint &> /dev/null; then
    echo "Running ansible-lint..."
    ansible-lint wg-setup.yml generate_client.yml || {
        echo -e "${YELLOW}⚠ Warning: Some linting issues found${NC}"
    }
else
    echo -e "${YELLOW}⚠ ansible-lint not installed, skipping linting${NC}"
fi
echo ""

# Check inventory
echo "Checking inventory..."
ansible-inventory -i inventory --list > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Inventory is valid${NC}"
    echo "Hosts in inventory:"
    ansible all -i inventory --list-hosts | sed 's/^/  /'
else
    echo -e "${RED}✗ Inventory validation failed${NC}"
    exit 1
fi
echo ""

# Dry run check (if host is accessible)
echo "To perform a dry run against your host, run:"
echo "  ansible-playbook -i inventory wg-setup.yml --check"
echo ""

echo -e "${GREEN}✓ All validation checks passed!${NC}"