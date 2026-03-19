#!/bin/bash
# Save as ~/.local/bin/font-preview-ranger.sh

FONT_FILE="$1"
CACHE_DIR="$HOME/.cache/font-previews"
mkdir -p "$CACHE_DIR"

# Generate a cache filename based on the font file path
CACHE_FILE="$CACHE_DIR/$(echo "$FONT_FILE" | sed 's/[^a-zA-Z0-9]/_/g').png"

# Generate preview if it doesn't exist or if font is newer
if [[ ! -f "$CACHE_FILE" ]] || [[ "$FONT_FILE" -nt "$CACHE_FILE" ]]; then
    fontpreview -i "$FONT_FILE" -o "$CACHE_FILE"
fi

# Display with kitty icat
kitty +kitten icat "$CACHE_FILE"
