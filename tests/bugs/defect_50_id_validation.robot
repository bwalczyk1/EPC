*** Settings ***
Documentation    Bug reproduction tests for EPC Simulator REST API
Resource         ../../resources/keywords.robot
Suite Setup      Suite Setup EPC Session
Test Setup       Reset Simulator


*** Test Cases ***

# BUG: API coerces a string UE ID instead of rejecting it.
TC58 Attach UE with string ID should be rejected
    [Documentation]    Reject string UE IDs in request body.
    [Tags]    bug    defect-50    ue    id-validation
    Attach UE With Raw ID-1 Should Fail With Validation Error


# BUG: API coerces a boolean UE ID instead of rejecting it.
TC59 Attach UE with boolean ID should be rejected
    [Documentation]    Reject boolean UE IDs in request body.
    [Tags]    bug    defect-50    ue    id-validation
    Attach UE With Boolean ID Should Fail With Validation Error


# BUG: API coerces a string bearer ID instead of rejecting it.
TC60 Add bearer with string ID should be rejected
    [Documentation]    Reject string bearer IDs in request body.
    [Tags]    bug    defect-50    bearer    id-validation
    Attach UE-1
    Add Bearer With Raw ID-1 To UE-1 Should Fail With Validation Error


# BUG: API coerces a boolean bearer ID instead of rejecting it.
TC61 Add bearer with boolean ID should be rejected
    [Documentation]    Reject boolean bearer IDs in request body.
    [Tags]    bug    defect-50    bearer    id-validation
    Attach UE-1
    Add Bearer With Boolean ID To UE-1 Should Fail With Validation Error


# BUG: Decimal UE path parameter is coerced to an integer UE ID.
TC62 Decimal UE path parameter should be rejected
    [Documentation]    Reject decimal UE identifiers in path parameters.
    [Tags]    bug    defect-50    ue    id-validation
    Attach UE-1
    Get Deep UE Decimal Path Should Fail With Validation Error


# BUG: Decimal bearer path parameter is coerced to an integer bearer ID.
TC63 Decimal bearer path parameter should be rejected
    [Documentation]    Reject decimal bearer identifiers in path parameters.
    [Tags]    bug    defect-50    bearer    id-validation
    Attach UE-1
    Get Deep Traffic Stats Decimal Bearer Path Should Fail With Validation Error
