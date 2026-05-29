*** Settings ***
Resource    session.robot


*** Keywords ***

Start Traffic UE-${ue_id} Bearer-${bearer_id} Speed-${speed_kbps}
    ${speed}=     Convert To Integer  ${speed_kbps}
    ${body}=      Create Dictionary   protocol=tcp  kbps=${speed}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  json=${body}
    Status Should Be  200  ${response}
    Set Test Variable    ${START_TRAFFIC_RESPONSE}    ${response.json()}


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


Stop Traffic UE-${ue_id} Bearer-${bearer_id}
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic
    Status Should Be  200  ${response}
    Set Test Variable    ${STOP_TRAFFIC_RESPONSE}    ${response.json()}


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


Start Traffic For Transfer Check UE-${ue_id} Bearer-${bearer_id} Kbps-${kbps}
    ${kbps_int}=  Convert To Integer  ${kbps}
    ${body}=      Create Dictionary   protocol=tcp  kbps=${kbps_int}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  json=${body}
    Status Should Be  200  ${response}
    Sleep  1s


Start Traffic UE-${ue_id} Bearer-${bearer_id} With Raw Kbps-${kbps} Should Fail With Validation Error
    ${body}=      Create Dictionary   protocol=tcp  kbps=${kbps}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  json=${body}  expected_status=any
    Status Should Be  422  ${response}


Start Traffic UE-${ue_id} Bearer-${bearer_id} Kbps-${kbps} Should Fail With UE Throughput Limit
    ${speed}=     Convert To Integer  ${kbps}
    ${body}=      Create Dictionary   protocol=tcp  kbps=${speed}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  json=${body}  expected_status=any
    Status Should Be  400  ${response}


Start Traffic UE-${ue_id} Bearer-${bearer_id} Kbps-${kbps} Without Protocol
    ${speed}=     Convert To Integer  ${kbps}
    ${body}=      Create Dictionary   kbps=${speed}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  json=${body}
    Status Should Be  200  ${response}


Start Uplink Traffic UE-${ue_id} Bearer-${bearer_id} Kbps-${kbps} Should Fail
    ${speed}=     Convert To Integer  ${kbps}
    ${body}=      Create Dictionary   protocol=tcp  kbps=${speed}  direction=UL
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  json=${body}  expected_status=any
    Should Be True    ${response.status_code} in [400, 422]


Stop All Traffic For UE-${ue_id} Through Documented Endpoint
    ${response}=  DELETE  ${BASE_URL}/ues/${ue_id}/traffic  expected_status=any
    Status Should Be  200  ${response}


Start Traffic UE-${ue_id} Bearer-${bearer_id} With Raw Kbps-${kbps} Should Fail Without Server Error
    ${body}=      Create Dictionary   protocol=tcp  kbps=${kbps}
    ${response}=  POST  ${BASE_URL}/ues/${ue_id}/bearers/${bearer_id}/traffic  json=${body}  expected_status=any
    Status Should Be  422  ${response}
