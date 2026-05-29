*** Settings ***
Library    RequestsLibrary
Library    Collections


*** Variables ***
${BASE_URL}    http://localhost:8000

*** Keywords ***
Suite Setup EPC Session
    Create Session    epc    ${BASE_URL}    verify=${False}    disable_warnings=1

Reset Simulator
    ${response}=    POST On Session    epc    /reset
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()}
    Dictionary Should Contain Item    ${data}    status    reset


# --- Task 1: Attach UE ---

Attach UE-${ue_id}
    ${id}=        Convert To Integer  ${ue_id}
    ${body}=      Create Dictionary  ue_id=${id}
    ${response}=  POST  ${BASE_URL}/ues  json=${body}
    Status Should Be  200  ${response}
    Set Test Variable    ${ATTACH_RESPONSE}    ${response.json()}

Verify UE-${ue_id} Attached Successfully
    Should Be Equal As Integers  ${ATTACH_RESPONSE}[ue_id]  ${ue_id}
    Should Be Equal  ${ATTACH_RESPONSE}[status]  attached

Attach UE-${ue_id} Should Fail With Out Of Range
    ${id}=        Convert To Integer  ${ue_id}
    ${body}=      Create Dictionary   ue_id=${id}
    ${response}=  POST  ${BASE_URL}/ues  json=${body}  expected_status=any
    Status Should Be  422  ${response}

Attach UE-${ue_id} Should Fail With Already Attached
    ${id}=        Convert To Integer  ${ue_id}
    ${body}=      Create Dictionary   ue_id=${id}
    ${response}=  POST  ${BASE_URL}/ues  json=${body}  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  UE already attached

Verify UE-${ue_id} Has Default Bearer
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}
    Status Should Be  200  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Key  ${data}[bearers]  9


# --- Task 2: Detach UE ---

Detach UE-${ue_id}
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}
    Status Should Be  200  ${response}
    Set Test Variable    ${DETACH_RESPONSE}    ${response.json()}

Verify UE-${ue_id} Detached Successfully
    Should Be Equal As Integers  ${DETACH_RESPONSE}[ue_id]  ${ue_id}
    Should Be Equal              ${DETACH_RESPONSE}[status]  detached

Detach UE-${ue_id} Should Fail With UE Not Found
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  UE not found


# --- Task 3: Start data transfer ---

Start Traffic UE-${ue_id} Bearer-${bearer_id} Speed-${speed_kbps}
    ${speed}=     Convert To Integer  ${speed_kbps}
    ${body}=      Create Dictionary   protocol=tcp  kbps=${speed}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  json=${body}
    Status Should Be  200  ${response}
    Set Test Variable    ${START_TRAFFIC_RESPONSE}    ${response.json()}

Verify Traffic Started UE-${ue_id} Bearer-${bearer_id} Speed-${speed_kbps}
    ${target_bps}=    Evaluate    ${speed_kbps} * 1000
    Should Be Equal              ${START_TRAFFIC_RESPONSE}[status]      traffic_started
    Should Be Equal As Integers  ${START_TRAFFIC_RESPONSE}[ue_id]       ${ue_id}
    Should Be Equal As Integers  ${START_TRAFFIC_RESPONSE}[bearer_id]   ${bearer_id}
    Should Be Equal As Integers  ${START_TRAFFIC_RESPONSE}[target_bps]  ${target_bps}

Start Traffic UE-${ue_id} Bearer-${bearer_id} Speed-${speed_kbps} Should Fail With Out Of Range
    ${speed}=     Convert To Integer  ${speed_kbps}
    ${body}=      Create Dictionary   protocol=tcp  kbps=${speed}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  json=${body}  expected_status=any
    Status Should Be  400  ${response}

Start Traffic UE-${ue_id} Bearer-${bearer_id} Speed-0 Should Fail With Speed Out Of Range
    ${body}=      Create Dictionary   protocol=tcp  kbps=${0}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  json=${body}  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Should Not Be Equal As Strings  ${data}[detail]  Bearer not configured for traffic

