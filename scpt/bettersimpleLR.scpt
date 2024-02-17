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
