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


import re
import subprocess
import os
from PIL import Image, ImageDraw, ImageFont

def create_video_from_images(input_dir, filepath, images_per_second = 3, width=2048, height=2048):

    ffmpeg_command = [
        "ffmpeg",
        "-framerate", "1",
        "-r", f"{images_per_second}",  # Frame rate
        "-y",  # Overwrite output files without asking
        "-f", "image2",  # Input format
        "-s", f"{width}x{height}",  # Size of the output video
        "-i", f"{input_dir}/%d.jpg",  # Input file pattern
        "-vcodec", "libx264",  # Output video codec
        "-crf", "25",  # Constant Rate Factor (quality level of the output video)
        "-pix_fmt", "yuv420p",  # Pixel format
        filepath  # Output file
    ]

    # Execute the command
    subprocess.run(ffmpeg_command, check=True)

def write_label_on_image(image_path, output_dir, label):
    image = Image.open(image_path)
    im = ImageDraw.Draw(image)

    # Define the rectangle dimensions
    # rectangle height of 100 pixels at the bottom
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

    im.text((2048/2, image.height - 25), label, anchor='mm', fill=text_color, font=mf)

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

def run_firefly_command(prompt, output_dir, filename, width=2048, height=2048, options=None):
    """Construct and run the firefly command with the selected styles."""
    command = [
        "firefly",
        "--prompt", prompt,
        "--output-dir", output_dir,
        "--filename", filename,
        "--width", f"{width}",
        "--height", f"{height}"
    ]

    if options is not None:
        command.extend(options)

    subprocess.run(command, check=True)

def sanitize_filename(input_string):
    """
    Sanitizes the input string to be safe for use as a file name.
    
    - Replaces spaces with underscores
    - Removes characters not typically allowed in file names
    """
    # Replace spaces with underscores
    sanitized = input_string.replace(' ', '_')
    
    # Remove characters that are not allowed in file names
    sanitized = re.sub(r'[<>:"/\\|?*]', '', sanitized)


    
    return sanitized[:250]

style_presets = [
    "photo", "art", "graphic", "bw",
    "cool_colors", "golden", "monochromatic", "muted_color",
    "pastel_color", "toned_image", "vibrant_colors", "warm_tone",
    "closeup", "knolling", "landscape_photography", "macrophotography",
    "photographed_through_window", "shallow_depth_of_field", "shot_from_above",
    "shot_from_below", "surface_detail", "wide_angle", "beautiful", "bohemian",
    "chaotic", "dais", "divine", "eclectic", "futuristic", "kitschy", "nostalgic",
    "simple", "antique_photo", "bioluminescent", "bokeh", "color_explosion", "dark",
    "faded_image", "fisheye", "gomori_photography", "grainy_film", "iridescent",
    "isometric", "misty", "neon", "otherworldly_depiction", "ultraviolet",
    "underwater", "backlighting", "dramatic_light", "golden_hour", "harsh_light",
    "long-time_exposure", "low_lighting", "multiexposure", "studio_light",
    "surreal_lighting", "3d_patterns", "charcoal", "claymation", "fabric", "fur",
    "guilloche_patterns", "layered_paper", "marble_sculpture", "made_of_metal",
    "origami", "paper_mache", "polka-dot_pattern", "strange_patterns",
    "wood_carving", "yarn", "art_deco", "art_nouveau", "baroque", "bauhaus",
    "constructivism", "cubism", "cyberpunk", "fantasy", "fauvism", "film_noir",
    "glitch_art", "impressionism", "industrialism", "maximalism", "minimalism",
    "modern_art", "modernism", "neo-expressionism", "pointillism", "psychedelic",
    "science_fiction", "steampunk", "surrealism", "synthetism", "synthwave",
    "vaporwave", "acrylic_paint", "bold_lines", "chiaroscuro", "color_shift_art",
    "daguerreotype", "digital_fractal", "doodle_drawing", "double_exposure_portrait",
    "fresco", "geometric_pen", "halftone", "ink", "light_painting", "line_drawing",
    "linocut", "oil_paint", "paint_spattering", "painting", "palette_knife",
    "photo_manipulation", "scribble_texture", "sketch", "splattering",
    "stippling_drawing", "watercolor", "3d", "anime", "cartoon", "cinematic",
    "comic_book", "concept_art", "cyber_matrix", "digital_art", "flat_design",
    "geometric", "glassmorphism", "glitch_graphic", "graffiti", "hyper_realistic",
    "interior_design", "line_gradient", "low_poly", "newspaper_collage",
    "optical_illusion", "pattern_pixel", "pixel_art", "pop_art", "product_photo",
    "psychedelic_background", "psychedelic_wonderland", "scandinavian",
    "splash_images", "stamp", "trompe_loeil", "vector_look", "wireframe"
]