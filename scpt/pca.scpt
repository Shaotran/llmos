-- Install required Python packages
do shell script "pip3 install numpy matplotlib scikit-learn python-pptx"

set pythonScript to "import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
from sklearn.datasets import load_iris
from pptx import Presentation
from pptx.util import Inches

# Load the Iris dataset
iris = load_iris()
X = iris.data
y = iris.target

# PCA transformation
pca = PCA(n_components=2)
X_r = pca.fit_transform(X)

# Plotting the PCA
plt.figure()
colors = ['navy', 'turquoise', 'darkorange']
lw = 2
target_names = iris.target_names

for color, i, target_name in zip(colors, [0, 1, 2], target_names):
    plt.scatter(X_r[y == i, 0], X_r[y == i, 1], color=color, alpha=.8, lw=lw,
                label=target_name)
plt.legend(loc='best', shadow=False, scatterpoints=1)
plt.title('PCA of IRIS dataset')
plt.savefig('iris_pca.png')

plt.show(block=False)
plt.pause(5)  # Pause for 5 seconds before closing the plot
plt.close()

prs = Presentation()
slide_layout = prs.slide_layouts[5]  # Choosing a blank layout for the slide
slide = prs.slides.add_slide(slide_layout)

# Add the PCA plot to the slide
img_path = 'iris_pca.png'
left = Inches(1)
top = Inches(1)
pic = slide.shapes.add_picture(img_path, left, top, width=Inches(5.5))

# Add analysis comments
txBox = slide.shapes.add_textbox(Inches(0.5), Inches(5), Inches(9), Inches(2))
tf = txBox.text_frame
tf.text = 'PCA Analysis Comments:\\n1. The first two principal components capture most of the variance in the data.\\n2. There is clear separation between the species based on these components.'

# Save the presentation
prs.save('PCA_Analysis_Presentation.pptx')"

-- Define the path for the folder and the new Python file name
set folderPath to "Macintosh HD:Users:robertsheng:Desktop:THTest"
set fileName to "iris_pca.py"
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

delay 2

-- Define the path for the generated PowerPoint presentation
set pptxPath to POSIX path of ((path to desktop as text) & "THTest:PCA_Analysis_Presentation.pptx")

-- Open the PowerPoint presentation with Microsoft PowerPoint
tell application "Microsoft PowerPoint"
    open pptxPath
    activate
end tell

