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

# Takes a prompt and then uses firefly to generate an images applying every single
# possible style preset

import argparse
import os
import subprocess
from firefly_lib import style_presets, run_firefly_command

def generate_image(prompt, output_dir):
    # Ensure the output directory exists
    os.makedirs(output_dir, exist_ok=True)

    # Define the filename for the image
    filename = "all_styles_combined.jpg"

    print("Generating image with all styles combined...")

    style_args = []
    
    for style in style_presets:
        style_args.append("--style-presets")
        style_args.append(style)

    run_firefly_command(prompt, output_dir, filename, options=style_args)

    print("Image with all styles combined has been generated.")

if __name__ == "__main__":
    # Initialize the argument parser
    parser = argparse.ArgumentParser(description="Generate images based on prompts using the firefly command.")
    
    # Add named command-line arguments
    parser.add_argument("--prompt", type=str, required=True, help="The prompt to use for generating an image.")
    parser.add_argument("--output-dir", dest="output_dir", type=str, required=True, help="The directory where the generated image will be saved.")
    
    # Parse the command-line arguments
    args = parser.parse_args()
    
    # Call the main function with parsed arguments
    generate_image(args.prompt, args.output_dir)
