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
