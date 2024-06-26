

import argparse
import os
import glob
import time
import json
from firefly_lib import create_images_from_video, run_firefly_command, call_delay, create_video_from_images

import tempfile
import shutil

input_video = None
prompt = None
output_name = None
working_dir = None

images_per_second = None
content_class = None

styles = None

def main():


    with tempfile.TemporaryDirectory() as tmp_dir:

    #tmp_dir = os.path.join(working_dir, "scratch")
    #os.makedirs(tmp_dir, exist_ok=True)

        prefix = "tmp"
        create_images_from_video(input_video, tmp_dir, prefix, images_per_second)

        file_pattern = os.path.join(tmp_dir, f"{prefix}*.png")
        files = sorted(glob.glob(file_pattern))

        #generated_dir = os.path.join(working_dir, "generated")

        with tempfile.TemporaryDirectory() as generated_dir:
            seed = None
            count = 0
            lastfile = None
            for filename in files:

                commands = []

                if seed is not None:
                    commands += ["--seeds", str(seed)]
                else:
                    commands += ["--write-settings"]

                commands += ["--structure-image", filename]
                commands += ["--structure-strength", "100"]
                commands += ["--content-class", content_class]

                if styles is not None:
                    commands += ["--style-presets"]
                    for s in styles:
                        commands += [s]

                if lastfile is not None:
                    commands += ["--reference-image", lastfile]
                    commands += ["--style-strength", "100"]

                lastfile = filename

                output_file = f"{count}.jpg"
                count = count + 1

                

                try:
                    run_firefly_command(prompt, generated_dir, output_file, options=commands)
                except Exception as e:
                    print("Error calling firefly. Sleeping 20 seconds")
                    time.sleep(20)
                    run_firefly_command(prompt, generated_dir, output_file, options=commands)


                print(f"{count} of {len(files)}")

                if seed is None:
                    #read seed here 0.jpg.json
                    json_path = os.path.join(generated_dir, f"{output_file}.json")
                    with open(json_path, 'r') as file:
                        data = json.load(file)
                        seed = data["seed"]

                time.sleep(call_delay)

            output_filepath = os.path.join(working_dir, output_name)
            create_video_from_images(generated_dir, output_filepath, images_per_second)
    

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Convert a video using Firefly")

    parser.add_argument("--source", dest="input_video", required=True, help="Source Video.")

    parser.add_argument("--prompt", type=str, required=True, help="The prompt to use for generating an image.")

    parser.add_argument("--content-class", dest="content_class", type=str, required=False, default="art", help="The prompt to use for generating an image.")

    parser.add_argument("--output-name", dest="output_name", type=str, required=True, help="The directory where the generated image will be saved.")

    parser.add_argument("--fps", type=int, required=False, default=3, help="Frames per second of final video. Will determine number of FPS to extract from original.")

    parser.add_argument("--styles", nargs='+', type=str, required=False, help="List of styles to apply.")

    args = parser.parse_args()

    input_video = args.input_video

    images_per_second = args.fps
    content_class = args.content_class

    working_dir = os.path.dirname(input_video)

    styles = args.styles
    prompt = args.prompt
    output_name = args.output_name
    main()
