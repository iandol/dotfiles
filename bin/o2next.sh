#!/usr/bin/env sh

# Converts Opera to Opera Next on OS X

if [ -f /Applications/Opera.app/Contents/Info.plist ]; then
	echo "Rewriting plist info..."
	defaults write /Applications/Opera.app/Contents/Info.plist CFBundleIdentifier com.operasoftware.OperaNext
	defaults write /Applications/Opera.app/Contents/Info.plist CFBundleName "Opera Next"
fi
if [ -f /Applications/Opera\ Next.app/Contents/Resources/Opera.icns ]; then
	echo "Copying icon..."
	cp -f Applications/Opera\ Next.app/Contents/Resources/Opera.icns Applications/Opera.app/Contents/Resources/Opera.icns
fi

echo "moving application..."
rm -rf /Applications/Opera\ Next.app
mv -f /Applications/Opera.app /Applications/Opera\ Next.app
echo "Done..."
# Disclaimer: Any alteration to Opera’s application bundle is unsupported and discouraged.
