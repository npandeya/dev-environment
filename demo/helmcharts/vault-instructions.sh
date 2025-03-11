helm repo add hashicorp https://helm.releases.hashicorp.com

helm repo update

helm install vault hashicorp/vault -f vault-values.yaml --create-namespace --namespace vault

# If not in dev mode, then use the following command
kubectl exec -it vault-0 -n vault -- vault operator init
# You'll see output like this:
# Unseal Key 1: <key-1>
# Unseal Key 2: <key-2>
# Unseal Key 3: <key-3>
# ...
# Initial Root Token: <root-token>
# Save the unseal keys and root token somewhere secure.
# You’ll need to use at least 3 keys to unseal the Vault.
kubectl exec -it vault-0 -n vault -- vault operator unseal
# You’ll be prompted to enter the unseal keys.
# You need to repeat this command three times using different keys.
# Once unsealed, Vault will remain active unless the pod restarts.
kubectl exec -it vault-0 -n vault -- vault login <root-token>
# Non Dev Mode specific command end ---------------------------
# Install Vault CLI
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault
# https://developer.hashicorp.com/vault/install

export KUBERNETES_PORT_443_TCP_ADDR=$(kubectl exec -it vault-0 -n vault -- sh -c 'echo $KUBERNETES_PORT_443_TCP_ADDR')

export VAULT_ADDR='http://vault.nimesh.lab'
kubectl logs vault-0 -n vault | grep 'Root Token' # Wont work in non dev mode 
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


