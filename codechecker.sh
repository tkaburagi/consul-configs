#!/bin/sh
cd /home/ubuntu

wget "${var.vault_dl_url}"
wget "${var.consul_dl_url}"

unzip vault*.zip
rm vault*zip

unzip consul*.zip
rm consul*zip

chmod +x vault
chmod +x consul

wget https://raw.githubusercontent.com/tkaburagi/vault-configs/master/remote-vault-template.hcl
sed -e 's/SERVICE_NAME_REPLACE/"${var.vault_instance_name}-${count.index}-hashistack"/g' remote-vault-template.hcl > remote-vault-template-2.hcl
sed -e 's/API_ADDR_REPLACE/"http:\/\/${var.vault_url}"/g' remote-vault-template-2.hcl > remote-vault.hcl

export VAULT_AWSKMS_SEAL_KEY_ID=${var.kms_key_id}
export AWS_SECRET_ACCESS_KEY=${var.secret_key}
export AWS_ACCESS_KEY_ID=${var.access_key}

nohup ./consul agent -bind=0.0.0.0 -data-dir=/home/ubuntu -retry-join "provider=aws tag_key=Consul_server tag_value=true access_key_id=${var.access_key} secret_access_key=${var.secret_key}" &
nohup ./vault server -config /home/ubuntu/remote-vault.hcl &

rm remote-vault-template-*