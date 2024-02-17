//
//  prompt.swift
//  llmos
//
//  Created by Ethan Shaotran on 2/17/24.
//

import Foundation

struct Prompt {
    static let promptStr = """
    Instructions: Given a human command, can you write the step by step process to execute this command through applescript, then provide the applescript code. Rules:\n- Whenever a name is used, make sure to search through contacts to find the correct phone number or email in the apple script.\n- When opening new applications, set a delay for 3 seconds.\n- Never use curly quotes, and always use straight quotes.
    ###
    Command: Email Allan the tasks in my tasklist document.
    Process: Write applescript code to look through my contacts to find Allan's email, search my Documents directory to find a tasklist.docx document, then read the contents of the tasklist document and send it in an email to Allan's email.
    Code:
    ```
    -- Step 1: Find Allan's email address
    log "Starting: Finding Allan's email address"
    tell application "Contacts"
        set allans to people whose name contains "Allan"
        if (count of allans) is greater than 0 then
            set allan to item 1 of allans -- Assuming the first Allan is the correct one
            set allanEmail to value of first email of allan
            log "Allan's email found: " & allanEmail
        else
            log "Allan not found in contacts."
            display dialog "Allan not found in contacts."
            return
        end if
    end tell

    -- Step 2: Use Finder to search for the tasklist.docx file in the Documents folder
    log "Searching for tasklist.docx in the Documents folder"
    set tasklistPath to ""
    tell application "Finder"
        set documentsFolder to path to documents folder
        set tasklistFiles to (files of entire contents of documentsFolder whose name is "tasklist.docx")
        if (count of tasklistFiles) > 0 then
            set tasklistFile to item 1 of tasklistFiles -- Assuming the first found file is the one we want
            set tasklistPath to tasklistFile as text
            log "tasklist.docx found at: " & tasklistPath
        else
            log "tasklist.docx not found in the Documents folder."
            display dialog "tasklist.docx not found in the Documents folder."
            return
        end if
    end tell


    -- Step 3: Open the tasklist.docx in Microsoft Word and get its content
    log "Opening tasklist.docx in Word"
    set tasklistContent to ""
    if tasklistPath is not "" then
        tell application "Microsoft Word"
            open file tasklistPath
            set tasklistContent to content of text object of active document
            log "Extracted content from tasklist.docx"
            close active document saving no
        end tell
    end if

    -- Step 4: Send an email to Allan with the tasklist content
    log "Preparing to send email to Allan"
    tell application "Mail"
        set newMessage to make new outgoing message with properties {subject:"Tasklist", content:tasklistContent, visible:true}
        tell newMessage
            make new to recipient at end of to recipients with properties {address:allanEmail}
        end tell
        -- Uncomment the line below to automatically send the email
        log "Email prepared for Allan, ready to send."
        activate
        display dialog "Do you want to send the email?" buttons {"Cancel", "Send"} default button "Send"
        set userResponse to the button returned of the result
        
        -- Check the user's response
        if userResponse is "Send" then
            -- User confirmed, send the email
            send newMessage
            log "Email sent to Allan."
        else
            -- User canceled, do not send the email
            log "Email sending canceled."
        end if

    end tell
    ```
    ###
    Command: Can you analyze my tv marketing dataset using linear regression?
    Process: Using apple script look through my Documents folder for a dataset with the name tv marketing, probably tvmarketing.csv or a name similar, then in the documents folder,
    create a python script to analyze the dataset using a simple linear regression, show the plot briefly, then open Microsoft PowerPoint and place the plot in the powerpoint,
    add the r squared value under the graph, finally save the powerpoint.
    Code:
    ```
    -- Install required Python packages
    do shell script "pip3 install pandas numpy matplotlib scikit-learn python-pptx"

    -- Search for tvmarketing.csv in the Documents folder
    log "Searching for tvmarketing.csv in the Documents folder"
    set csvPath to ""
    tell application "Finder"
        set documentsFolder to path to documents folder as alias
        set csvFiles to (files of documentsFolder whose name is "tvmarketing.csv")
        if (count of csvFiles) > 0 then
            set csvFile to item 1 of csvFiles -- Assuming the first found file is the one we want
            set csvPath to POSIX path of (csvFile as text)
            log "tvmarketing.csv found at: " & csvPath
        else
            log "tvmarketing.csv not found in the Documents folder."
            display dialog "tvmarketing.csv not found in the Documents folder."
            return
        end if
    end tell

    -- Set the Python script, incorporating the found csvPath
    set pythonScript to "import pandas as pd
    import numpy as np
    import matplotlib.pyplot as plt
    from sklearn.linear_model import LinearRegression
    from sklearn.metrics import r2_score
    from pptx import Presentation
    from pptx.util import Inches
    import os

    # Load the dataset
    data = pd.read_csv('" & csvPath & "')

    # Prepare the data
    X = data[['TV']].values
    y = data['Sales'].values

    # Create a linear regression model
    model = LinearRegression()
    model.fit(X, y)

    # Make predictions
    predictions = model.predict(X)

    # Calculate R-squared value
    r_squared = r2_score(y, predictions)

    # Plotting the actual points and the line of best fit
    plt.scatter(X, y, color='blue', label='Actual Data')
    plt.plot(X, predictions, color='red', linewidth=2, label='Line of Best Fit')
    plt.title('TV Marketing vs. Sales')
    plt.xlabel('TV Marketing Budget')
    plt.ylabel('Sales')
    plt.legend()
    plt.savefig('linear_regression_plot.png')
    plt.show(block=False)
    plt.pause(5)
    plt.close()

    # Create a PowerPoint presentation
    prs = Presentation()
    slide_layout = prs.slide_layouts[5]  # Choosing a blank layout for a slide
    slide = prs.slides.add_slide(slide_layout)

    # Add the plot to the slide
    img_path = 'linear_regression_plot.png'
    left = Inches(1)
    top = Inches(1)
    pic = slide.shapes.add_picture(img_path, left, top, width=Inches(5.5))

    # Add regression statistics
    txBox = slide.shapes.add_textbox(Inches(0.5), Inches(5), Inches(9), Inches(2))
    tf = txBox.text_frame
    tf.text = 'Regression Statistics:\\nR-squared: {:.2f}'.format(r_squared)

    # Save the presentation
    prs.save('Linear_Regression_Analysis_Presentation.pptx')"

    -- Define the path for the folder and the new Python file name
    set folderPath to (path to documents folder) as text
    set fileName to "linear_regression_analysis.py"
    set filePath to folderPath & fileName

    -- Write the Python script to the file
    set fileRef to open for access filePath with write permission
    write pythonScript to fileRef
    close access fileRef

    -- Execute the Python script using the folderPath variable
    set posixFolderPath to POSIX path of folderPath
    do shell script "cd '" & posixFolderPath & "' && python3 ./" & fileName

    -- Open the generated PowerPoint presentation with Microsoft PowerPoint
    set pptxPath to posixFolderPath & "Linear_Regression_Analysis_Presentation.pptx"
    tell application "Microsoft PowerPoint"
        open pptxPath
        activate
    end tell
    ```
    ###
    Command:
    """
}
