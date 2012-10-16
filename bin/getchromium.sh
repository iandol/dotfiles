#!/bin/sh
# Get current build for Chromium on Mac.
# 
# @version  2009-05-22
# @author   XXXX 
# @todo     Nothing yet

# setup ------------------------------------------------------------------------
tempDir="/tmp/`whoami`/chrome-nightly/";
baseURL="http://commondatastorage.googleapis.com/chromium-browser-snapshots/Mac";
baseName="chrome-mac";
baseExt="zip";
appName="Chromium.app";
appDir="/Applications";
version=~/.CURRENT_CHROME;
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
function checkForErrors {
    if [ "$?" != "0" ]; then
        echo "Unkown error (see above for help)!";
        exit 3;
    fi
}
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
echo "Setup...";
mkdir -p "$tempDir";
cd "$tempDir";
checkForErrors;
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
echo "Checking current version...";
touch $version
currentVersion=`cat $version`;
latestVersion=`curl -s $baseURL/LAST_CHANGE`;
checkForErrors;
echo " * your/latest build: $currentVersion / $latestVersion";
if [ "$currentVersion" == "$latestVersion" ]; then
    echo " * build $currentVersion is the latest one.";
    exit 1;
fi
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
echo "Downloading and unpacking...";
chromePID=`ps wwaux|grep -v grep|grep "$appName"|awk '{print $2}'`;
if [ "$chromePID" != "" ];then
    echo " * chromium is running. Please stop it first.";
    exit 2;
fi
curl -L "$baseURL/$latestVersion/$baseName.$baseExt" -o $baseName.$baseExt;
unzip -qo $baseName.$baseExt;
checkForErrors;
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
echo "Installing...";
cp -r $baseName/$appName $appDir
checkForErrors;
echo $latestVersion > $version;
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
echo "Done. You're now running build $latestVersion";
# ------------------------------------------------------------------------------