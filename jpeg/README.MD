

Update file timestamps from metadata
exiv2 -t -r "updated/:basename:" *.JPG

Update file timestamps from metadata for video files
for file in *.mp4; do touch -t "$(mediainfo "$file" | grep -m 1 'Tagged date' | sed -r 's/.*([0-9]{4})-([0-9]{2})-([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2}).*/\1\2\3\4\5.\6/')" "$file"; done

