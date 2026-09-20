vault server -dev
ngrok version
brew install ngrok
ngrok config add-authtoken <YOUR_NGROK_TOKEN>
ngrok http 8200


export VAULT_ADDR="https://uptake-freebie-hypnotist.ngrok-free.dev"
export VAULT_TOKEN="hvs.b8fEJ47KHnoNt16zTzMA2jgA"

vault kv put secret/nhhaApp \
    username=nhha-demo \
    password=secret123

vault kv get secret/nhhaApp
vault policy write nhha-python-policy nhha-python-policy.hcl
vault policy read nhha-python-policy

vault auth list
vault auth enable approle
vault auth list

vault write auth/approle/role/nhha-python \
    token_policies="nhha-python-policy" \
    token_ttl=1h \
    token_max_ttl=4h

vault read auth/approle/role/nhha-python/role-id

export VAULT_ROLE_ID="1b16e12e-3123-09c5-cbd9-611afcaa2e12"

vault write -f auth/approle/role/nhha-python/secret-id

export VAULT_SECRET_ID="cdbe599c-7fed-8cec-4695-0d2a9548eaff"


vault write auth/approle/login \
    role_id="$VAULT_ROLE_ID" \
    secret_id="$VAULT_SECRET_ID"


token = hvs.CAESIIQ-FkwZYHz0K4drCIbLytRcUG8pZbR0DHf9qrT9BqRCGh4KHGh2cy5YTXNTNW5SeTMxOThCWm1PMlcwZlJCY2c



APP_TOKEN=$(vault write -field=token auth/approle/login \
    role_id="$VAULT_ROLE_ID" \
    secret_id="$VAULT_SECRET_ID")

VAULT_TOKEN="$APP_TOKEN" vault kv get secret/nhhaApp

echo $VAULT_ADDR
echo $VAULT_ROLE_ID
echo $VAULT_SECRET_ID
