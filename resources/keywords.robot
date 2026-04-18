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

