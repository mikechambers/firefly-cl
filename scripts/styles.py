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
from PIL import Image, ImageDraw, ImageFont
from firefly_lib import run_firefly_command, sanitize_filename, style_presets

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

    
def write_label_on_image(image_path, output_dir, label):
    image = Image.open(image_path)
    im = ImageDraw.Draw(image)

    # Define the rectangle dimensions
    # For a 1000x1000 image, and rectangle height of 100 pixels at the bottom
    rect_start = (0, image.height - 50)
    rect_end = (image.width, image.height)

    # Draw a white rectangle at the bottom
    im.rectangle([rect_start, rect_end], fill=(255,255,255))

    try:
        # Attempt to load the custom font
        mf = ImageFont.truetype('Monaco.ttf', 25)
    except IOError:
        # Fallback to the default font if Monaco.ttf is not available
        mf = ImageFont.load_default()
        print("Fallback to the default font")

    text_color = "#333333"

    im.text((1000/2, image.height - 25), label, anchor='mm', fill=text_color, font=mf)

    path = os.path.join(output_dir, f"{label}.jpg")
    image.save(path)


def create_pdf_from_images(folder_path, output_pdf_path):
    # Get all image paths
    image_files = [os.path.join(folder_path, f) for f in os.listdir(folder_path) if f.endswith('.jpg')]
    image_files.sort()  # Ensure the files are sorted alphabetically

    # Ensure there's at least one image
    if not image_files:
        print("No images found in the folder.")
        return

    # Open the first image to create the PDF
    first_image = Image.open(image_files[0]).convert('RGB')
    
    # Convert remaining images to PIL images and append to a list
    other_images = [Image.open(img).convert('RGB') for img in image_files[1:]]
    
    # Save the images as a PDF
    first_image.save(output_pdf_path, save_all=True, append_images=other_images)
    print(f"PDF created successfully: {output_pdf_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate images with random styles using the firefly command.")
    parser.add_argument("--prompt", required=True, help="The prompt for the image generation.")
    parser.add_argument("--output_dir", required=True, help="Directory where images will be saved.")
    
    args = parser.parse_args()

    main(args.prompt, args.output_dir)