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

TC07 Stop traffic on specific bearer
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-1000
    Stop Traffic UE-1 Bearer-9
    Verify Traffic Stopped UE-1 Bearer-9

TC08 Stop all traffic for UE
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-1000
    Stop All Traffic UE-1

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

# BUG: spec defines max 100 Mbps DL transfer limit, but API accepts any value.
# StartTrafficRequest schema has no min/max on kbps/Mbps/bps fields and
# application-level validation is missing. 100001 kbps (100.001 Mbps) returns
# 200 traffic_started instead of an error.
TC14 Start traffic with out of range speed
    Attach UE-1
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

TC18 Get bearer transfer stats with no traffic
    [Documentation]    Task 4: bearer throughput is zero before traffic starts.
    Attach UE-1
    Get Bearer Transfer Stats For UE-1 Bearer-9
    Verify Bearer Transfer Stats Are Zero

TC19 Get bearer transfer after starting traffic
    [Documentation]    Task 4: single bearer stats; default unit kbps.
    Attach UE-1
    Start Traffic For Transfer Check UE-1 Bearer-9 Kbps-1000
    Get Bearer Transfer Stats For UE-1 Bearer-9
    Verify Bearer Transfer Stats Show Active Traffic
    Verify Bearer Target Speed Is 1000 Kbps

TC20 Get aggregated transfer stats with no traffic
    [Documentation]    Task 4: UE-level aggregate is zero without active bearers.
    Attach UE-1
    Get Aggregated Transfer Stats For UE-1
    Verify Aggregated Transfer Is Zero

TC21 Get aggregated transfer with one active bearer
    [Documentation]    Task 4: aggregate shows one bearer with traffic.
    Attach UE-1
    Start Traffic For Transfer Check UE-1 Bearer-9 Kbps-1000
    Get Aggregated Transfer Stats For UE-1
    Verify Aggregated Bearer Count Is 1
    Verify Aggregated Total Throughput Is Non Zero

TC22 Get aggregated transfer with multiple bearers
    [Documentation]    Task 4: aggregate counts bearers with active traffic.
    Attach UE-1
    Add Bearer-1 To UE-1
    Start Traffic For Transfer Check UE-1 Bearer-9 Kbps-1000
    Start Traffic For Transfer Check UE-1 Bearer-1 Kbps-500
    Get Aggregated Transfer Stats For UE-1
    Verify Aggregated Bearer Count Is 2
    Verify Aggregated Total Throughput Is Non Zero

TC23 Get aggregated transfer details per bearer
    [Documentation]    Task 4: include_details lists per-bearer throughput.
    Attach UE-1
    Add Bearer-1 To UE-1
    Start Traffic For Transfer Check UE-1 Bearer-9 Kbps-1000
    Start Traffic For Transfer Check UE-1 Bearer-1 Kbps-500
    Get Aggregated Transfer Stats For UE-1 With Details
    Verify Aggregated Details Contain Bearer-9 For UE-1
    Verify Aggregated Details Contain Bearer-1 For UE-1
    Verify Aggregated Total Matches Details Sum For UE-1

TC24 Get aggregated transfer for non-existent UE
    [Documentation]    Task 4: aggregate requires attached UE.
    Get Aggregated Transfer Stats For UE-1 Should Fail With UE Not Found

TC25 Get global transfer stats
    [Documentation]    Task 4: global stats across all attached UEs.
    Attach UE-1
    Start Traffic For Transfer Check UE-1 Bearer-9 Kbps-1000
    Get Global Transfer Stats
    Verify Global Transfer Stats Show Activity

TC26 Delete dedicated bearer successfully
    [Documentation]    Task 8: remove dedicated bearer for UE.
    Attach UE-1
    Add Bearer-1 To UE-1
    Delete Bearer-1 From UE-1
    Verify Bearer-1 Delete Response For UE-1
    Verify Bearer-1 Deleted From UE-1

TC27 Delete bearer removes it from UE bearer list
    [Documentation]    Task 8: deleted bearer no longer returned by GET UE.
    Attach UE-1
    Add Bearer-1 To UE-1
    Delete Bearer-1 From UE-1
    Verify Bearer-1 Deleted From UE-1

TC28 Cannot delete default bearer
    [Documentation]    Task 8: default bearer 9 cannot be removed.
    Attach UE-1
    Delete Bearer-9 From UE-1 Should Fail With Cannot Remove Default Bearer

TC29 Delete bearer out of range
    [Documentation]    Task 8: bearer ID outside 1-9 returns error.
    Attach UE-1
    Delete Bearer-0 From UE-1 Should Fail With Bearer Not Found
    Delete Bearer-10 From UE-1 Should Fail With Bearer Not Found

TC30 Delete inactive bearer not on UE
    [Documentation]    Task 8: bearer not added to UE cannot be deleted.
    Attach UE-1
    Delete Bearer-3 From UE-1 Should Fail With Bearer Not Found

TC31 Delete bearer twice fails
    [Documentation]    Task 8: second delete returns bearer not found.
    Attach UE-1
    Add Bearer-1 To UE-1
    Delete Bearer-1 From UE-1
    Delete Bearer-1 From UE-1 Should Fail With Bearer Not Found

TC32 Delete bearer when UE not found
    [Documentation]    Task 8: delete requires attached UE.
    Delete Bearer-1 From UE-1 Should Fail With UE Not Found

# BUG: spec defines UE ID range as 0-100 (inclusive), but API schema enforces min=1.
# UE ID 0 is rejected with 422 instead of being accepted.
TC33 UE ID 0 should be valid per spec range 0-100
    Attach UE-0
    Verify UE-0 Attached Successfully

# BUG: negative throughput values are not validated. All units (Mbps, kbps, bps)
# accept negative numbers — e.g. kbps=-1 returns 200 traffic_started with
# target_bps=-1000. StartTrafficRequest schema has no minimum constraint on
# throughput fields.
TC34 Negative speed should be rejected
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed--1 Should Fail With Out Of Range

# BUG: GET /ues/{ue_id}/bearers/{bearer_id}/traffic returns 200 with zero data for
# a bearer that was never added to the UE. DELETE on the same bearer correctly
# returns 400 "Bearer not found" — inconsistency within the same endpoint.
TC35 GET traffic stats for non-existent bearer should return 400 not 200
    Attach UE-1
    Get Traffic Stats UE-1 Bearer-5 Should Fail With Bearer Not Found

# BUG: spec requires optional 'unit' parameter for traffic stats
# API ignores the parameter entirely — GET with ?unit=kbps still returns
# raw bps values. For 1000 kbps traffic, target_bps should be 1000 (kbps)
# but is 1000000 (bps).
TC36 Traffic stats unit parameter should affect returned values
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-1000
    Get Traffic Stats UE-1 Bearer-9 With Unit-kbps
    Should Be Equal As Integers  ${TRAFFIC_STATS_RESPONSE}[target_bps]  ${1000}
