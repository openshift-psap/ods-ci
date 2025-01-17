*** Settings ***
Documentation       Collection of keywords to interact with Data Science Pipelines
Resource            ../../../RHOSi.resource
Resource            ../../../ODS.robot
Resource            ../../../Common.robot
Resource            ../../../Page/ODH/ODHDashboard/ODHDashboard.robot
Library             DateTime
Library             ../../../../../libs/DataSciencePipelinesAPI.py


*** Variables ***
${DATA_SCIENCE_PIPELINES_APPLICATION_YAML}=    ods_ci/tests/Resources/Files/data-science-pipelines-sample.yaml
${PIPELINES_IMPORT_BTN_FORM_XP}=    xpath://footer/button[text()="Import pipeline"]
${PIPELINE_NAME_INPUT_XP}=    id:pipeline-name
${PIPELINE_DESC_INPUT_XP}=    id:pipeline-description

*** Keywords ***
Install DataSciencePipelinesApplication CR
    [Documentation]    Install and verifies that DataSciencePipelinesApplication CRD is installed and working
    [Arguments]     ${project}
    Log    ${project}
    Oc Apply    kind=DataSciencePipelinesApplication    src=${DATA_SCIENCE_PIPELINES_APPLICATION_YAML}     namespace=${project}    # robocop: disable:line-too-long
    ${generation_value}    Run    oc get datasciencepipelinesapplications -n ${project} -o json | jq '.items[0].metadata.generation'    # robocop: disable:line-too-long
    Should Be True    ${generation_value} == 1    DataSciencePipelinesApplication created

Fill In Pipeline Import Form
    [Documentation]    Compiles the form to create a pipeline.
    ...                It works when you start server creation from either
    ...                DS Project details page or DS Pipelines page.
    [Arguments]    ${name}    ${filepath}    ${project_title}
    ...            ${description}=${NONE}
    Run Keyword And Continue On Failure    Element Should Be Disabled    ${PIPELINES_IMPORT_BTN_FORM_XP}
    Input Text    ${PIPELINE_NAME_INPUT_XP}    ${name}
    Input Text    ${PIPELINE_DESC_INPUT_XP}    ${description}
    ${rc}    ${pwd}=    Run And Return Rc And Output    echo $PWD
    Choose File    //div[@class="pf-c-file-upload"]//input[@type="file"]    ${pwd}/${filepath}
    Element Should Be Enabled    ${PIPELINES_IMPORT_BTN_FORM_XP}

Fill In Run Creation Form    # robocop: disable
    [Documentation]    Compiles the form to create a pipeline run.
    ...                It works when you start server creation from either
    ...                DS Project details page or DS Pipelines page.
    [Arguments]    ${name}    ${pipeline_name}    ${from_actions}=${TRUE}    ${run_type}=Immediate
    ...            ${trigger_type}=Periodic    ${start_date}=${NONE}    ${start_time}=${NONE}
    ...            ${end_date}=${NONE}    ${end_time}=${NONE}    ${cron_expr}=${NONE}&{model_param}
    Input Text    ${PIPELINE_NAME_INPUT_XP}    ${name}
    Input Text    ${PIPELINE_DESC_INPUT_XP}    ${name}
    Run Keyword And Continue On Failure
    ...    Element Should Be Disabled    ${GENERIC_CREATE_BTN_XP}
    Select Pipeline For The Run    pipeline_name=${pipeline_name}
    Element Should Be Enabled    ${GENERIC_CREATE_BTN_XP}
    # select run_type
    # set options based on run_type
    # change model param if required
    # check selected project
    # insert name
    # insert description
    # select pipeline
    # select run type
    # insert additional params based on run type
    # insert additinal params based on the model

Select Pipeline For The Run
    [Documentation]    Selects the given ${pipeline_name} from the pipeline
    ...                dropdown in the Run creation form.
    [Arguments]    ${pipeline_name}
    Click Element    xpath://section[@id="run-section-pipeline"]//span[text()="Select a pipeline"]/..
    Wait Until Page Contains Element    xpath://ul/li/a[text()="${pipeline_name}"]
    Click Element     xpath://ul/li/a[text()="${pipeline_name}"]

Get Workflow Name From Topology Page
    [Documentation]    Returns the workflow name corresponding to the displayed pipeline.
    ...                The workflow name can be used to retrieve pods, for example
    ${workflow_name}=    Get Text    xpath://div/div[text()="Workflow name"]/following-sibling::div
    RETURN    ${workflow_name}
