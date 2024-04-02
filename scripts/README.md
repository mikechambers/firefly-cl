# firefly-cl scripts

Collection of shell scripts using the firefly command line app.

[https://github.com/mikechambers/firefly-cl](https://github.com/mikechambers/firefly-cl)

## Scripts

### recursive

Bash script that recursively generates an image, feeding the previously generated image in as a style reference, and then outputs all of the file and a video.

Requires that [ffmpeg](https://ffmpeg.org/) is install and in path.

### styles

Bash script that generates one image for each possible style based on the specified prompt. Will create an image for each style, and combine all of them into a pdf.

Requires that [ImageMagick](https://imagemagick.org/index.php) is installed and in path.

### rstyles

Bash script that takes a prompt and randomly combines styles (based on your settings), to create images. Useful for finding unique, interesting style combinations.

Requires that [ImageMagick](https://imagemagick.org/index.php) is installed and in path.

### astyles

Bash script that takes a prompt and then generates an image using all possible styles.

## License

Project released under a [MIT License](LICENSE.md).

[![License: MIT](https://img.shields.io/badge/License-MIT-orange.svg)](LICENSE.md)
