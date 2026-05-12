ls /Applications/ /Applications/Utilities/ /System/Applications/ /System/Applications/Utilities/ $HOME/Applications/ $HOME/Applications/Chrome\ Apps.localized/ | \
    grep '\.app$' | \
    sed 's/\.app$//g' | \
    { cat; echo "Finder"; } | \
    sort | \
    raymenu -p "launch application" | \
    while read app; do
        if [ "$app" = "Finder" ]; then
            osascript -e 'tell application "Finder"
                activate
                make new Finder window
            end tell'
        else
            open -n -a "$app.app"
        fi
    done
