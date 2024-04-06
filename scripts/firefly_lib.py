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

def run_firefly_command(prompt, output_dir, filename, args=None):
    """Construct and run the firefly command with the selected styles."""
    command = [
        "firefly",
        "--prompt", prompt,
        "--output-dir", output_dir,
        "--filename", filename,
        "--width", "1000",
        "--height", "1000"
    ]

    if args is not None:
        command.extend(args)

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