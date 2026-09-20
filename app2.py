import os
import html
from pathlib import Path
from http.server import HTTPServer, BaseHTTPRequestHandler
import hvac

def load_env():
    env_file = Path(__file__).parent / ".env"
    if env_file.exists():
        with open(env_file, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    k, v = line.split("=", 1)
                    os.environ.setdefault(k.strip(), v.strip().strip("'\""))

load_env()

VAULT_ADDR = os.environ.get("VAULT_ADDR")
VAULT_ROLE_ID = os.environ.get("VAULT_ROLE_ID")
VAULT_SECRET_ID = os.environ.get("VAULT_SECRET_ID")
PORT = 9201
SECRET_PATH = "secret/nhhaApp"

TEMPLATE_PATH = Path(__file__).parent / "templates" / "index.html"


def fetch_secret():
    """Authenticates with Vault using AppRole and reads KV v2 secret."""
    client = hvac.Client(url=VAULT_ADDR)
    login_response = client.auth.approle.login(
        role_id=VAULT_ROLE_ID,
        secret_id=VAULT_SECRET_ID,
    )
    client.token = login_response["auth"]["client_token"]

    secret = client.secrets.kv.v2.read_secret_version(
        path="nhhaApp",
        mount_point="secret",
        raise_on_deleted_version=True,
    )
    return secret["data"]["data"]


def render_template(title: str, vault_url: str, secret_path: str, username: str, password: str) -> str:
    """Reads templates/index.html and injects secret values."""
    with open(TEMPLATE_PATH, "r", encoding="utf-8") as f:
        template = f.read()

    return (
        template.replace("{{ title }}", html.escape(str(title)))
        .replace("{{ vault_url }}", html.escape(str(vault_url)))
        .replace("{{ secret_path }}", html.escape(str(secret_path)))
        .replace("{{ username }}", html.escape(str(username)))
        .replace("{{ password }}", html.escape(str(password)))
    )


class VaultHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            data = fetch_secret()
            html_content = render_template(
                title="Vault Secret with AppRole Auth",
                vault_url=VAULT_ADDR or "",
                secret_path=SECRET_PATH,
                username=data.get("username", ""),
                password=data.get("password", ""),
            )
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(html_content.encode("utf-8"))
        except Exception as e:
            self.send_response(500)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(f"Error fetching secret: {e}".encode("utf-8"))


def main():
    data = fetch_secret()
    print("Successfully authenticated with Vault")
    print("Vault URL:", VAULT_ADDR)
    print("Secret Path:", SECRET_PATH)
    print("Username:", data.get("username", ""))
    print("Password:", data.get("password", ""))

    server = HTTPServer(("0.0.0.0", PORT), VaultHandler)
    print(f"Server running on http://localhost:{PORT}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.server_close()


if __name__ == "__main__":
    main()
