-- Step 1: Launch Slack
tell application "Slack"
    activate
end tell

delay 5 -- Wait for Slack to activate

-- Step 2: Navigate to the TreeHacks 2024 workspace
-- This step assumes that you can switch to the desired workspace with a keyboard shortcut or that it's already the active workspace.

-- Step 3: Open a direct message with Aarush Aitha
-- Use the Slack shortcut for opening a new message (Cmd + K on Mac) and type the name.
tell application "System Events"
    keystroke "k" using {command down}
    delay 1 -- Wait for the dialog to open
    keystroke "Aarush Aitha" -- Adjust the name as it appears in Slack
    delay 1 -- Wait for Slack to find the user
    keystroke return -- Select the user
    delay 1 -- Wait for the chat window to open
end tell

-- Step 4: Upload and send the tvmarketing.csv file
tell application "System Events"
    keystroke "u" using {command down} -- Open the file upload dialog
    delay 2 -- Wait for the file dialog to open

    -- Navigate to the Documents folder using Go to Folder command (Shift + Cmd + G)
    keystroke "g" using {shift down, command down}
    delay 1 -- Wait for the Go to Folder dialog to open

    -- Type the path to the Documents folder
    keystroke "~/Documents"
    delay 1 -- Allow time for typing
    keystroke return -- Go to the Documents folder
    delay 2 -- Wait for navigation

    -- Now that we're in the Documents folder, type the name of the file
    keystroke "tvmarketing.csv"
    delay 1 -- Allow time for typing
    keystroke return -- Select the file and open it (which will attach it in Slack)
    delay 2 -- Wait for Slack to process the file upload

    -- If needed, add additional steps here to confirm the file upload in Slack
    keystroke return
end tell
