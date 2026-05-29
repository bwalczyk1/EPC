*** Settings ***
Documentation    Bug reproduction tests for EPC Simulator REST API
Resource         ../../resources/keywords.robot
Suite Setup      Suite Setup EPC Session
Test Setup       Reset Simulator


*** Test Cases ***

# BUG: API accepts traffic over the documented 100 Mbps limit.
TC14 Start traffic with out of range speed
    [Documentation]    Reject traffic speed above the documented 100 Mbps limit.
    [Tags]    bug    defect-10    traffic    speed    validation
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-100001 Should Fail With Out Of Range


# BUG: UE-level aggregate traffic can exceed the documented 100 Mbps UE limit.
TC34 Aggregate UE throughput should be capped at 100 Mbps
    [Documentation]    Reject aggregate UE throughput above 100 Mbps.
    [Tags]    bug    defect-10    traffic    speed    aggregate
    Attach UE-1
    Add Bearer-1 To UE-1
    Start Traffic UE-1 Bearer-9 Speed-60000
    Start Traffic UE-1 Bearer-1 Kbps-60000 Should Fail With UE Throughput Limit


# BUG: API accepts negative kbps and starts traffic with a negative target rate.
TC38 Negative traffic speed should be rejected
    [Documentation]    Reject negative traffic speed.
    [Tags]    bug    defect-10    traffic    speed    validation
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed--1 Should Fail With Out Of Range


# BUG: API returns a misleading bearer configuration error for zero throughput.
TC39 Zero traffic speed should be rejected as speed out of range
    [Documentation]    Return a speed validation error for zero throughput.
    [Tags]    bug    defect-10    traffic    speed    validation
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-0 Should Fail With Speed Out Of Range


# BUG: API coerces string kbps values instead of rejecting them.
TC40 String traffic speed should be rejected
    [Documentation]    Reject string values in the numeric kbps field.
    [Tags]    bug    defect-10    traffic    speed    validation
    Attach UE-1
    Start Traffic UE-1 Bearer-9 With Raw Kbps-1000 Should Fail With Validation Error


# BUG: String NaN throughput causes a 500 instead of validation error.
TC41 NaN throughput should be rejected without server error
    [Documentation]    Reject NaN throughput as a client validation error.
    [Tags]    bug    defect-10    traffic    speed    validation
    Attach UE-1
    Start Traffic UE-1 Bearer-9 With Raw Kbps-NaN Should Fail Without Server Error


# BUG: String Infinity throughput causes a 500 instead of validation error.
TC42 Infinite throughput should be rejected without server error
    [Documentation]    Reject infinite throughput as a client validation error.
    [Tags]    bug    defect-10    traffic    speed    validation
    Attach UE-1
    Start Traffic UE-1 Bearer-9 With Raw Kbps-Infinity Should Fail Without Server Error
