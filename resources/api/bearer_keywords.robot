*** Settings ***
Resource    session.robot


*** Keywords ***

Add Bearer-${bearer_id} To UE-${ue_id}
    ${id}=        Convert To Integer  ${bearer_id}
    ${body}=      Create Dictionary   bearer_id=${id}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers  json=${body}
    Status Should Be  200  ${response}
    Set Test Variable    ${ADD_BEARER_RESPONSE}    ${response.json()}


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


Delete Bearer-${bearer_id} From UE-${ue_id}
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}
    Status Should Be  200  ${response}
    Set Test Variable    ${DELETE_BEARER_RESPONSE}    ${response.json()}


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


Delete Bearer-${bearer_id} From UE-${ue_id} Should Fail With Active Traffic
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}  expected_status=any
    Status Should Be  400  ${response}


Add Bearer With Raw ID-${bearer_id} To UE-${ue_id} Should Fail With Validation Error
    ${body}=      Create Dictionary   bearer_id=${bearer_id}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers  json=${body}  expected_status=any
    Status Should Be  422  ${response}


Add Bearer With Boolean ID To UE-${ue_id} Should Fail With Validation Error
    ${body}=      Create Dictionary   bearer_id=${True}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers  json=${body}  expected_status=any
    Status Should Be  422  ${response}