Start Traffic UE-${ue_id} Bearer-${bearer_id} Should Fail With Bearer Not Found
    ${body}=      Create Dictionary   protocol=tcp  kbps=${1000}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  json=${body}  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  Bearer not found

Start Traffic UE-${ue_id} Bearer-${bearer_id} Should Fail With Traffic Already Running
    ${body}=      Create Dictionary   protocol=tcp  kbps=${2000}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  json=${body}  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  Traffic already running


# --- Task 5: Stop data transfer ---

Stop Traffic UE-${ue_id} Bearer-${bearer_id}
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic
    Status Should Be  200  ${response}
    Set Test Variable    ${STOP_TRAFFIC_RESPONSE}    ${response.json()}

Verify Traffic Stopped UE-${ue_id} Bearer-${bearer_id}
    Should Be Equal              ${STOP_TRAFFIC_RESPONSE}[status]      traffic_stopped
    Should Be Equal As Integers  ${STOP_TRAFFIC_RESPONSE}[ue_id]       ${ue_id}
    Should Be Equal As Integers  ${STOP_TRAFFIC_RESPONSE}[bearer_id]   ${bearer_id}

Stop All Traffic UE-${ue_id}
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}
    Status Should Be  200  ${response}
    ${bearers}=   Set Variable  ${response.json()}[bearers]
    FOR    ${bearer_id}    IN    @{bearers}
        ${del_resp}=  DELETE  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic
        Status Should Be  200  ${del_resp}
    END

Stop Traffic UE-${ue_id} Bearer-${bearer_id} Should Fail With Bearer Not Found
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  Bearer not found

Stop Traffic UE-${ue_id} Bearer-${bearer_id} Should Fail With No Active Traffic
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  expected_status=any
    Status Should Be  400  ${response}

Stop Traffic Should Fail With Traffic Not Running
    [Arguments]    ${ue_id}    ${bearer_id}
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  Traffic not running


# --- Task 6: Add bearer to UE ---

Add Bearer-${bearer_id} To UE-${ue_id}
    ${id}=        Convert To Integer  ${bearer_id}
    ${body}=      Create Dictionary   bearer_id=${id}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers  json=${body}
    Status Should Be  200  ${response}
    Set Test Variable    ${ADD_BEARER_RESPONSE}    ${response.json()}

Verify UE-${ue_id} Has Bearer-${bearer_id}
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}
    Status Should Be  200  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Key  ${data}[bearers]  ${bearer_id}

Add Bearer-${bearer_id} To UE-${ue_id} Should Fail With Out Of Range
    ${id}=        Convert To Integer  ${bearer_id}
    ${body}=      Create Dictionary   bearer_id=${id}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers  json=${body}  expected_status=any
    Status Should Be  422  ${response}

Add Bearer-${bearer_id} To UE-${ue_id} Should Fail With Already Added
    ${id}=        Convert To Integer  ${bearer_id}
    ${body}=      Create Dictionary   bearer_id=${id}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers  json=${body}  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  Bearer already exists


# --- Task 7: Check connected bearers ---

Get Connected Bearers For UE-${ue_id}
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}
    Status Should Be  200  ${response}
    ${data}=      Set Variable  ${response.json()}
    Set Test Variable    ${CONNECTED_BEARERS}    ${data}[bearers]

Verify Connected Bearers Contain Bearer-${bearer_id}
    Dictionary Should Contain Key  ${CONNECTED_BEARERS}  ${bearer_id}

Get Connected Bearers For UE-${ue_id} Should Fail With UE Not Found
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  UE not found


# --- Task 4: Check current transfer ---

Start Traffic For Transfer Check UE-${ue_id} Bearer-${bearer_id} Kbps-${kbps}
    ${kbps_int}=  Convert To Integer  ${kbps}
    ${body}=      Create Dictionary   protocol=tcp  kbps=${kbps_int}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  json=${body}
    Status Should Be  200  ${response}
    Sleep  1s

Get Bearer Transfer Stats For UE-${ue_id} Bearer-${bearer_id}
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic
    Status Should Be  200  ${response}
    Set Test Variable    ${BEARER_TRANSFER_STATS}    ${response.json()}

