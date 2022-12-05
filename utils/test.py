# Test post to http://localhost:3700/api/polygon/prompt/6a05187c53c94d0787d5fa11ac4feb39/run with inputs.input of "Hi, can you help me with an idea?"

import requests

url = "http://localhost:3700/api/polygon/prompt/6a05187c53c94d0787d5fa11ac4feb39/run"
payload = dict(
  inputs = dict(
    input = "Hi, I want to build an app for people who want to learn how to code. Can you give me a bullet list of features?"
  ),
  parameters = dict(
    n = 3,
    max_tokens = 100,
    stop = 'User:'
  )
)

r = requests.post(url, json=payload)

# Returns an array of texts

for text in r.json():
  print(text)
