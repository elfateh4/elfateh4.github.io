#!/usr/bin/env sh
# POSIX shell script to scaffold a new Jekyll post in _posts/
# Usage: scripts/new_post.sh --title "My Post" [--tags "a,b"] [--excerpt "Short summary"] [--date "YYYY-MM-DD" | "YYYY-MM-DD HH:MM:SS"]

set -eu

# Warn when iconv is not available: fallback will remove accents instead of transliterating them.
if ! command -v iconv >/dev/null 2>&1; then
  echo "Warning: 'iconv' not found; accents may be removed instead of transliterated." >&2
fi

usage() {
  cat <<EOF
Usage: $0 --title "Title" [--tags "a,b"] [--excerpt "text"] [--date "YYYY-MM-DD" | "YYYY-MM-DD HH:MM:SS"]
EOF
  exit 1
}

TITLE=""
TAGS=""
EXCERPT=""
DATE=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --title)
      shift
      TITLE="$1"; shift;;
    --tags)
      shift
      TAGS="$1"; shift;;
    --excerpt)
      shift
      EXCERPT="$1"; shift;;
    --date)
      shift
      DATE="$1"; shift;;
    --help|-h)
      usage;;
    *)
      echo "Unknown arg: $1" >&2
      usage;;
  esac
done

if [ -z "$TITLE" ]; then
  echo "Error: --title is required" >&2
  usage
fi

# slugify: lower-case, replace non-alnum with -, trim -
slugify() {
  # If iconv is available, use transliteration to preserve accents; otherwise do a conservative fallback.
  if command -v iconv >/dev/null 2>&1; then
    echo "$1" | iconv -t ascii//TRANSLIT 2>/dev/null | tr '[:upper:]' '[:lower:]' | sed "s/[^a-z0-9]/-/g" | sed "s/-\{1,\}/-/g" | sed 's/^\-|-$//g'
  else
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed "s/[^a-z0-9]/-/g" | sed "s/-\{1,\}/-/g" | sed 's/^\-|-$//g'
  fi
}

# date for filename
if [ -n "$DATE" ]; then
  # try to parse YYYY-MM-DD or ISO-ish strings; just grab the date part
  DATE_PREFIX=$(echo "$DATE" | awk '{print $1}')
else
  DATE_PREFIX=$(date +%Y-%m-%d)
fi

FILENAME_SUFFIX=$(slugify "$TITLE")
FILENAME="$DATE_PREFIX-$FILENAME_SUFFIX.md"
TARGET_DIR="_posts"
mkdir -p "$TARGET_DIR"
TARGET="$TARGET_DIR/$FILENAME"

if [ -e "$TARGET" ]; then
  echo "Error: $TARGET already exists" >&2
  exit 1
fi

# tags to YAML list
if [ -n "$TAGS" ]; then
  # convert a,b to [a, b]
  IFS=','; set -- $TAGS; unset IFS
  TAGS_YAML="["
  first=1
  for tag in "$@"; do
    tag_trim=$(printf '%s' "$tag" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ "$first" -eq 1 ]; then
      TAGS_YAML="$TAGS_YAML$tag_trim"
      first=0
    else
      TAGS_YAML="$TAGS_YAML, $tag_trim"
    fi
  done
  TAGS_YAML="$TAGS_YAML]"
else
  TAGS_YAML="[]"
fi

# date in frontmatter (with time if provided)
if [ -n "$DATE" ]; then
  DATE_FM="$DATE"
else
  DATE_FM=$(date +"%Y-%m-%d %H:%M:%S %z")
fi

# build content
{
  echo "---"
  echo "layout: post"
  # escape double quotes in title
  esc_title=$(printf '%s' "$TITLE" | sed 's/"/\"/g')
  echo "title: \"$esc_title\""
  echo "date: $DATE_FM"
  echo "tags: $TAGS_YAML"
  if [ -n "$EXCERPT" ]; then
    esc_excerpt=$(printf '%s' "$EXCERPT" | sed 's/"/\"/g')
    echo "excerpt: \"$esc_excerpt\""
  fi
  echo "---"
  echo
  echo "# $TITLE"
  echo
  echo "Write your post here."
} > "$TARGET"

chmod 644 "$TARGET"

echo "Created $TARGET"
