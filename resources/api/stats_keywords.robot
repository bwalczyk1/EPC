*** Settings ***
Resource    session.robot


*** Keywords ***

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


Get Aggregated Transfer Stats For UE-${ue_id} Should Fail With UE Not Found
    ${params}=    Create Dictionary  ue_id=${ue_id}
    ${response}=  GET  url=${BASE_URL}/ues/stats  params=${params}  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  UE not found


Get Bearer Transfer Stats For UE-${ue_id} Bearer-${bearer_id} With Unit-${unit}
    ${params}=    Create Dictionary  unit=${unit}
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  params=${params}
    Status Should Be  200  ${response}
    Set Test Variable    ${BEARER_TRANSFER_STATS}    ${response.json()}


Get Deep Traffic Stats UE-${ue_id} Bearer-${bearer_id}
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic
    Status Should Be  200  ${response}
    Set Test Variable    ${DEEP_TRAFFIC_STATS}    ${response.json()}


Get Deep Aggregated Transfer Stats For UE-${ue_id} With Details
    ${params}=    Create Dictionary  ue_id=${ue_id}  include_details=${True}
    ${response}=  GET  url=${BASE_URL}/ues/stats  params=${params}
    Status Should Be  200  ${response}
    Set Test Variable    ${DEEP_AGG_STATS}    ${response.json()}


Get Deep Traffic Stats UE-${ue_id} Bearer-${bearer_id} Should Fail With Bearer Not Found
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  expected_status=any
    Status Should Be  400  ${response}
    ${data}=      Set Variable  ${response.json()}
    Dictionary Should Contain Item  ${data}  detail  Bearer not found


Get Deep Traffic Stats Decimal Bearer Path Should Fail With Validation Error
    ${response}=  GET  ${BASE_URL}/ues/1/bearers/9.0/traffic  expected_status=any
    Status Should Be  422  ${response}


Get Deep Traffic Stats UE-${ue_id} Bearer-${bearer_id} With Unit-${unit} Should Fail With Validation Error
    ${params}=    Create Dictionary  unit=${unit}
    ${response}=  GET  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  params=${params}  expected_status=any
    Status Should Be  422  ${response}
