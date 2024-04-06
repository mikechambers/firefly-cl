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

# python script that creates an image from a prompt, and then recreates, using
# previous images as a style reference, and then generates a video from the images

import argparse
import os
from firefly_lib import run_firefly_command
import time
import subprocess

def generate_images(prompt, output_dir, num_generations):
    os.makedirs(output_dir, exist_ok=True)

    filename = "0.jpg"
    run_firefly_command(prompt, output_dir, filename)

    referenceImage = os.path.join(output_dir, filename)

    for i in range(num_generations):
        currentFileName = f"{i}.jpg"

        commands = [
            "--reference-image", referenceImage
        ]

        print(f"Generating : {currentFileName}")
        run_firefly_command(prompt, output_dir, currentFileName, options=commands)

        referenceImage = os.path.join(output_dir, currentFileName)

        time.sleep(10)


def create_video(output_dir):

    filepath = f"{output_dir}/firefly_recursive.mp4"

    print(f"Generating video: {filepath}")

    ffmpeg_command = [
        "ffmpeg",
        "-y",  # Overwrite output files without asking
        "-r", "10",  # Frame rate
        "-f", "image2",  # Input format
        "-s", "1000x1000",  # Size of the output video
        "-i", f"{output_dir}/%d.jpg",  # Input file pattern
        "-vcodec", "libx264",  # Output video codec
        "-crf", "25",  # Constant Rate Factor (quality level of the output video)
        "-pix_fmt", "yuv420p",  # Pixel format
        filepath  # Output file
    ]

    # Execute the command
    subprocess.run(ffmpeg_command, check=True)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate images with random styles using the firefly command.")
    parser.add_argument("--prompt", required=True, help="The prompt for the image generation.")
    parser.add_argument("--output-dir", dest="output_dir", required=True, help="Directory where images will be saved.")
    parser.add_argument("--num-generations", dest="num_generations", type=int, default=5, help="Number of images to create.")
    
    args = parser.parse_args()

    generate_images(args.prompt, args.output_dir, args.num_generations)
    create_video(args.output_dir)