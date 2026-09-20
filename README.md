#for app.py
export VAULT_ADDR='https://xxxxxxxx'
export VAULT_TOKEN='hvs.xxxxxxxxx'

#for app2.py
export VAULT_ADDR='https://xxxxxxxx'
export VAULT_ROLE_ID='xxxxxxxx'
export VAULT_SECRET_ID='xxxxxxxx'

python3 -m venv venv
source venv/bin/activate
pip install hvac
pip show hvac

#To run app.py
python app.py

#To run app2.py 
python app2.py
