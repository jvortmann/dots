---
name: yt-dlp
description: Load whenever a video or its audio, subtitles, transcript or details need fetching from a URL, every time. That covers YouTube and the many other sites yt-dlp supports, a request to summarize or quote a video, and a playlist. It carries the commands that work on this machine, which has no ffmpeg, and how to turn subtitles into plain text.
---

# yt-dlp

yt-dlp fetches media and its details from YouTube and many other sites. Write
what it fetches under `/tmp`, unless the user names a place.

## No ffmpeg here

ffmpeg is not installed, so avoid every option that converts: `--convert-subs`,
`-x`, `--audio-format`, `--merge-output-format`, and a format that joins
separate video and audio. Ask the user before you install ffmpeg. The commands
below all work without it.

## Get a transcript

Download the subtitles as VTT, which needs no conversion, then strip them to
text. Captions made by YouTube repeat each line as they roll, so drop the
repeats.

```sh
yt-dlp --skip-download --write-auto-subs --sub-langs en --sub-format vtt \
  -o /tmp/transcript "<url>"
sed -E '/^WEBVTT|^Kind:|^Language:|-->|^[[:space:]]*$/d; s/<[^>]*>//g' \
  /tmp/transcript.en.vtt | awk '!seen[$0]++'
```

- `--write-subs` takes subtitles that a person uploaded. They are better when a
  video has them. `--write-auto-subs` takes the captions YouTube made.
- `yt-dlp --list-subs "<url>"` lists the languages. `--sub-langs` also takes a
  pattern, such as `"en.*"`.

## Get the details

```sh
yt-dlp --print "%(title)s | %(channel)s | %(duration_string)s" "<url>"
yt-dlp --dump-json "<url>"
yt-dlp --flat-playlist --print "%(title)s %(url)s" "<playlist-url>"
```

## Download

```sh
yt-dlp -f best -o "/tmp/%(title)s.%(ext)s" "<url>"
yt-dlp -f bestaudio -o "/tmp/%(title)s.%(ext)s" "<url>"
```

- `best` picks one file that holds both video and audio, so nothing has to
  merge them. On YouTube that file is often only 360p. The higher qualities
  come as separate video and audio, and joining them needs ffmpeg.
  `yt-dlp -F "<url>"` lists the formats.
- YouTube can answer two requests for one video differently. When a format
  that worked a moment ago is not available, run the command again once.
- `bestaudio` keeps the audio in its own format, such as `m4a` or `webm`.
  Changing it to `mp3` needs ffmpeg.
- `--no-playlist` takes one video from a playlist URL. `--playlist-items 1:5`
  takes a range.

## When it fails

- Private or age-restricted video: `--cookies-from-browser firefox` uses the
  login of that browser. Ask the user first, because it reads their cookies.
- An error on a site that worked before: yt-dlp breaks when a site changes.
  Check `yt-dlp --version`, and tell the user an update may fix it.
