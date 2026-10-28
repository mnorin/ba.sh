# screen.class.bash - Screen operations for ba.sh TUI library
# No dependencies

# Prevent double-loading
[[ -n $TUI_SCREEN_LOADED ]] && return
TUI_SCREEN_LOADED=1

# Clear entire screen
tui.screen.clear(){
    printf '\033[2J'
}

# Clear from cursor to end of screen
tui.screen.clear_to_end(){
    printf '\033[0J'
}

# Clear from cursor to beginning of screen
tui.screen.clear_to_start(){
    printf '\033[1J'
}

# Clear entire line
tui.screen.clear_line(){
    printf '\033[2K'
}

# Clear from cursor to end of line
tui.screen.clear_line_to_end(){
    printf '\033[0K'
}

# Clear from cursor to start of line
tui.screen.clear_line_to_start(){
    printf '\033[1K'
}

# Clear screen and move cursor to home (common operation)
tui.screen.clear_home(){
    printf '\033[2J\033[H'
}

# Enable alternative screen buffer
tui.screen.alt(){
    printf '\033[?1049h'
}

# Disable alternative screen buffer (return to main)
tui.screen.main(){
    printf '\033[?1049l'
}

# Hard reset terminal
tui.screen.reset(){
    printf '\033c'
}

# Soft reset (preserves some state)
tui.screen.soft_reset(){
    printf '\033[!p'
}

# Clear screen and scrollback buffer
tui.screen.clear_scrollback(){
    printf '\033[3J'
}

# Enable line wrap
tui.screen.wrap_on(){
    printf '\033[?7h'
}

# Disable line wrap
tui.screen.wrap_off(){
    printf '\033[?7l'
}

# Scroll up N lines
tui.screen.scroll_up(){
    local n=${1:-1}
    printf '\033[%dS' "$n"
}

# Scroll down N lines
tui.screen.scroll_down(){
    local n=${1:-1}
    printf '\033[%dT' "$n"
}

# Set scroll region (top row to bottom row, inclusive)
tui.screen.scroll_region(){
    local top=$1
    local bottom=$2
    printf '\033[%d;%dr' "$top" "$bottom"
}

# Reset scroll region to full screen
tui.screen.scroll_region_reset(){
    printf '\033[r'
}

# Get terminal size (returns "rows cols")
tui.screen.size(){
    local rows cols
    
    # Try using stty first (most reliable)
    if command -v stty &>/dev/null; then
        read rows cols < <(stty size 2>/dev/null)
        if [[ -n $rows && -n $cols ]]; then
            echo "$rows $cols"
            return
        fi
    fi
    
    # Fallback to environment variables
    rows=${LINES:-24}
    cols=${COLUMNS:-80}
    echo "$rows $cols"
}
