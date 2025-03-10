# Generate GPG Key
gpg --full-generate-key
# Options to select:
# Type: RSA
# Key length: 4096 bits
# Expiration: 1 year
# Name: GitLab Secrets
# Email: your-email@example.com
# Passphrase: Optional
# or 
# Generate Key directly 
gpg --batch --gen-key --pinentry-mode=loopback <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Name-Real: GitLab Secrets
Name-Email: your-email@example.com
Expire-Date: 1y
%commit
EOF

# or 
docker run --rm -it \
  --entrypoint sh \
  -v ~/.gnupg:/root/.gnupg \
  ghcr.io/getsops/sops:v3.9.4 -c "
  gpg --batch --generate-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Name-Real: GitLab Secrets
Name-Email: your-email@example.com
Expire-Date: 1y
%commit
EOF
"

# List GPG Keys
gpg --list-secret-keys --keyid-format LONG
# or 
docker run --rm -it --entrypoint sh -v ~/.gnupg:/root/.gnupg ghcr.io/getsops/sops:v3.9.4 -c "
  gpg --list-secret-keys --keyid-format LONG
"

# Output example:
# /Users/username/.gnupg/secring.gpg
# ----------------------------------
# sec   4096R/3AA5C34371567BD2 2025-03-10 [expires: 2026-03-10]
#       Key fingerprint = ABCD 1234 EFGH 5678 IJKL 9876 MNOP 5432 QRST
# uid       [ultimate] GitLab Secrets <your-email@example.com>
# ssb   4096R/1BB5C6D4B1234567 2025-03-10

# In this example, the Key ID is 3AA5C34371567BD2 (replace with your own).

# Export the Private Key
gpg --export-secret-keys --armor <key id> > sops-key.asc
# or
docker run --rm -it --entrypoint sh -v ~/.gnupg:/root/.gnupg ghcr.io/getsops/sops:v3.9.4 -c "
  gpg --export-secret-keys --armor 3AA5C34371567BD2
"
# Output example:
# -----BEGIN PGP PRIVATE KEY BLOCK-----
# ...
# -----END PGP PRIVATE KEY BLOCK-----


# Copy the Key for Gitlab CICD
cat sops-key.asc

# Add the Key to GitLab CICD

# Create and Encrypt Secret with SOPS

# Create a file named secrets.yaml
# api_key: "my-super-secret-key"
# database_password: "my-db-password"

# Encrypt the file with SOPS
sops --encrypt --pgp BF8165F154D74485 -i secret.yml

# Note: Replace 3AA5C34371567BD2 with your actual Key ID


# After encryption, verify the encrypted content and commit to your repo 

# Decrypt the file with SOPS
sops --decrypt secrets.yaml > decrypted_secrets.yaml


 