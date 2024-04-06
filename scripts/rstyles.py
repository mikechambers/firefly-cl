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
import time
from firefly_lib import sanitize_filename, style_presets, run_firefly_command

def run_command(prompt, output_dir, filename, selected_styles, seed=None):

    command = [
        "--style-presets", *selected_styles
    ]

    if seed is not None:
        command += ["--seeds", str(seed)]

    run_firefly_command(prompt, output_dir, filename, options=command)

    

def generate_images(prompt, output_dir, num_images, num_styles_per_image, style_presets, seed):
    os.makedirs(output_dir, exist_ok=True)

    for i in range(1, num_images + 1):
        selected_styles = random.sample(style_presets, num_styles_per_image)

        n = ' '.join(selected_styles)

        n = sanitize_filename(n)
        filename = f"{n}.png"

        run_command(prompt, output_dir, filename, selected_styles, seed)

        time.sleep(10)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate images with random styles using the firefly command.")
    parser.add_argument("--prompt", required=True, help="The prompt for the image generation.")
    parser.add_argument("--output-dir", dest="output_dir", required=True, help="Directory where images will be saved.")
    parser.add_argument("--num-images", dest="num_images", type=int, default=5, help="Number of images to create.")
    parser.add_argument("--num-styles", dest="num_styles", type=int, default=5, help="Number of random styles to combine for each image.")
    parser.add_argument("--seed", type=int, default=None, help="Seed to use to generate image. If not set, random seed will be used")
    
    args = parser.parse_args()

    generate_images(args.prompt, args.output_dir, args.num_images, args.num_styles, style_presets, args.seed)
