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

# Python3 script that wraps Real-ESRGAN to scale up directories of Firefly generated jpgs.

import argparse
import os
import subprocess


model_dir = None
input_dir = None
scale_amount  = 2
format = "png"


def main():

    if not os.path.exists(model_dir):
        print("--model-dir does not exist. You must specify the model that contains realesrgan models.")
    
    if not os.path.exists(input_dir):
        print(f"--input_dir does not exist : {input_dir}")
        return
    
    output_dir = os.path.join(input_dir, "scaled")
    os.makedirs(output_dir, exist_ok=True)

    found = False
    for filename in os.listdir(input_dir):
        # Check if the file has a .jpg extension
        if filename.endswith('.jpg'):
            found = True

            input_path = os.path.join(input_dir, filename)

            filename = f"{filename[:-4]}.{format}"
            output_path = os.path.join(output_dir, filename)

            print(f"scaling : {input_path}")
            command = [
                "realesrgan",
                "-i", input_path,
                "-o", output_path,
                "-s", str(scale_amount),
                "-m", model_dir,
                "-f", format
            ]

            # Execute the command
            subprocess.run(command, check=True)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Scale up all jpgs in specified directory")
    parser.add_argument("--input-dir", dest="input_dir", required=True, help="Directory containing jpgs to be scaled.")

    parser.add_argument("--model-dir", dest="model_dir", required=False, default="~/bin/models/", help="Directory containing realesrgan models.")

    parser.add_argument("--format", required=False, default="png", help="Output format. jpg or png")
    parser.add_argument("--scale", required=False, type=int, default=2, help="Scale factor. 2, 3, 4.")
    
    args = parser.parse_args()

    input_dir = os.path.expanduser(args.input_dir)
    scale_amount = args.scale

    if scale_amount > 4:
        print("Invalid scale factor. 2, 3 or 4")

    model_dir = os.path.expanduser(args.model_dir)

    main()