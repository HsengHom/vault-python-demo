import os
import hvac


VAULT_ADDR = os.environ["VAULT_ADDR"]
VAULT_ROLE_ID = os.environ["VAULT_ROLE_ID"]
VAULT_SECRET_ID = os.environ["VAULT_SECRET_ID"]


# Create Vault client
client = hvac.Client(url=VAULT_ADDR)


# Authenticate using AppRole
login_response = client.auth.approle.login(
    role_id=VAULT_ROLE_ID,
    secret_id=VAULT_SECRET_ID
)


# Vault generated this token for us
vault_token = login_response["auth"]["client_token"]

print("Successfully authenticated with Vault")


# Use the generated token
client.token = vault_token


# Read KV v2 secret
secret = client.secrets.kv.v2.read_secret_version(
    mount_point="secret",
    path="nhhaApp"
)


data = secret["data"]["data"]


print("Username:", data["username"])
print("Password:", data["password"])
