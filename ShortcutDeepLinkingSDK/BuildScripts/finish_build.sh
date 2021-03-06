# This script copies all files that will be distributed into the project dir

set -e

FRAMEWORK="${BUILT_PRODUCTS_DIR}/${PROJECT_NAME}.framework"

rm -rf "${PROJECT_DIR}/build"
mkdir -p "${PROJECT_DIR}/build"

cp -R "${FRAMEWORK}" "${PROJECT_DIR}/build/"

cp "${PROJECT_DIR}/README.md" "${PROJECT_DIR}/build/"
cp "${PROJECT_DIR}/LICENSE.txt" "${PROJECT_DIR}/build/"

SDK_VERSION=`ruby -e "print File.read('${PROJECT_DIR}/ShortcutDeepLinkingSDK/ShortcutDeepLinkingSDK.h').match(/SDK_VERSION @\"([^\"]+)\"/)[1]"`

cd "${PROJECT_DIR}/build" && zip -r "ShortcutDeepLinkingSDK-${SDK_VERSION}.zip" . && cd -

open "${PROJECT_DIR}/build"