Get Bearer Transfer Stats For UE-${ue_id} Bearer-${bearer_id} Should Fail With Bearer Not Found
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  Bearer not found

Get Traffic Stats UE-${ue_id} Bearer-${bearer_id} Should Fail With Bearer Not Found
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  Bearer not found

Get Aggregated Transfer Stats For UE-${ue_id}
    ${params}=    Create Dictionary  ue_id=${ue_id}
    ${response}=  GET  url=${BASE_URL}/ues/stats  params=${params}
    Status Should Be  200  ${response}
    Set Test Variable    ${AGG_TRANSFER_STATS}    ${response.json()}

Get Aggregated Transfer Stats For UE-${ue_id} With Details
    ${params}=    Create Dictionary  ue_id=${ue_id}  include_details=${True}
    ${response}=  GET  url=${BASE_URL}/ues/stats  params=${params}
    Status Should Be  200  ${response}
    Set Test Variable    ${AGG_TRANSFER_STATS}    ${response.json()}

Get Global Transfer Stats
    ${response}=  GET  url=${BASE_URL}/ues/stats
    Status Should Be  200  ${response}
    Set Test Variable    ${GLOBAL_TRANSFER_STATS}    ${response.json()}

Verify Bearer Transfer Stats Are Zero
    Should Be Equal As Integers  ${BEARER_TRANSFER_STATS}[tx_bps]  0
    Should Be Equal As Integers  ${BEARER_TRANSFER_STATS}[rx_bps]  0
    Should Be Equal              ${BEARER_TRANSFER_STATS}[protocol]  ${None}
    Should Be Equal As Numbers   ${BEARER_TRANSFER_STATS}[duration]  0

Verify Bearer Transfer Stats Show Active Traffic
    Should Not Be Equal As Integers  ${BEARER_TRANSFER_STATS}[tx_bps]  0
    Should Not Be Equal              ${BEARER_TRANSFER_STATS}[protocol]  ${None}
    Should Be True                   ${BEARER_TRANSFER_STATS}[target_bps] > 0

Verify Bearer Target Speed Is ${kbps} Kbps
    ${expected_bps}=  Evaluate  int(${kbps}) * 1000
    Should Be Equal As Integers  ${BEARER_TRANSFER_STATS}[target_bps]  ${expected_bps}

Verify Traffic Is Downlink Only
    [Documentation]    Spec: DL only — uplink (tx) should stay zero while download (rx) is active.
    Should Be True    ${BEARER_TRANSFER_STATS}[rx_bps] > 0
    Should Be Equal As Integers    ${BEARER_TRANSFER_STATS}[tx_bps]    0

Verify Aggregated Transfer Is Zero
    Should Be Equal As Integers  ${AGG_TRANSFER_STATS}[bearer_count]  0
    Should Be Equal As Integers  ${AGG_TRANSFER_STATS}[total_tx_bps]  0
    Should Be Equal As Integers  ${AGG_TRANSFER_STATS}[total_rx_bps]  0

Verify Aggregated Bearer Count Is ${count}
    Should Be Equal As Integers  ${AGG_TRANSFER_STATS}[bearer_count]  ${count}

Verify Aggregated Total Throughput Is Non Zero
    Should Not Be Equal As Integers  ${AGG_TRANSFER_STATS}[total_tx_bps]  0
    Should Not Be Equal As Integers  ${AGG_TRANSFER_STATS}[total_rx_bps]  0

Verify Aggregated Details Contain Bearer-${bearer_id} For UE-${ue_id}
    ${details}=      Set Variable  ${AGG_TRANSFER_STATS}[details]
    ${ue_details}=   Get From Dictionary  ${details}  ${ue_id}
    Dictionary Should Contain Key  ${ue_details}  ${bearer_id}

Verify Aggregated Total Matches Details Sum For UE-${ue_id}
    ${details}=      Set Variable  ${AGG_TRANSFER_STATS}[details]
    ${ue_details}=   Get From Dictionary  ${details}  ${ue_id}
    ${values}=     Get Dictionary Values  ${ue_details}
    ${sum}=        Evaluate  sum(${values})
    ${total}=      Set Variable  ${AGG_TRANSFER_STATS}[total_tx_bps]
    Should Be True  ${total} >= ${sum}

