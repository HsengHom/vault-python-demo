# HashiCorp Vault Python Demo

A demonstration of interacting with HashiCorp Vault using Python and the [`hvac`](https://github.com/hvac/hvac) library to read KV v2 secrets.

This repository demonstrates two authentication approaches:
1. **Token Authentication (`app.py`)**: Connects directly using a Vault token.
2. **AppRole Authentication (`app2.py`)**: Authenticates securely using AppRole (`Role ID` and `Secret ID`) to obtain a dynamic client token.

---

## Prerequisites

- Python 3.8+
- An accessible HashiCorp Vault instance (or local dev server)
- A KV version 2 secret engine enabled at `secret/` containing secret `nhhaApp` with `username` and `password` keys.

---

## Setup

### 1. Clone & Set Up Virtual Environment

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows (Command Prompt):
# venv\Scripts\activate.bat
# On Windows (PowerShell):
# venv\Scripts\Activate.ps1
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
# Alternatively:
# pip install hvac
```

### 3. Configure Environment (`.env`)

Copy `.env.example` to `.env` and fill in your Vault credentials so you don't need to manually export variables each time:

```bash
cp .env.example .env
```

Edit `.env`:
```ini
VAULT_ADDR=https://<your-vault-address>:8200
VAULT_TOKEN=<your-vault-token>
VAULT_ROLE_ID=<your-role-id>
VAULT_SECRET_ID=<your-secret-id>
```

Both `app.py` and `app2.py` automatically load `.env` on startup.

---

## Usage

### Method 1: Direct Token Authentication (`app.py`)

Set the required environment variables:

```bash
export VAULT_ADDR='https://<your-vault-address>:8200'
export VAULT_TOKEN='<your-vault-token>'
```

Run the application:

```bash
python app.py
```

**Expected Output:**
```text
Connected to Vault
Vault URL: https://<your-vault-address>:8200
Secret Path: secret/nhhaApp
Username: <username>
Password: <password>
Server running on http://localhost:9200
```

Open `http://localhost:9200` in your web browser to view the secret.

---

### Method 2: AppRole Authentication (`app2.py`)

Set the required environment variables:

```bash
export VAULT_ADDR='https://<your-vault-address>:8200'
export VAULT_ROLE_ID='<your-role-id>'
export VAULT_SECRET_ID='<your-secret-id>'
```

Run the application:

```bash
python app2.py
```

**Expected Output:**
```text
Successfully authenticated with Vault
Vault URL: https://<your-vault-address>:8200
Secret Path: secret/nhhaApp
Username: <username>
Password: <password>
Server running on http://localhost:9201
```

Open `http://localhost:9201` in your web browser to view the secret.

---

## Vault Policy Reference

The application requires read access to `secret/data/nhhaApp`. A sample policy file is provided in [`nhha-python-policy.hcl`](nhha-python-policy.hcl):

```hcl
path "secret/data/nhhaApp" {
  capabilities = ["read"]
}
```
