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


import argparse
import os
import random
import subprocess
import time
from PIL import Image, ImageDraw, ImageFont
from firefly_lib import sanitize_filename, style_presets

def write_label_on_image(image):
    Im = ImageDraw.Draw(image)
    mf = ImageFont.truetype('Monaco.ttf', 25)

    # Add Text to an image
    Im.text((15,image.height - 50), "Lady watching movie with her dog", (255,0,0), font=mf)

    #background color

    # Save the image on which we have added the text
    #image.save("mm.png")
    return image

def run_firefly_command(prompt, output_dir, filename, selected_styles, seed):
    """Construct and run the firefly command with the selected styles."""
    command = [
        "firefly",
        "--prompt", prompt,
        "--output-dir", output_dir,
        "--filename", filename,
        "--width", "1000",
        "--height", "1000",
        "--seeds", "957802221",
        "--style-presets", *selected_styles
    ]

    if seed != -1:
        command += ["--seeds", str(seed)]



    subprocess.run(command, check=True)

def generate_images(prompt, output_dir, num_images, num_styles_per_image, style_presets, seed):
    os.makedirs(output_dir, exist_ok=True)
    #labeled_output_dir = os.path.join(output_dir, "labeled")
    #os.makedirs(labeled_output_dir, exist_ok=True)

    for i in range(1, num_images + 1):
        selected_styles = random.sample(style_presets, num_styles_per_image)

        n = ' '.join(selected_styles)
        print(n)
        n = sanitize_filename(n)
        filename = f"{n}.png"

        run_firefly_command(prompt, output_dir, filename, selected_styles, seed)

        time.sleep(10)
        
        #label_image = create_label_image(", ".join(selected_styles))
        #original_image_path = os.path.join(output_dir, filename)
        #original_image = Image.open(original_image_path).convert("RGBA")
        #original_image = write_label_on_image(original_image)
        #original_image.save(original_image_path)

        #print(f"Generated and labeled image {i} with styles: {', '.join(selected_styles)}.")

    # Instructions for combining labeled images into a single PDF would go here
    # Similar to previous examples, ensuring all images are converted to 'RGB' mode before saving as PDF.

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate images with random styles using the firefly command.")
    parser.add_argument("--prompt", required=True, help="The prompt for the image generation.")
    parser.add_argument("--output_dir", required=True, help="Directory where images will be saved.")
    parser.add_argument("--num_images", type=int, default=5, help="Number of images to create.")
    parser.add_argument("--num_styles", type=int, default=5, help="Number of random styles to combine for each image.")
    parser.add_argument("--seed", type=int, default=-1, help="Seed to use to generate image. If not set, random seed will be used")
    
    args = parser.parse_args()

    generate_images(args.prompt, args.output_dir, args.num_images, args.num_styles, style_presets, args.seed)
