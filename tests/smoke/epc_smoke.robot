*** Settings ***
Documentation    Smoke tests for EPC Simulator REST API
Resource         ../../resources/keywords.robot
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


TC49 Start traffic twice on same bearer fails
    [Documentation]    Reject starting traffic twice on the same bearer.
    [Tags]    smoke    traffic    lifecycle
    Attach UE-1
    Start Traffic UE-1 Bearer-9 Speed-1000
    Start Traffic UE-1 Bearer-9 Should Fail With Traffic Already Running
