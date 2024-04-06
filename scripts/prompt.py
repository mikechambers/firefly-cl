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

# Python3 script that takes a prompt and generates the specified number of variations
# Images and a PDF are created with the information necessary to recreate the images.

import argparse
import os
from firefly_lib import sanitize_filename, run_firefly_command, write_label_on_image, create_pdf_from_images
import time
import json


height = 1000
width = 1000

#add style presets here
#style_presets = ["photo", "art", "graphic", "bw"]
style_presets = []

def generate_images(prompt, output_dir, num_generations):
    # Ensure the output directory exists
    os.makedirs(output_dir, exist_ok=True)

    label_dir = os.path.join(output_dir, "labeled")
    os.makedirs(label_dir, exist_ok=True)

    commands = [
        "--write-settings"
    ]

    if style_presets:
        commands.append("--style-presets")
        for style in style_presets:
            commands.append(style)

    for i in range(num_generations):
        filename = f"{i}.jpg"

        run_firefly_command(prompt, output_dir, filename, height=height, width=width, args=commands)

        path = os.path.join(output_dir, filename)

        json_path = os.path.join(output_dir, f"{filename}.json")

        with open(json_path, 'r') as file:
            data = json.load(file)

            # Access the seed value
            seed = data['seed']
            write_label_on_image(path, label_dir, f"{seed}")

            print(f"{filename} generated with seed : {seed}")

        time.sleep(10)

    pdf_name = sanitize_filename(prompt)
    pdf_path = os.path.join(output_dir, f"{pdf_name}.pdf")
    create_pdf_from_images(label_dir, pdf_path)

if __name__ == "__main__":
    # Initialize the argument parser
    parser = argparse.ArgumentParser(description="Generate images based on prompts using the firefly command.")
    
    # Add named command-line arguments
    parser.add_argument("--prompt", type=str, required=True, help="The prompt to use for generating an image.")
    parser.add_argument("--output_dir", type=str, required=True, help="The directory where the generated image will be saved.")

    parser.add_argument("--num_generations", type=int, default=5, help="Number of images to create.")
    
    # Parse the command-line arguments
    args = parser.parse_args()

    generate_images(args.prompt, args.output_dir, args.num_generations)