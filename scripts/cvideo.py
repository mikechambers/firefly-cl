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

#Python3 script that takes a folder of jpgs and converts it to an mp4 videos 
# playing 3 images per second

import argparse
import os
import shutil
from firefly_lib import create_video_from_images

input_dir = None
should_rename = True

def main():
    tmp_dir = os.path.join(input_dir, "videos")
    os.makedirs(tmp_dir, exist_ok=True)

    if should_rename:
        counter = 0
        for filename in os.listdir(input_dir):

            if not filename.lower().endswith('.jpg'):
                continue

            src_file_path = os.path.join(input_dir, filename)

            new_filename = f"{counter}.jpg"

            target_file_path = os.path.join(tmp_dir, new_filename)

            print(src_file_path)
            print(target_file_path)

            shutil.copy2(src_file_path, target_file_path)

            counter += 1

    output = os.path.join(input_dir, "output.mp4")
    create_video_from_images(tmp_dir, output)


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Generate a video from a folder of jpgs.")

    parser.add_argument("--input-dir", dest="input_dir", required=True, help="Directory containing jpgs to covert.")

    parser.add_argument('--rename', dest='should_rename', action='store_true', help='Whether files need to be renamed for ffmpeg.')

    args = parser.parse_args()

    input_dir = args.input_dir
    should_rename = args.should_rename
    print(should_rename)
    main()
    