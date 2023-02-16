*** Settings ***
Documentation       A simple web scraper robot. (Certificate level I: Beginners' course)

Library    RPA.Browser.Selenium    auto_close=${False}
Library    RPA.HTTP
Library    RPA.Excel.Files
Library    RPA.PDF

*** Variables ***
${TEMPDIR}    ${OUTPUT_DIR}${/}DEMOROBOT${/}output

*** Tasks ***
To login into application need to export results
    Logging into Application
    Download Excel file
    # Fill Form for one person
    Open Excel File and load Data  
    Collect the results
    Export the table as a PDF
    [Teardown]    Log out Application 

*** Keywords ***
Logging into Application
    Open Available Browser        https://robotsparebinindustries.com/#/
    Input Text                    username    maria
    Input Password                password    thoushallnotpass
    Click Button                  xpath://button[contains(text(),'Log in')]
    Wait Until Element Contains   xPath://span[@class='username']    maria

Download Excel file
     Download    https://robotsparebinindustries.com/SalesData.xlsx    target_file=${TEMPDIR}${/}SalesData.xlsx    overwrite=true


Fill Form for one person
    [Arguments]                ${sales_rep}
    Input Text    firstname    ${sales_rep}[First Name]
    Input Text    lastname     ${sales_rep}[Last Name]
    Select From List By Value    salestarget     ${sales_rep}[Sales Target]
    Input Text    salesresult    ${sales_rep}[Sales]
    Click Button   xpath://button[@type='submit']

Open Excel File and load Data  
    Open Workbook      ${TEMPDIR}${/}SalesData.xlsx
    ${sales_resps}=    Read Worksheet As Table    header=True    
    Close Workbook
    FOR    ${sales_rep}     IN     @{sales_resps}
        Fill Form for one person    ${sales_rep}
    END

Collect the results
    Screenshot    css:div.sales-summary    ${TEMPDIR}${/}Sales_summary.png

Export the table as a PDF
    Wait Until Element Is Visible    id:sales-results
    ${sales_results_html}=    Get Element Attribute    id:sales-results    outerHTML    
    Html To Pdf    ${sales_results_html}    ${TEMPDIR}${/}Sales_results.pdf

Log out Application
    Click Button                 logout
    Close Browser