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

# Script that cleans up organed setting JSON files (setting files that dont have a
# corresponding jpg file

import argparse
import os

input_dir = None
delete_files = False

def main():
    if not os.path.exists(input_dir):
        print("--input-dir does not exists")
        return
    

    if not delete_files:
        removed_dir = os.path.join(input_dir, "removed")
        os.makedirs(removed_dir, exist_ok=True)
    
    for filename in os.listdir(input_dir):
        if not filename.lower().endswith('.json'):
            continue

        jpg_filename = filename[:-5]

        jpg_path = os.path.join(input_dir, jpg_filename)
        if not os.path.exists(jpg_path):

            source_path = os.path.join(input_dir, filename)
            if delete_files:
                os.remove(source_path)
            else:
                dest_path = os.path.join(removed_dir, filename)
                os.rename(source_path, dest_path)
        

if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        description="Remove orphaned settings files.")

    parser.add_argument("--input-dir", dest="input_dir", required=True, 
                        help="Directory to remove orphaned settings files.")
    
    parser.add_argument('--delete', dest='delete', 
                        action='store_true', 
                        help='Delete files instead of moving them to another director')

    args = parser.parse_args()

    delete_files = args.delete
    input_dir = args.input_dir

    main()