*** Settings ***
Resource    ../api/session.robot


*** Keywords ***

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


Verify Deep Traffic Stats Are Zero After Stop
    Should Be Equal              ${DEEP_TRAFFIC_STATS}[protocol]    ${None}
    Should Be Equal              ${DEEP_TRAFFIC_STATS}[target_bps]  ${None}
    Should Be Equal As Integers  ${DEEP_TRAFFIC_STATS}[tx_bps]      0
    Should Be Equal As Integers  ${DEEP_TRAFFIC_STATS}[rx_bps]      0
    Should Be Equal As Numbers   ${DEEP_TRAFFIC_STATS}[duration]    0


Verify Deep Aggregated Transfer Is Zero
    Should Be Equal As Integers  ${DEEP_AGG_STATS}[bearer_count]    0
    Should Be Equal As Integers  ${DEEP_AGG_STATS}[total_tx_bps]    0
    Should Be Equal As Integers  ${DEEP_AGG_STATS}[total_rx_bps]    0
