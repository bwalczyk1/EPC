*** Settings ***
Library    RequestsLibrary

*** Variables ***
${BASE_URL}    http://localhost:8000

*** Keywords ***
Suite Setup EPC Session
    Create Session    epc    ${BASE_URL}    verify=${False}    disable_warnings=1
