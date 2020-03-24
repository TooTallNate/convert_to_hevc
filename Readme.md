# convert_to_hevc

Transcodes input video file to use the h265/HEVC codec using `ffmpeg`.
Outputs the same filename but with x264/h264/xvid/etc. replaced with HEVC.

## Installation

 1. [Install `import`](https://import.pw/importpw/import/docs/install.md).
 1. Add to your `.bashrc` file:
    ```bash
    . "$(which import)"
    import "tootallnate/convert_to_hevc@0.0.1"
    ```

## Usage

```
$ convert_to_hevc <list of files...>
```
