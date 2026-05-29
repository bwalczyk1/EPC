*** Settings ***
Documentation    Bug reproduction tests for EPC Simulator REST API
Resource         ../../resources/keywords.robot
Suite Setup      Suite Setup EPC Session
Test Setup       Reset Simulator


*** Test Cases ***

# BUG: API reports success when stopping traffic that is not running.
TC50 Stop traffic with no active transfer should fail
    [Documentation]    Reject stopping traffic that is not running.
    [Tags]    bug    defect-40    traffic    lifecycle
    Attach UE-1
    Stop Traffic UE-1 Bearer-9 Should Fail With No Active Traffic


# BUG: API reports success when stopping the same traffic twice.
TC51 Stop traffic twice should fail second time
    [Documentation]    Reject stopping the same traffic twice.
    [Tags]    bug    defect-40    traffic    lifecycle
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-10
    Stop Traffic UE-1 Bearer-9
    Stop Traffic Should Fail With Traffic Not Running    1    9


# BUG: API allows deleting a bearer while traffic is active.
TC55 Delete bearer with active traffic should be rejected
    [Documentation]    Reject deleting a bearer while traffic is active.
    [Tags]    bug    defect-40    traffic    bearer    lifecycle
    Attach UE-1
    Add Bearer-1 To UE-1
    Start Traffic UE-1 Bearer-1 Speed-500
    Delete Bearer-1 From UE-1 Should Fail With Active Traffic


# BUG: API allows detaching a UE while traffic is active.
TC56 Detach UE with active traffic should be rejected
    [Documentation]    Reject detaching a UE while traffic is active.
    [Tags]    bug    defect-40    traffic    ue    lifecycle
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-1000
    Verify Bearer-9 Active For UE-1
    Detach UE-1 Should Fail With Active Traffic
