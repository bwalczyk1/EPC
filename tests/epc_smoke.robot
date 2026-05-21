*** Settings ***
Documentation    Smoke tests for EPC Simulator REST API
Resource         ../resources/keywords.robot
Suite Setup      Suite Setup EPC Session
Test Setup       Reset Simulator


*** Test Cases ***
TC01 Attach UE successfully
    [Documentation]    Docs
    Attach UE-1
    Verify UE-1 Attached Successfully

TC02 Attach UE with out of range ID
    Attach UE-0 Should Fail With Out Of Range
    Attach UE-101 Should Fail With Out Of Range

TC03 Attach already attached UE
    Attach UE-1
    Attach UE-1 Should Fail With Already Attached

TC04 Verify default bearer after attach
    Attach UE-1
    Verify UE-1 Has Default Bearer

TC05 Detach UE successfully
    Attach UE-1
    Detach UE-1
    Verify UE-1 Detached Successfully

TC06 Detach not attached UE
    Detach UE-1 Should Fail With UE Not Found

# TC07 Stop traffic on specific bearer
#     Attach UE-1
#     <ptrojan Task 3: Start Traffic UE-1 Bearer-9>
#     Stop Traffic UE-1 Bearer-9
#     Verify Traffic Stopped UE-1 Bearer-9

# TC08 Stop all traffic for UE
#     Attach UE-1
#     <ptrojan Task 3: Start Traffic UE-1 Bearer-9>
#     Stop All Traffic UE-1

TC09 Stop traffic on non-existent bearer
    Attach UE-1
    Stop Traffic UE-1 Bearer-3 Should Fail With Bearer Not Found

TC10 Add bearer successfully
    Attach UE-1
    Add Bearer-1 To UE-1
    Verify UE-1 Has Bearer-1

TC11 Add bearer out of range
    Attach UE-1
    Add Bearer-0 To UE-1 Should Fail With Out Of Range
    Add Bearer-10 To UE-1 Should Fail With Out Of Range

TC12 Add already existing bearer
    Attach UE-1
    Add Bearer-1 To UE-1
    Add Bearer-1 To UE-1 Should Fail With Already Added

TC13 Start traffic successfully
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-1000
    Verify Traffic Started UE-1 Bearer-9 Speed-1000

TC14 Start traffic with out of range speed
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-0 Should Fail With Out Of Range
    Start Traffic UE-1 Bearer-9 Speed-100001 Should Fail With Out Of Range

TC15 Start traffic on non-existent bearer
    Attach UE-1
    Start Traffic UE-1 Bearer-3 Should Fail With Bearer Not Found

TC16 Get connected bearers successfully
    Attach UE-1
    Get Connected Bearers For UE-1
    Verify Connected Bearers Contain Bearer-9

TC17 Get connected bearers for non-existent UE
    Get Connected Bearers For UE-1 Should Fail With UE Not Found
