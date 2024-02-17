from openai import OpenAI
import textwrap

prompt = ""
with open('prompt.txt', 'r') as file:
    prompt = file.read()

input = "Send an email to Allan"

full_prompt = textwrap.dedent(prompt) + input
print(full_prompt)

client = OpenAI()
client.api_key = "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"

response2 = client.chat.completions.create(
    model="gpt-4",
    messages=[
        {
            "role": "system",
            "content": textwrap.dedent(
                """\
                You are a helpful personal assistant. You should output AppleScript code that will do the task the user asks for."""
            ),
        },
        {
            "role": "user",
            "content": full_prompt,
        },
    ],
)
