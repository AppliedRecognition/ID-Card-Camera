#!/bin/sh
set -e

#  build-docs.sh
#  IDCardCamera
#
#  Created by Jakub Dolejs on 15/11/2021.
#  Copyright © 2021 Applied Recognition Inc. All rights reserved.
LOG_FILE=build-docs-log.txt
rm -f ${LOG_FILE}
DERIVED_DATA_PATH=tmp/IDCardCamera
echo "Building documentation archive"
xcodebuild docbuild -scheme IDCardCamera -sdk iphoneos -derivedDataPath "${DERIVED_DATA_PATH}" > ${LOG_FILE} 2>&1
DOCCARCHIVE=`find "${DERIVED_DATA_PATH}" -type d -name IDCardCamera.doccarchive`
echo "Cloning docc2html utility from Github"
git clone https://github.com/DoccZz/docc2html.git >> ${LOG_FILE} 2>&1
cd docc2html
echo "Converting doccarchive to html"
swift run docc2html --force "../${DOCCARCHIVE}" ../docs >> ${LOG_FILE} 2>&1
cd ..
echo "Writing redirection index.html"
echo '<!DOCTYPE html><html><head><meta http-equiv="refresh" content="0; url=documentation/idcardcamera/index.html" /></head><body><a href="documentation/idcardcamera/index.html">Documentation</a></body></html>' > docs/index.html
echo "Cleaning up"
rm -rf docc2html
rm -rf tmp
rm -rf IDCardCamera.doccarchive
echo "Done"
