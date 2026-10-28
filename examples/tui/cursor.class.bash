# cursor.class.bash - Cursor control primitives for ba.sh TUI library
# No dependencies

# Prevent double-loading
[[ -n $TUI_CURSOR_LOADED ]] && return
TUI_CURSOR_LOADED=1

# Move cursor to specific position (row, col - 1-indexed)
tui.cursor.move(){
    printf '\033[%d;%dH' "$1" "$2"
}

# Move cursor to home position (1,1)
tui.cursor.home(){
    printf '\033[H'
}

# Move cursor up N lines
tui.cursor.up(){
    local n=${1:-1}
    printf '\033[%dA' "$n"
}

# Move cursor down N lines
tui.cursor.down(){
    local n=${1:-1}
    printf '\033[%dB' "$n"
}

# Move cursor forward (right) N columns
tui.cursor.right(){
    local n=${1:-1}
    printf '\033[%dC' "$n"
}

# Move cursor backward (left) N columns
tui.cursor.left(){
    local n=${1:-1}
    printf '\033[%dD' "$n"
}

# Move to start of next line, N lines down
tui.cursor.next_line(){
    local n=${1:-1}
    printf '\033[%dE' "$n"
}

# Move to start of previous line, N lines up
tui.cursor.prev_line(){
    local n=${1:-1}
    printf '\033[%dF' "$n"
}

# Move cursor to column N (1-indexed)
tui.cursor.column(){
    printf '\033[%dG' "$1"
}

# Save cursor position
tui.cursor.save(){
    printf '\033[s'
}

# Restore cursor position
tui.cursor.restore(){
    printf '\033[u'
}

# Alternative save (more compatible)
tui.cursor.save_alt(){
    printf '\0337'
}

# Alternative restore
tui.cursor.restore_alt(){
    printf '\0338'
}

# Hide cursor
tui.cursor.hide(){
    printf '\033[?25l'
}

# Show cursor
tui.cursor.show(){
    printf '\033[?25h'
}

# Set cursor style
# Styles: 0=default, 1=blinking block, 2=steady block,
#         3=blinking underline, 4=steady underline,
#         5=blinking bar, 6=steady bar
tui.cursor.style(){
    printf '\033[%d q' "$1"
}

# Get cursor position (returns via callback or prints to stdout)
# Note: This reads from terminal, may not work reliably in all contexts
# Use with caution - can block if terminal doesn't respond
tui.cursor.get_position(){
    local oldstty pos_row pos_col
    
    # Save terminal state and set raw mode
    oldstty=$(stty -g 2>/dev/null)
    stty raw -echo 2>/dev/null
    
    # Query position
    printf '\033[6n' > /dev/tty
    
    # Read response with timeout
    IFS='[;' read -t 1 -r -d R _ pos_row pos_col < /dev/tty 2>/dev/null
    
    # Restore terminal state
    stty "$oldstty" 2>/dev/null
    
    echo "${pos_row:-0} ${pos_col:-0}"
}
