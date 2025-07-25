#!/usr/bin/env bash

# sudo dnf install -y curl jq unzip

# Fetch latest release tag (e.g., v1.12.2)
TAG=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | jq -r .tag_name)

# Remove leading 'v'
VERSION=${TAG#v}

# Construct the URL
URL="https://releases.hashicorp.com/terraform/$VERSION/terraform_${VERSION}_linux_amd64.zip"

cd /tmp
rm -rf /tmp/terraform* /tmp/LICENSE.txt
wget "$URL"
unzip "terraform_${VERSION}_linux_amd64.zip"
sudo cp -f terraform /usr/local/bin/terraform

echo
echo "terraform has been installed to /usr/local/bin"
/usr/local/bin/terraform --version

rm -rf /tmp/terraform* /tmp/LICENSE.txt
