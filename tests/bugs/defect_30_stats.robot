*** Settings ***
Documentation    Bug reproduction tests for EPC Simulator REST API
Resource         ../../resources/keywords.robot
Suite Setup      Suite Setup EPC Session
Test Setup       Reset Simulator


*** Test Cases ***

# BUG: API returns traffic stats for a bearer that is not assigned to the UE.
TC43 Traffic stats for unassigned bearer should be rejected
    [Documentation]    Reject traffic stats for a bearer not assigned to the UE.
    [Tags]    bug    defect-30    stats    bearer    validation
    Attach UE-1
    Get Bearer Transfer Stats For UE-1 Bearer-5 Should Fail With Bearer Not Found


# BUG: Traffic stats endpoint accepts out-of-range bearer ID 0.
TC44 Traffic stats for bearer 0 should be rejected
    [Documentation]    Reject traffic stats for bearer ID below the supported range.
    [Tags]    bug    defect-30    stats    bearer    validation
    Attach UE-1
    Get Deep Traffic Stats UE-1 Bearer-0 Should Fail With Bearer Not Found


# BUG: Traffic stats endpoint accepts out-of-range bearer ID 10.
TC45 Traffic stats for bearer 10 should be rejected
    [Documentation]    Reject traffic stats for bearer ID above the supported range.
    [Tags]    bug    defect-30    stats    bearer    validation
    Attach UE-1
    Get Deep Traffic Stats UE-1 Bearer-10 Should Fail With Bearer Not Found


# BUG: API keeps traffic stats available after deleting the bearer.
TC46 Deleted bearer traffic stats should not be available
    [Documentation]    Remove traffic stats access after bearer deletion.
    [Tags]    bug    defect-30    stats    bearer    delete
    Attach UE-1
    Add Bearer-1 To UE-1
    Start Traffic UE-1 Bearer-1 Speed-10
    Delete Bearer-1 From UE-1
    Get Traffic Stats UE-1 Bearer-1 Should Fail With Bearer Not Found


# BUG: Traffic stats unit parameter is ignored.
TC47 Traffic stats unit parameter should affect returned values
    [Documentation]    Apply requested unit conversion in traffic stats.
    [Tags]    bug    defect-30    stats    unit
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-1000
    Get Bearer Transfer Stats For UE-1 Bearer-9 With Unit-kbps
    Should Be Equal As Integers  ${BEARER_TRANSFER_STATS}[target_bps]  ${1000}


# BUG: Invalid unit parameter is silently ignored.
TC48 Traffic stats should reject unsupported unit parameter
    [Documentation]    Reject unsupported unit values in traffic stats query.
    [Tags]    bug    defect-30    stats    unit    validation
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-1000
    Get Deep Traffic Stats UE-1 Bearer-9 With Unit-packets Should Fail With Validation Error


# BUG: Stopped bearer keeps non-zero traffic stats and active traffic metadata.
TC52 Stopping traffic should clear bearer transfer stats
    [Documentation]    Clear bearer traffic stats after stopping traffic.
    [Tags]    bug    defect-30    stats    traffic    state
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-1000
    Stop Traffic UE-1 Bearer-9
    Get Deep Traffic Stats UE-1 Bearer-9
    Verify Deep Traffic Stats Are Zero After Stop


# BUG: Stopped traffic still contributes to UE aggregate stats.
TC53 Stopping traffic should remove bearer from aggregate stats
    [Documentation]    Remove stopped traffic from UE aggregate stats.
    [Tags]    bug    defect-30    stats    aggregate    state
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-1000
    Stop Traffic UE-1 Bearer-9
    Get Deep Aggregated Transfer Stats For UE-1 With Details
    Verify Deep Aggregated Transfer Is Zero


# BUG: GET UE keeps stale traffic config and stats after traffic is stopped.
TC54 Stopping traffic should clear UE display state
    [Documentation]    Clear stale traffic state from the UE view after stop.
    [Tags]    bug    defect-30    stats    ue    state
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-1000
    Stop Traffic UE-1 Bearer-9
    Get Deep UE-1
    Verify Deep UE Bearer-9 Has No Stale Traffic State
