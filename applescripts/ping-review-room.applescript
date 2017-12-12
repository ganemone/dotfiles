do shell script "fusion-orchestrate reviews --mine | grep -v 'Needs other' | grep -v '^$' | pbcopy"
tell application "uchat"
  activate
  tell application "System Events" 
    keystroke "k" using command down
    delay 0.5
    keystroke "Web Platform Code Reviews"
    delay 0.5
    key code 36
    delay 0.5
    keystroke "v" using command down    
  end tell
end tell