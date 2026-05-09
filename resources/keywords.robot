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