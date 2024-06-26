# firefly-cl scripts

Collection of Python 3 scripts using the firefly command line app.

[https://github.com/mikechambers/firefly-cl](https://github.com/mikechambers/firefly-cl)

## Scripts

### prompt.py

Python3 script that takes a prompt and generates the specified number of variations

Individual images and a PDF are created with the information necessary to recreate the images.

```
python3 prompt.py --prompt "Big bang universe explosion, supernova blast, made out of colorful powder and dust, super detailed" --num-generations 20 --output-dir ~/tmp/fireflyOutput
```

Requires the Python [Pillow library](https://python-pillow.org/) is installed.

### recursive.py

Python 3 script that recursively generates an image, feeding the previously generated image in as a style reference, and then outputs all of the file and a video.

```
python3 recursive.py --prompt "Big bang universe explosion, supernova blast, made out of colorful powder and dust, super detailed" --output-dir ~/tmp/fireflyOutput --num-generations 20
```

Requires that [ffmpeg](https://ffmpeg.org/) is installed and in path.

### styles.py

Python 3 script that generates one image for each possible style based on the specified prompt. Will create an image for each style, and combine all of them into a pdf.

Requires the Python [Pillow library](https://python-pillow.org/) is installed.

```
python3 styles.py --prompt "Big bang universe explosion, supernova blast, made out of colorful powder and dust, super detailed" --output-dir ~/tmp/fireflyOutput
```

### svideo.py

Python 3 script that takes a video and prompt, and then recreates the video using images generated from Adobe Firefly.

```
python3 svideo.py --source ~/tmp/video/input.mp4 --output-name output.mp4  --prompt "russian guy dancing" --fps 30 --styles cubism isometric
```

Requires that [ffmpeg](https://ffmpeg.org/) is installed and in path.

### rstyles.py

Python 3 script that takes a prompt and randomly combines styles (based on your settings), to create images. Useful for finding unique, interesting style combinations.

Requires the Python [Pillow library](https://python-pillow.org/) is installed.

```
python3 rstyles.py --prompt "Big bang universe explosion, supernova blast, made out of colorful powder and dust, super detailed" --output-dir ~/tmp/fireflyOutput --num-images=20 --num-styles=5
```

### astyles.py

Python3 script that takes a prompt and then generates an image using all possible styles.

```
python3 astyles.py --prompt "Big bang universe explosion, supernova blast, made out of colorful powder and dust, super detailed" --output-dir ~/tmp/fireflyOutput
```

### gptprompt.py

Python3 script that takes a prompt and then calls the ChatGPT API to suggests alternatives to the prompt, and then optionally (--generate) uses firefly to generate all of the prompts.

Requires that you have an [OpenAPI key](https://help.openai.com/en/articles/4936850-where-do-i-find-my-openai-api-key) and that it is stored in the OPENAI_API_KEY environment variable

```
python3 gptprompt.py --prompt "Big bang universe explosion, supernova blast, made out of colorful powder and dust, super detailed" --output-dir ~/tmp/fireflyOutput --num-prompts = 5 --generate
```

### cvideo.py

Python3 script that takes a folder of jpgs and converts it to an mp4 videos playing 3 images per second

```
python3 cvideo.py --input-dir ~/tmp/fireflyOutput --rename
```

Requires that [ffmpeg](https://ffmpeg.org/) is installed and in path.

### scale.py

Python3 script that uses [REAL-ESRGAN](https://github.com/xinntao/Real-ESRGAN) to scale up directories of Firefly generated JPGs. By default it creates PNGs, but you can specify JPGs with the _--format_ argument

Scaled files will be saved in the _scaled_ directory created in the _--input-dir_

```
python3 scale.py --input-dir /Users/mesh/tmp/fireflyOutput/ --scale 2
```

Requires that [REAL-ESRGAN](https://github.com/xinntao/Real-ESRGAN) executable is placed into system path and named `realesrgan`. Assumes that included models are placed in `~/bin/models/` directory. Can also specify via the _--model-dir_ arguments.

### clean.py

Script that cleans up orphaned setting JSON files (setting files that dont have a corresponding jpg file)

By default it will copy the orphaned setting files into a directory called _removed_ created in the _--input-dir_

```
python3 clean.py --input-dir /Users/mesh/tmp/fireflyOutput/
```

### csv.py

Script that creates a CSV file with data from image setting json files contained in a folder

```
python3 export.py --input-dir /Users/mesh/tmp/fireflyOutput/
```

### firefly_lib.py

Library of code shared across the scripts.

## License

Project released under a [MIT License](LICENSE.md).

[![License: MIT](https://img.shields.io/badge/License-MIT-orange.svg)](LICENSE.md)
