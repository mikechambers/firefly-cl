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

# Script that creates a CSV file with data from image setting json files contained
# in a folder


import argparse
import os
import json

input_dir = None
style_count = 10

def main():

    if not os.path.exists(input_dir):
        print("--input-dir does not exists")
        return
    
    rows = []
    for filename in os.listdir(input_dir):
        if not filename.lower().endswith('.json'):
            continue

        json_path = os.path.join(input_dir, filename)

        

        with open(json_path, 'r') as file:
            data = json.load(file)
            seed = data["seed"]
            jpg_name = data["fileName"]
            styles = data["query"]["styles"]["presets"]
            prompt = data["query"]["prompt"]

            styles = sorted(styles, key=str.lower)

            row = {}
            row["seed"] = seed
            row["image"] = jpg_name
            row["prompt"] = prompt

            row["styles"] = styles
            rows.append(row)

    output = "image, seed, prompt,"

    for i in range(style_count):
        output += f"style_{i},"

    output = output[:-1]
    output += "\n"

    for row in rows:
        output += f"{row["image"]},"
        output += f"{row["seed"]},"
        output += f"\"{row["prompt"]}\","

        for i in range(style_count):
            s = ""
            try:
                s = row["styles"][i]
            except IndexError:
                s = ""
            output += f"{s},"

        output = output[:-1]
        output += "\n"


    csv_path = os.path.join(input_dir, "output.csv")
    with open(csv_path, 'w', encoding='utf-8') as file:
        file.write(output)

    print(f"File written to {csv_path}")


        


            





if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        description="Export image and settings to csv file.")

    parser.add_argument("--input-dir", dest="input_dir", required=True, 
                        help="Directory containing images and setting json files to export.")
    

    args = parser.parse_args()

    input_dir = args.input_dir

    main()