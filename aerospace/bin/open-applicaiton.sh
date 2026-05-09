ls /Applications/ /Applications/Utilities/ /System/Applications/ /System/Applications/Utilities/ /Users/ivar.fatland/Applications/ /Users/ivar.fatland/Applications/Chrome\ Apps.localized/ | \
    grep '\.app$' | \
    sed 's/\.app$//g' | \
    { cat; echo "Finder"; } | \
    sort | \
    raymenu | \
    xargs -I {} open -n -a "{}.app"
