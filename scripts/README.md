# firefly-cl scripts

Collection of Python 3 scripts using the firefly command line app.

[https://github.com/mikechambers/firefly-cl](https://github.com/mikechambers/firefly-cl)

## Scripts

### prompt.py

Python3 script that takes a prompt and generates the specified number of variations

Individual images and a PDF are created with the information necessary to recreate the images.

```
python3 prompt.py --prompt "Big bang universe explosion, supernova blast, made out of colorful powder and dust, super detailed" --num_generations 20 --output_dir ~/tmp/fireflyOutput
```

Requires the Python [Pillow library](https://python-pillow.org/) is installed.

### recursive.py

Python 3 script that recursively generates an image, feeding the previously generated image in as a style reference, and then outputs all of the file and a video.

```
python3 recursive.py --prompt "Big bang universe explosion, supernova blast, made out of colorful powder and dust, super detailed" --output_dir ~/tmp/fireflyOutput --num_generations 20
```

Requires that [ffmpeg](https://ffmpeg.org/) is install and in path.

### styles.py

Python 3 script that generates one image for each possible style based on the specified prompt. Will create an image for each style, and combine all of them into a pdf.

Requires the Python [Pillow library](https://python-pillow.org/) is installed.

```
python3 styles.py --prompt "Big bang universe explosion, supernova blast, made out of colorful powder and dust, super detailed" --output_dir ~/tmp/fireflyOutput
```

### rstyles.py

Python 3 script that takes a prompt and randomly combines styles (based on your settings), to create images. Useful for finding unique, interesting style combinations.

Requires the Python [Pillow library](https://python-pillow.org/) is installed.

```
python3 rstyles.py --prompt "Big bang universe explosion, supernova blast, made out of colorful powder and dust, super detailed" --output_dir ~/tmp/fireflyOutput --num_images=20 --num_styles=5
```

### astyles.py

Python3 script that takes a prompt and then generates an image using all possible styles.

```
python3 astyles.py --prompt "Big bang universe explosion, supernova blast, made out of colorful powder and dust, super detailed" --output_dir ~/tmp/fireflyOutput
```

### gptprompt.py

Python3 script that takes a prompt and then calls the ChatGPT API to suggests alternatives to the prompt, and then uses firefly to generate all of the prompts.

Requires that you have an [OpenAPI key](https://help.openai.com/en/articles/4936850-where-do-i-find-my-openai-api-key) and that it is stored in the OPENAI_API_KEY environment variable

```
python3 gptprompt.py --prompt "Big bang universe explosion, supernova blast, made out of colorful powder and dust, super detailed" --output_dir ~/tmp/fireflyOutput --num_prompts = 5
```

### firefly_lib.py

Library of code shared across the scripts.

## License

Project released under a [MIT License](LICENSE.md).

[![License: MIT](https://img.shields.io/badge/License-MIT-orange.svg)](LICENSE.md)
