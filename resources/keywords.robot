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
    ${response}=  POST  http://localhost:8000/ues  json=${body}
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