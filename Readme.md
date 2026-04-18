# TESTOWANIE OPROGRAMOWANIA

## Setup
```commandline
mkdir .venv
python3 -m venv .venv

# For MacOS
. .venv/bin/activate
# For Windows
. .venv/Scripts/activate

pip3 install -r requirements.txt
```

## Launch tests
```commandline
robot --outputdir results tests/epc_smoke.robot
```