*** Settings ***
Documentation    Smoke tests for EPC Simulator REST API
Resource         ../resources/keywords.robot
Suite Setup      Suite Setup EPC Session
Test Setup       Reset Simulator


*** Test Cases ***
Attach to UE
    [Documentation]    Docs
    Reset Simulator
