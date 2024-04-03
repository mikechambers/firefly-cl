# Copyright (c) 2024 Mike Chambers
# https://github.com/mikechambers/firefly-cl
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# python script that takes a prompt, and then calls ChatGPT to get a number of
# alternatives to that prompts, then generates them all
#
# Requires that OPENAI_API_KEY environment variable be set

import argparse
import os
import requests
import json
import subprocess
import sys
import time

# Initialize the argument parser
parser = argparse.ArgumentParser(description="Generate images based on prompts using the firefly command.")

# Add named command-line arguments
parser.add_argument("--prompt", type=str, required=True, help="The prompt to use for generating an image.")
parser.add_argument("--output_dir", type=str, required=True, help="The directory where the generated image will be saved.")

# Parse the command-line arguments
args = parser.parse_args()

# Retrieve the API key from an environment variable
openai_api_key = os.getenv("OPENAI_API_KEY")
if openai_api_key is None:
    print("Error: OPENAI_API_KEY environment variable is not set.", file=sys.stderr)
    sys.exit(1)

# Ensure the output directory exists
os.makedirs(args.output_dir, exist_ok=True)

model = "gpt-3.5-turbo-0125"
num_prompts = 5

headers = {
    'Content-Type': 'application/json',
    'Authorization': f'Bearer {openai_api_key}'
}

data = {
    "model": model,
    "messages": [
        {
            "role": "system",
            "content": f"you are a generative ai prompt master for Adobe's firefly text to image engine. When given a prompt, you will return {num_prompts} alternatives to the prompt for the user to use to try to get more interesting and exciting results. Return the results as a json object"
        },
        {
            "role": "user",
            "content": args.prompt
        }
    ]
}

response = requests.post('https://api.openai.com/v1/chat/completions', headers=headers, json=data)
response.raise_for_status()

prompts = json.loads(response.json()['choices'][0]['message']['content'])

def call_firefly(prompt, output_dir):
    sanitized_filename = ''.join(char for char in prompt if char.isalnum() or char in " _").replace(' ', '_') + '.jpg'
    firefly_cmd = f"firefly --prompt \"{prompt}\" --output-dir \"{output_dir}\" --filename \"{sanitized_filename}\" --width 1000 --height 1000 --seeds 100001"
    subprocess.run(firefly_cmd, shell=True)

for key, prompt in prompts.items():
    print(f"Processing prompt: {prompt}")
    call_firefly(prompt, args.output_dir)
    time.sleep(10)
