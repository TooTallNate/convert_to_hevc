#!/bin/bash
# Transcodes input video file to use the h265/HEVC codec.
# Outputs the same filename but with x264/h264/xvid/etc. replaced with HEVC.

# Allow for `sed` or `gsed`
convert_to_hevc__sed=sed
if type gsed >/dev/null 2>&1; then
	convert_to_hevc__sed=gsed
fi

convert_to_hevc__get_streams() {
	ffprobe "$1" 2>&1 | grep -e '^\s*Stream' | "$convert_to_hevc__sed" -e 's/^[[:space:]]*//'
}

convert_to_hevc__is_hevc() {
	echo "$1" | grep 'Video: hevc' >/dev/null
}

convert_to_hevc__r() {
	"$convert_to_hevc__sed" "s/$1/HEVC/ig"
}

convert_to_hevc__add_hevc() {
	local replaced
	local extension="$2"
	local base="${replaced%.*}"
	replaced="$(echo "$1" | convert_to_hevc__r "x.\?264" | convert_to_hevc__r "h.\?264" | convert_to_hevc__r xvid | convert_to_hevc__r divx)"

	echo "${base}" | grep -i HEVC >/dev/null
	if [ $? -ne 0 ]; then
		# Nothing changed, so just tack on hevc at the end
		base="${base}.HEVC"
	fi
	echo "${base}.${extension}"
}

convert_to_hevc() {
	local streams
	local output
	local input="$1"
	streams="$(convert_to_hevc__get_streams "${input}")"

	if convert_to_hevc__is_hevc "${streams}"; then
		echo "\"${input}\" is already in HEVC format, bailing…"
		return
	fi

	output="$(convert_to_hevc__add_hevc "${input}" mkv)"
	echo "Converting \"${input}\" to \"${output}\""
	ffmpeg \
		-hide_banner \
		-y \
		-ss 0 \
		-i "${input}" \
		-map_metadata 0 \
		-map_chapters 0 \
		-c:v libx265 -preset medium -x265-params \
		crf=22:qcomp=0.8:aq-mode=1:aq_strength=1.0:qg-size=16:psy-rd=0.7:psy-rdoq=5.0:rdoq-level=1:merange=44 \
		-c:a copy \
		-c:s copy \
		"${output}"
}
