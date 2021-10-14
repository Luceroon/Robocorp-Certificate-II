*** Settings ***
Library    RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive
Library    OperatingSystem
Library    RPA.Robocorp.Vault
Library    RPA.Dialogs


Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.



*** Variables ***
${output}=  ${CURDIR}${/}output${/}

   






*** Keywords ***
Starting dialog
    Add heading    Tell the order.csv file link
    Add text input    name   label=order.csv liNK
    ${link}    Run dialog
    Log    The link is: ${link.name}
    [Return]    ${link.name}

    




Open the robot order website
    ${secret}=    Get secret    Order website URL
    Open Chrome Browser    ${secret}[URL]



Close modal
    Click Button    Yep



Download csv
    [Arguments]    ${link}
    Download    ${link}    overwrite=true



Get orders
    [Arguments]    ${link}
    Download csv    ${link}
     ${orders} =  Read table from CSV    orders.csv
     [Return]  ${orders}
     


Fill the form  
    [Arguments]  ${row}
    Select From List By Value    id:head    ${row}[Head]
    Click Element    id:id-body-${row}[Body]
    Input Text    xpath://input[@placeholder="Enter the part number for the legs"]    ${row}[Legs]
    Input Text    id:address    ${row}[Address]



Preview the robot
    Click Button    id:preview



Submit the order
    Wait Until Keyword Succeeds    5x    0.2   Try Submit
    
    


Try Submit
    Click Button    id:order
    Wait Until Element Is Visible    id:receipt     0.5s
    
    

Store the receipt as a PDF file
    [Arguments]  ${row}
    
    ${pdf}=    Get Element Attribute    id:receipt  outerHTML
    Html To Pdf  ${pdf}  ${output}${/}Receipts${/}receipt${row}.pdf



Take a screenshot of the robot
    [Arguments]  ${row}  
     Wait Until Element Is Visible    id:robot-preview-image
    ${screenshot}=    Capture Element Screenshot    id:robot-preview-image    ${output}Robot${row}.PNG
    


Embed the robot screenshot to the receipt PDF file
    [Arguments]     ${screenshot}    ${pdf}    ${row}
    Open Pdf     ${output}${/}Receipts${/}receipt${row}[Order number].pdf
    ${files}=    Create List  ${output}Robot${row}[Order number].PNG
    Add Files To Pdf  ${files}    ${output}${/}Receipts${/}receipt${row}[Order number].pdf    append=true
    Close Pdf
    


Go to order another robot
     Click Button    id:order-another

    

Create a ZIP file of the receipts
    Archive Folder With Zip    ${output}${/}Receipts    Receipts.zip
    Move File    Receipts.zip    ${output}${/}Receipts_zip
    


Success dialog
    Add icon    Success
    Add heading    Your orders have been processed
    Run dialog    title=Success



*** Tasks ***
Order robots from RobotSpareBin Industries Inc   
    ${link}=    Starting dialog
    Open the robot order website
     ${orders}=        Get orders    ${link}
    FOR    ${row}    IN    @{orders}
     Log    ${row}
     Close modal
     Fill the form   ${row}
     Preview the robot
     Submit the order
     ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
    ${screenshot}=    Take a screenshot of the robot     ${row}[Order number]       
     Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}    ${row}
     Go to order another robot
     END
     Create a ZIP file of the receipts
     Success dialog


