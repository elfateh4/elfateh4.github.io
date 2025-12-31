#!/usr/bin/env sh
# Interactive script to scaffold a new Jekyll post in _posts/

set -eu

# Warn when iconv is not available: fallback will remove accents instead of transliterating them.
if ! command -v iconv >/dev/null 2>&1; then
  echo "Warning: 'iconv' not found; accents may be removed instead of transliterated." >&2
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

echo "Creating a new Jekyll post..."
echo -n "Title: "
read -r TITLE
if [ -z "$TITLE" ]; then
  echo "Error: Title is required" >&2
  exit 1
fi

echo -n "Create both English and Arabic versions? (y/n, default n): "
read -r CREATE_BOTH
if [ "$CREATE_BOTH" = "y" ] || [ "$CREATE_BOTH" = "Y" ]; then
  echo -n "Arabic Title: "
  read -r AR_TITLE
  if [ -z "$AR_TITLE" ]; then
    AR_TITLE="$TITLE"  # fallback
  fi
fi

echo -n "Tags (comma-separated, optional): "
read -r TAGS

echo -n "Excerpt (optional): "
read -r EXCERPT

echo -n "Arabic Excerpt (optional): "
read -r AR_EXCERPT

echo -n "Date (YYYY-MM-DD, optional): "
read -r DATE

echo -n "Base slug (optional, defaults to slugified English title): "
read -r BASE_SLUG

# default base_slug
if [ -z "$BASE_SLUG" ]; then
  BASE_SLUG=$(slugify "$TITLE")
fi

TARGET_DIR="_posts"
mkdir -p "$TARGET_DIR"

# Function to create a post
create_post() {
  local post_lang="$1"
  local post_title="$2"
  local post_excerpt="$3"
  local filename_suffix

  filename_suffix="$BASE_SLUG"
  if [ "$post_lang" = "ar" ]; then
    filename_suffix="$filename_suffix-ar"
  fi

  local filename="$DATE_PREFIX-$filename_suffix.md"
  local target="$TARGET_DIR/$filename"

  if [ -e "$target" ]; then
    echo "Error: $target already exists" >&2
    return 1
  fi

  # tags to YAML list
  local tags_yaml="[]"
  if [ -n "$TAGS" ]; then
    IFS=','; set -- $TAGS; unset IFS
    tags_yaml="["
    first=1
    for tag in "$@"; do
      tag_trim=$(printf '%s' "$tag" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      if [ "$first" -eq 1 ]; then
        tags_yaml="$tags_yaml$tag_trim"
        first=0
      else
        tags_yaml="$tags_yaml, $tag_trim"
      fi
    done
    tags_yaml="$tags_yaml]"
  fi

  # date in frontmatter
  local date_fm
  if [ -n "$DATE" ]; then
    date_fm="$DATE"
  else
    date_fm=$(date +"%Y-%m-%d %H:%M:%S %z")
  fi

  # build content
  {
    echo "---"
    echo "layout: post"
    esc_title=$(printf '%s' "$post_title" | sed 's/"/\"/g')
    echo "title: \"$esc_title\""
    echo "date: $date_fm"
    echo "tags: $tags_yaml"
    echo "lang: $post_lang"
    echo "base_slug: $BASE_SLUG"
    if [ -n "$post_excerpt" ]; then
      esc_excerpt=$(printf '%s' "$post_excerpt" | sed 's/"/\"/g')
      echo "excerpt: \"$esc_excerpt\""
    fi
    echo "---"
    echo
    echo "# $post_title"
    echo
    echo "Write your post here."
  } > "$target"

  chmod 644 "$target"
  echo "Created $target"
}

# date for filename
if [ -n "$DATE" ]; then
  DATE_PREFIX=$(echo "$DATE" | awk '{print $1}')
else
  DATE_PREFIX=$(date +%Y-%m-%d)
fi

# Create English post
create_post "en" "$TITLE" "$EXCERPT"

# Create Arabic post if requested
if [ "$CREATE_BOTH" = "y" ] || [ "$CREATE_BOTH" = "Y" ]; then
  create_post "ar" "$AR_TITLE" "$AR_EXCERPT"
fi
