#!/bin/bash

# Copy GoogleService-Info.plist if it exists
SOURCE="${SOURCE_ROOT}/Runner/GoogleService-Info.plist"
DEST="${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/Contents/Resources/"

if [ -f "$SOURCE" ]; then
    mkdir -p "$DEST"
    cp "$SOURCE" "$DEST"
    echo "Copied GoogleService-Info.plist to app bundle"
else
    echo "Warning: GoogleService-Info.plist not found"
fi
