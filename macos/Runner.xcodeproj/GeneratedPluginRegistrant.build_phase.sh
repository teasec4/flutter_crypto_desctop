#!/bin/bash
# Copy GoogleService-Info.plist to app bundle
if [ -f "${SOURCE_ROOT}/Runner/GoogleService-Info.plist" ]; then
  cp "${SOURCE_ROOT}/Runner/GoogleService-Info.plist" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/"
fi
