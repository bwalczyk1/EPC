# TESTOWANIE OPROGRAMOWANIA

## Setup
```
python3 -m venv .venv
. .venv/bin/activate
pip3 install -r requirements.txt
```

## Launch tests
```commandline
robot --outputdir results tests/epc_smoke.robot
```