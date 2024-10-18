if application "Bookends" is running then
	tell application "System Events" to set previousApp to name of 1st process whose frontmost is true
	tell application "Bookends" to activate
	delay (0.1)
	tell application "System Events" to tell application process "Bookends" to click menu item "Sync Linked BibTeX File" of menu 1 of menu bar item "File" of menu bar 1
	delay (0.1)
	tell application previousApp to activate
end if