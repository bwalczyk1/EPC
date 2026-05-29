# TESTOWANIE OPROGRAMOWANIA

## Setup
```commandline
mkdir .venv
python3 -m venv .venv

# For macOS using zsh
. .venv/bin/activate

# For macOS using fish
. .venv/bin/activate.fish

# For Windows
. .venv/Scripts/activate

pip3 install -r requirements.txt
```

## Launch tests

EPC simulator service must run on `http://localhost:8000`.

##### Full test suite

To launch full test suite and list results in `results/full` folder, run:

```commandline
robot --outputdir results/full tests/epc_full.robot
```

##### Smoke tests

To launch only smoke tests and list results in `results/smoke` folder, run:
```commandline
robot --outputdir results/smoke tests/smoke/epc_smoke.robot
```

##### Speed, throughput and validation tests

To launch speed, throughput and validation tests suite and list results in `results/10_speed` folder, run:
```commandline
robot --outputdir results/10_speed tests/bugs/defect_10_speed.robot
```

##### Contract tests

To launch contract test suite and list results in `results/20_contract` folder, run:
```commandline
robot --outputdir results/20_contract  tests/bugs/defect_20_contract.robot
```

##### Traffic stats, units and states tests

To traffic stats, units and states test suite and list results in `results/30_stats` folder, run:
```commandline
robot --outputdir results/30_stats  tests/bugs/defect_30_stats.robot
```

##### Lifecycle tests

To launch lifecycle test suite and list results in `results/40_lifecycle` folder, run:
```commandline
robot --outputdir results/40_lifecycle  tests/bugs/defect_40_lifecycle.robot
```

##### Type validation tests

To type validation suite and list results in `results/50_id_validation` folder, run:
```commandline
robot --outputdir results/50_id_validation  tests/bugs/defect_50_id_validation.robot
```

## Bug types

Bugs are categorized within 5 categories, with IDs assigned based on each of them:
- **10.x** - speed, throughput, and kbps validation,
- **20.x** - inconsistency with documentation and API,
- **30.x** - traffic statistics, units, and inconsistent state
- **40.x** - traffic lifecycle, stop/delete/detach,
- **50.x** - identifier type validation.