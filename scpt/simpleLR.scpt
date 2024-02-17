-- Install required Python packages
do shell script "pip3 install pandas numpy matplotlib scikit-learn"

set pythonScript to "import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression

# Load the dataset
data = pd.read_csv('tvmarketing.csv')

# Prepare the data
X = data[['TV']].values
y = data['Sales'].values

# Create a linear regression model
model = LinearRegression()
model.fit(X, y)

# Make predictions
predictions = model.predict(X)

# Plotting the actual points and the line of best fit
plt.scatter(X, y, color='blue', label='Actual Data')
plt.plot(X, predictions, color='red', linewidth=2, label='Line of Best Fit')
plt.title('TV Marketing vs. Sales')
plt.xlabel('TV Marketing Budget')
plt.ylabel('Sales')
plt.legend()
plt.savefig('linear_regression_plot.png')
plt.show()"

# Define the path for the folder and the new Python file name
set folderPath to "Macintosh HD:Users:robertsheng:Desktop:THTest"
set fileName to "linear_regression.py"
set filePath to folderPath & ":" & fileName

# Use AppleScript to navigate to the folder and create the file
tell application "Finder"
    set targetFolder to folder folderPath
    if not (exists file fileName of targetFolder) then
        make new file at targetFolder with properties {name:fileName}
    end if
end tell

# Write the Python script to the file
set fileRef to open for access file filePath with write permission
write pythonScript to fileRef
do shell script "python3 'linear_regression.py'"
close access fileRef
