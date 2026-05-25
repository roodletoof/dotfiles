MONITORS=$(xrandr -q | awk '/\sconnected/ {print $1}')
CHOSEN_MONITOR=$(echo "$MONITORS" | dmenu -i -p 'choose your monitor')
if [ -z "$CHOSEN_MONITOR" ]; then
    exit 1
fi
MONITORS=$(echo "$MONITORS" | sed "/^${CHOSEN_MONITOR}$/d")
echo "$MONITORS" | xargs -I {} xrandr --output {} --off
xrandr --output "$CHOSEN_MONITOR" --auto
feh --bg-max ~/.wallpaper/
