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
from firefly_lib import run_firefly_command, sanitize_filename

def main(prompt, output_dir, num_prompts, generate):

    # Retrieve the API key from an environment variable
    openai_api_key = os.getenv("OPENAI_API_KEY")
    if openai_api_key is None:
        print("Error: OPENAI_API_KEY environment variable is not set.", file=sys.stderr)
        sys.exit(1)

    # Ensure the output directory exists
    os.makedirs(output_dir, exist_ok=True)

    model = "gpt-3.5-turbo-0125"

    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {openai_api_key}'
    }

    data = {
        "model": model,
        "messages": [
            {
                "role": "system",
                "content": f"you are a generative ai prompt master for Adobe's firefly text to image engine. When given a prompt, you will return {num_prompts} alternatives to the prompt for the user to use to try to get more interesting and exciting results. Return the results as valid JSON array of Strings"
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

    for prompt in prompts:

        print(f"{prompt}")

        if not generate:
            continue
        
        filename = f"{sanitize_filename(prompt)}.jpg"

        commands = [
            "--seeds", "100001"
        ]

        run_firefly_command(prompt, output_dir, filename, options=commands)

        time.sleep(10)

if __name__ == "__main__":
    # Initialize the argument parser
    parser = argparse.ArgumentParser(description="Generate images based on prompts using the firefly command.")

    # Add named command-line arguments
    parser.add_argument("--prompt", type=str, required=True, help="The prompt to use for generating an image.")
    parser.add_argument("--output-dir", dest="output_dir", type=str, required=True, help="The directory where the generated image will be saved.")
    parser.add_argument("--num-prompts", dest="num_prompts", type=int, default=5, help="Number of prompts to generate.")

    parser.add_argument('--generate', dest='generate', action='store_true', help='Disable backup.')

    # Parse the command-line arguments
    args = parser.parse_args()
    
    main(args.prompt, args.output_dir, args.num_prompts, args.generate)