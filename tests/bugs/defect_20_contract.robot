*** Settings ***
Documentation    Bug reproduction tests for EPC Simulator REST API
Resource         ../../resources/keywords.robot
Suite Setup      Suite Setup EPC Session
Test Setup       Reset Simulator


*** Test Cases ***

# BUG: API rejects UE ID 0 although the documentation allows IDs from 0 to 100.
TC33 UE ID range should match documentation
    [Documentation]    Keep UE ID range consistent with documentation.
    [Tags]    bug    defect-20    contract    ue    validation
    Attach UE-0
    Verify UE-0 Attached Successfully


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


# BUG: API reports non-zero uplink traffic for a downlink-only transfer.
TC57 Traffic is downlink only
    [Documentation]    Report zero uplink throughput for downlink-only traffic.
    [Tags]    bug    defect-20    traffic    direction    stats
    Attach UE-1
    Start Traffic For Transfer Check UE-1 Bearer-9 Kbps-1000
    Get Bearer Transfer Stats For UE-1 Bearer-9
    Verify Traffic Is Downlink Only
