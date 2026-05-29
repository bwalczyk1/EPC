*** Settings ***
Resource    ../api/session.robot


*** Keywords ***

Verify Traffic Started UE-${ue_id} Bearer-${bearer_id} Speed-${speed_kbps}
    ${target_bps}=    Evaluate    ${speed_kbps} * 1000
    Should Be Equal              ${START_TRAFFIC_RESPONSE}[status]      traffic_started
    Should Be Equal As Integers  ${START_TRAFFIC_RESPONSE}[ue_id]       ${ue_id}
    Should Be Equal As Integers  ${START_TRAFFIC_RESPONSE}[bearer_id]   ${bearer_id}
    Should Be Equal As Integers  ${START_TRAFFIC_RESPONSE}[target_bps]  ${target_bps}


Verify Traffic Stopped UE-${ue_id} Bearer-${bearer_id}
    Should Be Equal              ${STOP_TRAFFIC_RESPONSE}[status]      traffic_stopped
    Should Be Equal As Integers  ${STOP_TRAFFIC_RESPONSE}[ue_id]       ${ue_id}
    Should Be Equal As Integers  ${STOP_TRAFFIC_RESPONSE}[bearer_id]   ${bearer_id}


Verify Traffic Is Downlink Only
    [Documentation]    Spec: DL only — uplink (tx) should stay zero while download (rx) is active.
    Should Be True    ${BEARER_TRANSFER_STATS}[rx_bps] > 0
    Should Be Equal As Integers    ${BEARER_TRANSFER_STATS}[tx_bps]    0
