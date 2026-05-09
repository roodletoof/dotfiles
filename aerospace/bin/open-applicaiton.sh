ls /Applications/ /Applications/Utilities/ /System/Applications/ /System/Applications/Utilities/ /Users/ivar.fatland/Applications/ /Users/ivar.fatland/Applications/Chrome\ Apps.localized/ | \
    grep '\.app$' | \
    sed 's/\.app$//g' | \
    { cat; echo "Finder"; } | \
    sort | \
    raymenu | \
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
