from openai import OpenAI
import textwrap

client = OpenAI()
response2 = client.chat.completions.create(
    model="gpt-4",
    messages=[
        {"role": "system", "content": textwrap.dedent("""\
You are a helpful personal assistant. You should output AppleScript code that will do the task the user asks for.""")},
        {"role": "user", "content": textwrap.dedent(f"""\
Instructions: Specific task instructions.
---
Command: User Input Example 1
Code: ```
applescript code 1```
---
Command: User Input Example 2
Code: ```
applescript code 2```
---
Command: the actual input now
Code: """)}
    ]
)
