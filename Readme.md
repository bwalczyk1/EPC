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

Serwis EPC Simulator musi działać na `http://localhost:8000`.

```commandline
# Smoke — bez testów dokumentujących znane błędy serwisu (oczekiwany wynik: PASS):
robot --outputdir results --exclude bug tests/epc_smoke.robot

# Pełny audyt — w tym testy z tagiem bug (część testów padnie do naprawy backendu):
robot --outputdir results tests/epc_smoke.robot
```

Znane błędy serwisu i kroki reprodukcji: [docs/epc_simulator_bugs.md](docs/epc_simulator_bugs.md).