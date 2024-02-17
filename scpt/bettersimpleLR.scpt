-- Install required Python packages
do shell script "pip3 install pandas numpy matplotlib scikit-learn python-pptx"

-- Find tvmarketing.csv in Downloads
set csvPath to POSIX path of (path to downloads folder) & "tvmarketing.csv"

set pythonScript to "import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score
from pptx import Presentation
from pptx.util import Inches
import os

# Construct the path to the dataset
home_dir = os.path.expanduser('~')
file_path = os.path.join(home_dir, 'Downloads', 'tvmarketing.csv')

# Load the dataset
data = pd.read_csv(file_path)

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
plt.savefig(os.path.join(home_dir, 'Desktop', 'THTest', 'linear_regression_plot.png'))
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
set folderPath to "Macintosh HD:Users:robertsheng:Desktop:THTest"
set fileName to "linear_regression_analysis.py"
set filePath to folderPath & ":" & fileName

-- Use AppleScript to navigate to the folder and create the file
tell application "Finder"
    set targetFolder to folder folderPath
    if not (exists file fileName of targetFolder) then
        make new file at targetFolder with properties {name:fileName}
    end if
end tell

-- Write the Python script to the file
set fileRef to open for access file filePath with write permission
write pythonScript to fileRef
close access fileRef

-- Execute the Python script
do shell script "cd '/Users/robertsheng/Desktop/THTest' && python3 '" & fileName & "'"

-- Define the path for the generated PowerPoint presentation
set pptxPath to POSIX path of ((path to desktop as text) & "THTest:Linear_Regression_Analysis_Presentation.pptx")

-- Open the PowerPoint presentation with Microsoft PowerPoint
tell application "Microsoft PowerPoint"
    open pptxPath
    activate
end tell

