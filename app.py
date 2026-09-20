import os
import hvac

VAULT_ADDR = os.environ["VAULT_ADDR"]
VAULT_TOKEN = os.environ["VAULT_TOKEN"]

client = hvac.Client(
    url=VAULT_ADDR,
    token=VAULT_TOKEN
)

if not client.is_authenticated():
    raise Exception("Vault authentication failed")

print("Connected to Vault")

secret = client.secrets.kv.v2.read_secret_version(
    path="nhhaApp",
    mount_point="secret"
)

data = secret["data"]["data"]

print("Username:", data["username"])
print("Password:", data["password"])