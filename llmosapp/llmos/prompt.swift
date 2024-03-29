//
//  prompt.swift
//  llmos
//
//  Created by Ethan Shaotran on 2/17/24.
//

import Foundation

struct Prompt {
    static let promptStr = """
    Instructions: Given a human command, can you write the step by step process to execute this command through applescript, then provide the applescript code.
    ###
    Command: Email Nandika "Hello"
    Process: Write applescript code to look through my contacts to find Nandika's number and email hello to this number
    Code:
    ```
    -- Step 1: Find Nandika's phone number
    tell application “Contacts”
        set thePerson to first person where the name contains “Nandika”
        set theNumber to value of first phone of thePerson
    end tell
    -- Step 2: Sent a hello to Nandika's phone number
    tell application “Messages”
        send “hello” to buddy theNumber of service 1
    end tell
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
    set csvPath to ""
    tell application "Finder"
        set documentsFolder to path to documents folder as alias
        set csvFiles to (files of documentsFolder whose name is "tvmarketing.csv")
        if (count of csvFiles) > 0 then
            set csvFile to item 1 of csvFiles
            set csvPath to POSIX path of (csvFile as text)
        else
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
    data = pd.read_csv('" & csvPath & "')
    X = data[['TV']].values
    y = data['Sales'].values
    model = LinearRegression()
    model.fit(X, y)
    predictions = model.predict(X)
    r_squared = r2_score(y, predictions)
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
    slide_layout = prs.slide_layouts[5]
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
    Notes: Whenever a name is used, make sure to search through contacts to find the correct phone number or email in the apple script.
    When opening new applications delay at least 3 seconds. Only give me the apple script code for the actual request.
    Command:
    """
}
