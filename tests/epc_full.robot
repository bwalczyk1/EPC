*** Settings ***
Documentation    Smoke tests for EPC Simulator REST API
Resource         ../resources/keywords.robot
Suite Setup      Suite Setup EPC Session
Test Setup       Reset Simulator


*** Test Cases ***
TC01 Attach UE successfully
    [Documentation]    Attach UE and verify successful response.
    [Tags]    smoke    attach    ue
    Attach UE-1
    Verify UE-1 Attached Successfully


TC02 Attach UE with out of range ID
    [Documentation]    Reject UE IDs outside the supported API range.
    [Tags]    smoke    attach    ue    validation
    Attach UE-0 Should Fail With Out Of Range
    Attach UE-101 Should Fail With Out Of Range


TC03 Attach already attached UE
    [Documentation]    Reject attaching the same UE twice.
    [Tags]    smoke    attach    ue    lifecycle
    Attach UE-1
    Attach UE-1 Should Fail With Already Attached


TC04 Verify default bearer after attach
    [Documentation]    Verify that attach creates default bearer 9.
    [Tags]    smoke    attach    bearer
    Attach UE-1
    Verify UE-1 Has Default Bearer


TC05 Detach UE successfully
    [Documentation]    Detach an attached UE successfully.
    [Tags]    smoke    detach    ue
    Attach UE-1
    Detach UE-1
    Verify UE-1 Detached Successfully


TC06 Detach not attached UE
    [Documentation]    Reject detach for a UE that is not attached.
    [Tags]    smoke    detach    ue    validation
    Detach UE-1 Should Fail With UE Not Found


TC07 Stop traffic on specific bearer
    [Documentation]    Stop active traffic on one bearer.
    [Tags]    smoke    traffic    lifecycle
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-1000
    Stop Traffic UE-1 Bearer-9
    Verify Traffic Stopped UE-1 Bearer-9


TC08 Stop all traffic for UE
    [Documentation]    Stop all active traffic for a UE.
    [Tags]    smoke    traffic    lifecycle
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-1000
    Stop All Traffic UE-1


TC09 Stop traffic on non-existent bearer
    [Documentation]    Reject stopping traffic on an unknown bearer.
    [Tags]    smoke    traffic    bearer    validation
    Attach UE-1
    Stop Traffic UE-1 Bearer-3 Should Fail With Bearer Not Found


TC10 Add bearer successfully
    [Documentation]    Add a dedicated bearer to an attached UE.
    [Tags]    smoke    bearer
    Attach UE-1
    Add Bearer-1 To UE-1
    Verify UE-1 Has Bearer-1


TC11 Add bearer out of range
    [Documentation]    Reject bearer IDs outside the supported range.
    [Tags]    smoke    bearer    validation
    Attach UE-1
    Add Bearer-0 To UE-1 Should Fail With Out Of Range
    Add Bearer-10 To UE-1 Should Fail With Out Of Range


TC12 Add already existing bearer
    [Documentation]    Reject adding the same bearer twice.
    [Tags]    smoke    bearer    lifecycle
    Attach UE-1
    Add Bearer-1 To UE-1
    Add Bearer-1 To UE-1 Should Fail With Already Added


TC13 Start traffic successfully
    [Documentation]    Start traffic on an attached UE bearer.
    [Tags]    smoke    traffic
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-1000
    Verify Traffic Started UE-1 Bearer-9 Speed-1000


# BUG: API accepts traffic over the documented 100 Mbps limit.
TC14 Start traffic with out of range speed
    [Documentation]    Reject traffic speed above the documented 100 Mbps limit.
    [Tags]    bug    defect-10    traffic    speed    validation
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-100001 Should Fail With Out Of Range


TC15 Start traffic on non-existent bearer
    [Documentation]    Reject traffic start on a bearer not assigned to the UE.
    [Tags]    smoke    traffic    bearer    validation
    Attach UE-1
    Start Traffic UE-1 Bearer-3 Should Fail With Bearer Not Found


TC16 Get connected bearers successfully
    [Documentation]    Return connected bearers for an attached UE.
    [Tags]    smoke    bearer    query
    Attach UE-1
    Get Connected Bearers For UE-1
    Verify Connected Bearers Contain Bearer-9


TC17 Get connected bearers for non-existent UE
    [Documentation]    Reject bearer query for an unknown UE.
    [Tags]    smoke    bearer    ue    validation
    Get Connected Bearers For UE-1 Should Fail With UE Not Found


TC18 Get bearer transfer stats with no traffic
    [Documentation]    Return zero bearer transfer stats before traffic starts.
    [Tags]    smoke    stats    traffic
    Attach UE-1
    Get Bearer Transfer Stats For UE-1 Bearer-9
    Verify Bearer Transfer Stats Are Zero


