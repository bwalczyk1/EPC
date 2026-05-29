*** Settings ***
Resource    session.robot


*** Keywords ***

Attach UE-${ue_id}
    ${id}=        Convert To Integer  ${ue_id}
    ${body}=      Create Dictionary  ue_id=${id}
    ${response}=  POST  ${BASE_URL}/ues  json=${body}
    Status Should Be  200  ${response}
    Set Test Variable    ${ATTACH_RESPONSE}    ${response.json()}


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


Detach UE-${ue_id}
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}
    Status Should Be  200  ${response}
    Set Test Variable    ${DETACH_RESPONSE}    ${response.json()}


Detach UE-${ue_id} Should Fail With UE Not Found
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  UE not found


# --- Task 3: Start data transfer ---


Get Connected Bearers For UE-${ue_id}
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}
    Status Should Be  200  ${response}
    ${data}=      Set Variable  ${response.json()}
    Set Test Variable    ${CONNECTED_BEARERS}    ${data}[bearers]


Get Connected Bearers For UE-${ue_id} Should Fail With UE Not Found
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  UE not found


# --- Task 4: Check current transfer ---


Attach UE With Raw ID-${ue_id} Should Fail With Validation Error
    ${body}=      Create Dictionary  ue_id=${ue_id}
    ${response}=  POST  ${BASE_URL}/ues  json=${body}  expected_status=any
    Status Should Be  422  ${response}


Attach UE With Boolean ID Should Fail With Validation Error
    ${body}=      Create Dictionary  ue_id=${True}
    ${response}=  POST  ${BASE_URL}/ues  json=${body}  expected_status=any
    Status Should Be  422  ${response}


Detach UE-${ue_id} Should Fail With Active Traffic
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}  expected_status=any
    Status Should Be  400  ${response}


Get Deep UE-${ue_id}
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}
    Status Should Be  200  ${response}
    Set Test Variable    ${DEEP_UE}    ${response.json()}


Get Deep UE Decimal Path Should Fail With Validation Error
    ${response}=  GET  ${BASE_URL}/ues/1.0  expected_status=any
    Status Should Be  422  ${response}
