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

        run_firefly_command(prompt, output_dir, currentFileName, commands)

        referenceImage = os.path.join(output_dir, currentFileName)

        time.sleep(10)


def create_video(output_dir):
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
        f"{output_dir}/firefly_recursive.mp4"  # Output file
    ]

    # Execute the command
    subprocess.run(ffmpeg_command, check=True)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate images with random styles using the firefly command.")
    parser.add_argument("--prompt", required=True, help="The prompt for the image generation.")
    parser.add_argument("--output_dir", required=True, help="Directory where images will be saved.")
    parser.add_argument("--num_generations", type=int, default=5, help="Number of images to create.")
    
    args = parser.parse_args()

    generate_images(args.prompt, args.output_dir, args.num_generations)
    create_video(args.output_dir)