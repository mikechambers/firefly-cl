# firefly-cl scripts

Collection of shell scripts using the firefly command line app.

## Scripts

### recursive

Bash script that recursively generates an image, feeding the previously generated image in as a style reference, and then outputs all of the file and a video.

Requires that [ffmpeg](https://ffmpeg.org/) is install and in path.

### styles

Bash script that generates one image for each possible style based on the specified prompt. Will create an image for each style, and combine all of them into a pdf.

Requires that [ImageMagick](https://imagemagick.org/index.php) is installed and in path.

## License

Project released under a [MIT License](LICENSE.md).

[![License: MIT](https://img.shields.io/badge/License-MIT-orange.svg)](LICENSE.md)
