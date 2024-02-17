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
Command: Write an AppleScript that extracts the content of a Word document named test.docx and sends it via email.
Code: 
```
-- Replace with the path to your Word document
set wordDocumentPath to "Macintosh HD:Users:YourUsername:Desktop:test.docx"
-- Replace with the recipient's email address
set recipientAddress to "example@example.com"
-- Replace with the email subject
set emailSubject to "Test"
-- The content of the Word document will be stored in this variable
set documentContent to ""
-- Extract text from the Word document
tell application "Microsoft Word"
-- Open the document
open wordDocumentPath
set theActiveDocument to the active document
-- Extract the text
set documentContent to content of text object of theActiveDocument
-- Close the document without saving
close theActiveDocument saving no
end tell
-- Create and send the email
tell application "Mail"
-- Create a new message
set theMessage to make new outgoing message with properties {subject:emailSubject, content:documentContent, visible:true}
tell theMessage
-- Set the recipient
make new to recipient at end of to recipients with properties {address:recipientAddress}
end tell
-- Send the message
-- Uncomment the next line if you want to send the email automatically
-- send theMessage
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
