#!/bin/bash
cd "`dirname "$0"`"
cabal --require-sandbox build
dist/build/httpmtimeline/httpmtimeline --no-access-log --no-error-log --port=5000
