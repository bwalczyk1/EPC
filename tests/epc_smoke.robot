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