Verify Global Transfer Stats Show Activity
    Should Be True  ${GLOBAL_TRANSFER_STATS}[ue_count] >= 1
    Should Not Be Equal As Integers  ${GLOBAL_TRANSFER_STATS}[total_tx_bps]  0

Get Aggregated Transfer Stats For UE-${ue_id} Should Fail With UE Not Found
    ${params}=    Create Dictionary  ue_id=${ue_id}
    ${response}=  GET  url=${BASE_URL}/ues/stats  params=${params}  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  UE not found


# --- Task 8: Delete bearer from UE ---

Delete Bearer-${bearer_id} From UE-${ue_id}
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}
    Status Should Be  200  ${response}
    Set Test Variable    ${DELETE_BEARER_RESPONSE}    ${response.json()}

Verify Bearer-${bearer_id} Delete Response For UE-${ue_id}
    Should Be Equal              ${DELETE_BEARER_RESPONSE}[status]     bearer_deleted
    Should Be Equal As Integers  ${DELETE_BEARER_RESPONSE}[ue_id]      ${ue_id}
    Should Be Equal As Integers  ${DELETE_BEARER_RESPONSE}[bearer_id]  ${bearer_id}

Verify Bearer-${bearer_id} Deleted From UE-${ue_id}
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}
    Status Should Be  200  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Not Contain Key  ${data}[bearers]  ${bearer_id}

Delete Bearer-${bearer_id} From UE-${ue_id} Should Fail With Bearer Not Found
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  Bearer not found

Delete Bearer-${bearer_id} From UE-${ue_id} Should Fail With Cannot Remove Default Bearer
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  Cannot remove default bearer

Delete Bearer-${bearer_id} From UE-${ue_id} Should Fail With UE Not Found
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  UE not found

Get Bearer Transfer Stats For UE-${ue_id} Bearer-${bearer_id} With Unit-${unit}
    ${params}=    Create Dictionary  unit=${unit}
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  params=${params}
    Status Should Be  200  ${response}
    Set Test Variable    ${BEARER_TRANSFER_STATS}    ${response.json()}

Delete Bearer-${bearer_id} From UE-${ue_id} Should Fail With Active Traffic
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}  expected_status=any
    Status Should Be  400  ${response}

Attach UE With Raw ID-${ue_id} Should Fail With Validation Error
    ${body}=      Create Dictionary  ue_id=${ue_id}
    ${response}=  POST  ${BASE_URL}/ues  json=${body}  expected_status=any
    Status Should Be  422  ${response}

Attach UE With Boolean ID Should Fail With Validation Error
    ${body}=      Create Dictionary  ue_id=${True}
    ${response}=  POST  ${BASE_URL}/ues  json=${body}  expected_status=any
    Status Should Be  422  ${response}

Add Bearer With Raw ID-${bearer_id} To UE-${ue_id} Should Fail With Validation Error
    ${body}=      Create Dictionary   bearer_id=${bearer_id}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers  json=${body}  expected_status=any
    Status Should Be  422  ${response}

Add Bearer With Boolean ID To UE-${ue_id} Should Fail With Validation Error
    ${body}=      Create Dictionary   bearer_id=${True}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers  json=${body}  expected_status=any
    Status Should Be  422  ${response}

Start Traffic UE-${ue_id} Bearer-${bearer_id} With Raw Kbps-${kbps} Should Fail With Validation Error
    ${body}=      Create Dictionary   protocol=tcp  kbps=${kbps}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  json=${body}  expected_status=any
    Status Should Be  422  ${response}

Detach UE-${ue_id} Should Fail With Active Traffic
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}  expected_status=any
    Status Should Be  400  ${response}

Verify Bearer-${bearer_id} Active For UE-${ue_id}
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}
    Status Should Be  200  ${response}
    ${data}=      Set Variable  ${response.json()}
    Should Be True    ${data}[bearers][${bearer_id}][active]
