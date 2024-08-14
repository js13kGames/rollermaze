#!/bin/bash

# Check for work folder specified
if [ $# -ge 1 ]
then
  workdir=$1
  echo "Entering ${workdir}"
  cd "${workdir}"
fi

if [ $# -ge 2 ]
then
  param=$2
else
  param=""
fi

zipfile="js13k.zip"
buildpath="tmpbuild"
jscat="${buildpath}/min.js"
indexcat="${buildpath}/index.html"

if [ "${param}" == "run" ]
then
  curbrowser=`which xdg-open >/dev/null 2>&1`
  if [ "${curbrowser}" == "" ]
  then
    curbrowser="firefox"
  fi

  curbrowser="/opt/google/chrome/chrome"

  ${curbrowser} "index.html" >/dev/null 2>&1
  exit 0
fi

# Create clean build folder
echo "Cleaning build folder"
rm -Rf "${buildpath}" >/dev/null 2>&1
mkdir "${buildpath}"

# Concatenate the JS files
echo "Concatenating JS"
touch "${jscat}" >/dev/null 2>&1
for file in "w.js" "main.js"
do
  cat "${file}" >> "${jscat}"
done

# Add the index header
echo -n '<!DOCTYPE html><html><head><meta charset="utf-8"/><meta http-equiv="Content-Type" content="text/html;charset=utf-8"/><title>JS13k 2024</title><style>' > "${indexcat}"

# Inject the concatenated and minified CSS files
echo "Minifying CSS"
for file in "main.css"
do
  JAVA_CMD=java yui-compressor "${file}" >> "${indexcat}"
done

# Add on the rest of the index file
echo -n '</style><script type="text/javascript">' >> "${indexcat}"

# Inject the closure-ised and minified JS
echo "Using closure to minify JS"
./closeyoureyes.sh "${jscat}" | tr -d '\n' >> "${indexcat}"

# Add on the rest of the index file
echo -n '</script><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"/></head><body><div id="wrapper"><canvas id="canvas" width="640" height="360"></canvas></div></body></html>' >> "${indexcat}"

# Remove the minified JS
rm "${jscat}" >/dev/null 2>&1

# Remove old zip
rm -Rf "${zipfile}" >/dev/null 2>&1

# Zip everything up
echo "ZIP build folder"
zip -j "${zipfile}" "${buildpath}"/*

# Re-Zip with advzip to save a bit more
echo "Trying to reduce ZIP size"
advzip -i 200 -k -z -4 "${zipfile}"

# Determine file sizes and compression
unzip -lv "${zipfile}"
stat "${zipfile}"

zipsize=`stat -c %s "${zipfile}"`
maxsize=$((13*1024))
bytesleft=$((${maxsize}-${zipsize}))
percent=$((200*${zipsize}/${maxsize} % 2 + 100*${zipsize}/${maxsize}))

if [ ${bytesleft} -ge 0 ]
then
  echo "YAY ${percent}% used - it fits with ${bytesleft} bytes spare"
else
  echo "OH NO ${percent}% used - it's gone ovey by "$((0-${bytesleft}))" bytes"
fi
