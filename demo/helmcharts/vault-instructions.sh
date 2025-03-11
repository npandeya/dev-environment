helm repo add hashicorp https://helm.releases.hashicorp.com

helm repo update

helm install vault hashicorp/vault -f vault-values.yaml --create-namespace --namespace vault

# Install Vault CLI
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault
# https://developer.hashicorp.com/vault/install

export VAULT_ADDR='http://vault.nimesh.lab'
kubectl logs vault-0 -n vault | grep 'Root Token'
vault login <root-token>


kubectl exec -it vault-0 -- /bin/sh
vault auth enable kubernetes
vault write auth/kubernetes/config \
      kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"

vault policy write snake-game - <<EOF
path "secret/data/snake-license" {
   capabilities = ["read"]
}
EOF

vault write auth/kubernetes/role/snake-game \
      bound_service_account_names=snake-game \
      bound_service_account_namespaces=snake-game \
      policies=snake-game \
      ttl=24h

k create ns snake-game
k create sa snake-game -n snake-game


