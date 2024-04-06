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

# Python3 script that take a prompt and then generates an image for each style
# preset, saving the images, and creating a PDF of all of the images with their
# styles labeled

import argparse
import os
import time
from firefly_lib import run_firefly_command, sanitize_filename, style_presets, write_label_on_image, create_pdf_from_images

def main(prompt, output_dir): 
    os.makedirs(output_dir, exist_ok=True)

    label_dir = os.path.join(output_dir, "labeled")
    os.makedirs(label_dir, exist_ok=True)

    a = style_presets[:2]

    for style in a:
        filename = f"{style}.jpg"

        commands = [
            "--style-presets", style,
            "--seeds", "100001"
        ]

        run_firefly_command(prompt, output_dir, filename, commands)

        path = os.path.join(output_dir, filename)
        write_label_on_image(path, label_dir, style)
        time.sleep(10)

    pdf_name = sanitize_filename(prompt)
    pdf_path = os.path.join(output_dir, f"{pdf_name}.pdf")
    create_pdf_from_images(label_dir, pdf_path)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate images with random styles using the firefly command.")
    parser.add_argument("--prompt", required=True, help="The prompt for the image generation.")
    parser.add_argument("--output_dir", required=True, help="Directory where images will be saved.")
    
    args = parser.parse_args()

    main(args.prompt, args.output_dir)