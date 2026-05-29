*** Settings ***
Resource    ../api/session.robot


*** Keywords ***

Verify UE-${ue_id} Has Bearer-${bearer_id}
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}
    Status Should Be  200  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Key  ${data}[bearers]  ${bearer_id}


Verify Connected Bearers Contain Bearer-${bearer_id}
    Dictionary Should Contain Key  ${CONNECTED_BEARERS}  ${bearer_id}


Verify Bearer-${bearer_id} Delete Response For UE-${ue_id}
    Should Be Equal              ${DELETE_BEARER_RESPONSE}[status]     bearer_deleted
    Should Be Equal As Integers  ${DELETE_BEARER_RESPONSE}[ue_id]      ${ue_id}
    Should Be Equal As Integers  ${DELETE_BEARER_RESPONSE}[bearer_id]  ${bearer_id}


Verify Bearer-${bearer_id} Deleted From UE-${ue_id}
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}
    Status Should Be  200  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Not Contain Key  ${data}[bearers]  ${bearer_id}


Verify Bearer-${bearer_id} Active For UE-${ue_id}
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}
    Status Should Be  200  ${response}
    ${data}=      Set Variable  ${response.json()}
    Should Be True    ${data}[bearers][${bearer_id}][active]