TC19 Get bearer transfer after starting traffic
    [Documentation]    Return active bearer transfer stats after traffic starts.
    [Tags]    smoke    stats    traffic
    Attach UE-1
    Start Traffic For Transfer Check UE-1 Bearer-9 Kbps-1000
    Get Bearer Transfer Stats For UE-1 Bearer-9
    Verify Bearer Transfer Stats Show Active Traffic
    Verify Bearer Target Speed Is 1000 Kbps


TC20 Get aggregated transfer stats with no traffic
    [Documentation]    Return zero UE aggregate stats without active traffic.
    [Tags]    smoke    stats    aggregate
    Attach UE-1
    Get Aggregated Transfer Stats For UE-1
    Verify Aggregated Transfer Is Zero


TC21 Get aggregated transfer with one active bearer
    [Documentation]    Aggregate traffic for one active bearer.
    [Tags]    smoke    stats    aggregate
    Attach UE-1
    Start Traffic For Transfer Check UE-1 Bearer-9 Kbps-1000
    Get Aggregated Transfer Stats For UE-1
    Verify Aggregated Bearer Count Is 1
    Verify Aggregated Total Throughput Is Non Zero


TC22 Get aggregated transfer with multiple bearers
    [Documentation]    Aggregate traffic across multiple active bearers.
    [Tags]    smoke    stats    aggregate
    Attach UE-1
    Add Bearer-1 To UE-1
    Start Traffic For Transfer Check UE-1 Bearer-9 Kbps-1000
    Start Traffic For Transfer Check UE-1 Bearer-1 Kbps-500
    Get Aggregated Transfer Stats For UE-1
    Verify Aggregated Bearer Count Is 2
    Verify Aggregated Total Throughput Is Non Zero


TC23 Get aggregated transfer details per bearer
    [Documentation]    Return per-bearer details in UE aggregate stats.
    [Tags]    smoke    stats    aggregate
    Attach UE-1
    Add Bearer-1 To UE-1
    Start Traffic For Transfer Check UE-1 Bearer-9 Kbps-1000
    Start Traffic For Transfer Check UE-1 Bearer-1 Kbps-500
    Get Aggregated Transfer Stats For UE-1 With Details
    Verify Aggregated Details Contain Bearer-9 For UE-1
    Verify Aggregated Details Contain Bearer-1 For UE-1
    Verify Aggregated Total Matches Details Sum For UE-1


TC24 Get aggregated transfer for non-existent UE
    [Documentation]    Reject aggregate stats for an unknown UE.
    [Tags]    smoke    stats    aggregate    validation
    Get Aggregated Transfer Stats For UE-1 Should Fail With UE Not Found


TC25 Get global transfer stats
    [Documentation]    Return global transfer stats across attached UEs.
    [Tags]    smoke    stats    global
    Attach UE-1
    Start Traffic For Transfer Check UE-1 Bearer-9 Kbps-1000
    Get Global Transfer Stats
    Verify Global Transfer Stats Show Activity


TC26 Delete dedicated bearer successfully
    [Documentation]    Delete a dedicated bearer from an attached UE.
    [Tags]    smoke    bearer    delete
    Attach UE-1
    Add Bearer-1 To UE-1
    Delete Bearer-1 From UE-1
    Verify Bearer-1 Delete Response For UE-1
    Verify Bearer-1 Deleted From UE-1


TC27 Delete bearer removes it from UE bearer list
    [Documentation]    Verify a deleted bearer disappears from the UE bearer list.
    [Tags]    smoke    bearer    delete
    Attach UE-1
    Add Bearer-1 To UE-1
    Delete Bearer-1 From UE-1
    Verify Bearer-1 Deleted From UE-1


TC28 Cannot delete default bearer
    [Documentation]    Reject deleting default bearer 9.
    [Tags]    smoke    bearer    delete    validation
    Attach UE-1
    Delete Bearer-9 From UE-1 Should Fail With Cannot Remove Default Bearer


TC29 Delete bearer out of range
    [Documentation]    Reject deletion of bearer IDs outside the supported range.
    [Tags]    smoke    bearer    delete    validation
    Attach UE-1
    Delete Bearer-0 From UE-1 Should Fail With Bearer Not Found
    Delete Bearer-10 From UE-1 Should Fail With Bearer Not Found


TC30 Delete inactive bearer not on UE
    [Documentation]    Reject deleting a bearer that is not assigned to the UE.
    [Tags]    smoke    bearer    delete    validation
    Attach UE-1
    Delete Bearer-3 From UE-1 Should Fail With Bearer Not Found


TC31 Delete bearer twice fails
    [Documentation]    Reject a second delete for an already removed bearer.
    [Tags]    smoke    bearer    delete    lifecycle
    Attach UE-1
    Add Bearer-1 To UE-1
    Delete Bearer-1 From UE-1
    Delete Bearer-1 From UE-1 Should Fail With Bearer Not Found


