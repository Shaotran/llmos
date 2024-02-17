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

-- Step 4: Type and send the message "what's up!"
tell application "System Events"
    keystroke "what's up!"
    delay 1 -- Allow time for typing
    keystroke return -- Send the message
end tell
