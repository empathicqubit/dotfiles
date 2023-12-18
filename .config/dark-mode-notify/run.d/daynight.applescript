property waitKey : 0.001
property waitTransition : 0.25
on run argv
	set darkMode to item 1 of argv
	set settingsString to item 2 of argv

	activate application "Microsoft Teams"
	tell application "System Events"
            key code 53
            delay waitTransition
            tell process "Microsoft Teams"
                click menu item settingsString of menu "Microsoft Teams" of menu bar 1
            end tell
            delay waitTransition

            keystroke tab
            delay waitKey

            if darkMode is "1" then
				key code 124 # right arrow
				delay waitKey
            end if

            keystroke return
            delay waitKey
            key code 53
            delay waitTransition
            
            keystroke tab using command down
	end tell
end run
