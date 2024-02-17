from openai import OpenAI
import textwrap

client = OpenAI()
response2 = client.chat.completions.create(
    model="gpt-4",
    messages=[
        {"role": "system", "content": textwrap.dedent("""\
You are a helpful personal assistant. You should output AppleScript code that will do the task the user asks for.""")},
        {"role": "user", "content": textwrap.dedent("""\
Instructions: Specific task instructions.
---
Command: Write an AppleScript that will find Allan's email address in the Contacts app, search for a file named "tasklist.docx" in the Documents folder, open the file in Microsoft Word, extract its content, and send an email to Allan with the tasklist content.
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
---
Command: User Input Example 2
Code: ```
applescript code 2```
---
Command: the actual input now
Code: """)}
    ]
)
