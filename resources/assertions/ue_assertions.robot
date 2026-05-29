*** Settings ***
Resource    ../api/session.robot


*** Keywords ***

Verify UE-${ue_id} Attached Successfully
    Should Be Equal As Integers  ${ATTACH_RESPONSE}[ue_id]  ${ue_id}
    Should Be Equal  ${ATTACH_RESPONSE}[status]  attached


Verify UE-${ue_id} Has Default Bearer
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}
    Status Should Be  200  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Key  ${data}[bearers]  9


Verify UE-${ue_id} Detached Successfully
    Should Be Equal As Integers  ${DETACH_RESPONSE}[ue_id]  ${ue_id}
    Should Be Equal              ${DETACH_RESPONSE}[status]  detached


Verify Deep UE Bearer-${bearer_id} Has No Stale Traffic State
    Should Be Equal              ${DEEP_UE}[bearers][${bearer_id}][protocol]    ${None}
    Should Be Equal              ${DEEP_UE}[bearers][${bearer_id}][target_bps]  ${None}
    Dictionary Should Not Contain Key    ${DEEP_UE}[stats]    ${bearer_id}