TC32 Delete bearer when UE not found
    [Documentation]    Reject bearer delete when the UE does not exist.
    [Tags]    smoke    bearer    delete    ue    validation
    Delete Bearer-1 From UE-1 Should Fail With UE Not Found


# BUG: API rejects UE ID 0 although the documentation allows IDs from 0 to 100.
TC33 UE ID range should match documentation
    [Documentation]    Keep UE ID range consistent with documentation.
    [Tags]    bug    defect-20    contract    ue    validation
    Attach UE-0
    Verify UE-0 Attached Successfully


# BUG: UE-level aggregate traffic can exceed the documented 100 Mbps UE limit.
TC34 Aggregate UE throughput should be capped at 100 Mbps
    [Documentation]    Reject aggregate UE throughput above 100 Mbps.
    [Tags]    bug    defect-10    traffic    speed    aggregate
    Attach UE-1
    Add Bearer-1 To UE-1
    Start Traffic UE-1 Bearer-9 Speed-60000
    Start Traffic UE-1 Bearer-1 Kbps-60000 Should Fail With UE Throughput Limit


# BUG: API does not expose a documented stop-all-traffic operation.
TC35 UE-level stop all traffic endpoint should be available
    [Documentation]    Expose documented UE-level stop-all traffic operation.
    [Tags]    bug    defect-20    contract    traffic    lifecycle
    Attach UE-1
    Add Bearer-1 To UE-1
    Start Traffic UE-1 Bearer-9 Speed-10
    Start Traffic UE-1 Bearer-1 Speed-10
    Stop All Traffic For UE-1 Through Documented Endpoint


# BUG: Start traffic requires an undocumented protocol field.
TC36 Start traffic should not require protocol field
    [Documentation]    Accept documented start traffic payload without protocol.
    [Tags]    bug    defect-20    contract    traffic
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Kbps-1000 Without Protocol


# BUG: Uplink direction is silently ignored and traffic is started.
TC37 Explicit uplink traffic direction should be rejected
    [Documentation]    Reject uplink traffic direction in a downlink-only API.
    [Tags]    bug    defect-20    contract    traffic    direction
    Attach UE-1
    Start Uplink Traffic UE-1 Bearer-9 Kbps-1000 Should Fail


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


TC49 Start traffic twice on same bearer fails
    [Documentation]    Reject starting traffic twice on the same bearer.
    [Tags]    smoke    traffic    lifecycle
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-1000
    Start Traffic UE-1 Bearer-9 Should Fail With Traffic Already Running


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


# BUG: API reports non-zero uplink traffic for a downlink-only transfer.
TC57 Traffic is downlink only
    [Documentation]    Report zero uplink throughput for downlink-only traffic.
    [Tags]    bug    defect-20    traffic    direction    stats
    Attach UE-1
    Start Traffic For Transfer Check UE-1 Bearer-9 Kbps-1000
    Get Bearer Transfer Stats For UE-1 Bearer-9
    Verify Traffic Is Downlink Only


# BUG: API coerces a string UE ID instead of rejecting it.
TC58 Attach UE with string ID should be rejected
    [Documentation]    Reject string UE IDs in request body.
    [Tags]    bug    defect-50    ue    id-validation
    Attach UE With Raw ID-1 Should Fail With Validation Error


# BUG: API coerces a boolean UE ID instead of rejecting it.
TC59 Attach UE with boolean ID should be rejected
    [Documentation]    Reject boolean UE IDs in request body.
    [Tags]    bug    defect-50    ue    id-validation
    Attach UE With Boolean ID Should Fail With Validation Error


# BUG: API coerces a string bearer ID instead of rejecting it.
TC60 Add bearer with string ID should be rejected
    [Documentation]    Reject string bearer IDs in request body.
    [Tags]    bug    defect-50    bearer    id-validation
    Attach UE-1
    Add Bearer With Raw ID-1 To UE-1 Should Fail With Validation Error


# BUG: API coerces a boolean bearer ID instead of rejecting it.
TC61 Add bearer with boolean ID should be rejected
    [Documentation]    Reject boolean bearer IDs in request body.
    [Tags]    bug    defect-50    bearer    id-validation
    Attach UE-1
    Add Bearer With Boolean ID To UE-1 Should Fail With Validation Error


# BUG: Decimal UE path parameter is coerced to an integer UE ID.
TC62 Decimal UE path parameter should be rejected
    [Documentation]    Reject decimal UE identifiers in path parameters.
    [Tags]    bug    defect-50    ue    id-validation
    Attach UE-1
    Get Deep UE Decimal Path Should Fail With Validation Error


# BUG: Decimal bearer path parameter is coerced to an integer bearer ID.
TC63 Decimal bearer path parameter should be rejected
    [Documentation]    Reject decimal bearer identifiers in path parameters.
    [Tags]    bug    defect-50    bearer    id-validation
    Attach UE-1
    Get Deep Traffic Stats Decimal Bearer Path Should Fail With Validation Error
