# box.class.bash - Box drawing primitives for ba.sh TUI library
# Dependencies: cursor.class.bash

# Load dependencies if you only source box.class.bash
# When you already loaded cursor.class.bash, you won't need this like below
# . cursor.class.bash

# Prevent double-loading
[[ -n $TUI_BOX_LOADED ]] && return
TUI_BOX_LOADED=1

# ============================================================================
# Basic Box Drawing
# ============================================================================

# Draw a box with single-line borders
# Usage: tui.box.draw row col width height
tui.box.draw(){
    local y=$1 x=$2 w=$3 h=$4
    
    # Top border
    tui.cursor.move $y $x
    printf '┌'
    local i
    for ((i=0; i<w-2; i++)); do
        printf '─'
    done
    printf '┐'
    
    # Sides
    for ((i=1; i<h-1; i++)); do
        tui.cursor.move $((y+i)) $x
        printf '│'
        tui.cursor.move $((y+i)) $((x+w-1))
        printf '│'
    done
    
    # Bottom border
    tui.cursor.move $((y+h-1)) $x
    printf '└'
    for ((i=0; i<w-2; i++)); do
        printf '─'
    done
    printf '┘'
}

# Draw a box with double-line borders
tui.box.draw_double(){
    local y=$1 x=$2 w=$3 h=$4
    
    # Top border
    tui.cursor.move $y $x
    printf '╔'
    local i
    for ((i=0; i<w-2; i++)); do
        printf '═'
    done
    printf '╗'
    
    # Sides
    for ((i=1; i<h-1; i++)); do
        tui.cursor.move $((y+i)) $x
        printf '║'
        tui.cursor.move $((y+i)) $((x+w-1))
        printf '║'
    done
    
    # Bottom border
    tui.cursor.move $((y+h-1)) $x
    printf '╚'
    for ((i=0; i<w-2; i++)); do
        printf '═'
    done
    printf '╝'
}

# Draw a box with rounded corners
tui.box.draw_rounded(){
    local y=$1 x=$2 w=$3 h=$4
    
    # Top border
    tui.cursor.move $y $x
    printf '╭'
    local i
    for ((i=0; i<w-2; i++)); do
        printf '─'
    done
    printf '╮'
    
    # Sides
    for ((i=1; i<h-1; i++)); do
        tui.cursor.move $((y+i)) $x
        printf '│'
        tui.cursor.move $((y+i)) $((x+w-1))
        printf '│'
    done
    
    # Bottom border
    tui.cursor.move $((y+h-1)) $x
    printf '╰'
    for ((i=0; i<w-2; i++)); do
        printf '─'
    done
    printf '╯'
}

# Draw a filled box (solid block)
tui.box.filled(){
    local y=$1 x=$2 w=$3 h=$4
    local char="${5:-█}"
    
    local i j
    for ((i=0; i<h; i++)); do
        tui.cursor.move $((y+i)) $x
        for ((j=0; j<w; j++)); do
            printf '%s' "$char"
        done
    done
}

# Clear box area (fill with spaces)
tui.box.clear(){
    local y=$1 x=$2 w=$3 h=$4
    
    local i
    for ((i=0; i<h; i++)); do
        tui.cursor.move $((y+i)) $x
        printf '%*s' "$w"
    done
}

# ============================================================================
# Line Drawing
# ============================================================================

# Draw horizontal line
tui.box.hline(){
    local y=$1 x=$2 length=$3
    local char="${4:-─}"
    
    tui.cursor.move $y $x
    local i
    for ((i=0; i<length; i++)); do
        printf '%s' "$char"
    done
}

# Draw vertical line
tui.box.vline(){
    local y=$1 x=$2 height=$3
    local char="${4:-│}"
    
    local i
    for ((i=0; i<height; i++)); do
        tui.cursor.move $((y+i)) $x
        printf '%s' "$char"
    done
}

# Draw horizontal double line
tui.box.hline_double(){
    local y=$1 x=$2 length=$3
    tui.box.hline $y $x $length '═'
}

# Draw vertical double line
tui.box.vline_double(){
    local y=$1 x=$2 height=$3
    tui.box.vline $y $x $height '║'
}

# ============================================================================
# Box with Title
# ============================================================================

# Draw box with title on top border
tui.box.titled(){
    local y=$1 x=$2 w=$3 h=$4 title="$5"
    
    # Draw basic box
    tui.box.draw $y $x $w $h
    
    # Add title if provided
    if [[ -n $title ]]; then
        local title_len=${#title}
        local title_x=$((x + (w - title_len - 2) / 2))
        
        tui.cursor.move $y $title_x
        printf '┤ %s ├' "$title"
    fi
}

# Draw box with title on top border (double line)
tui.box.titled_double(){
    local y=$1 x=$2 w=$3 h=$4 title="$5"
    
    # Draw basic box
    tui.box.draw_double $y $x $w $h
    
    # Add title if provided
    if [[ -n $title ]]; then
        local title_len=${#title}
        local title_x=$((x + (w - title_len - 2) / 2))
        
        tui.cursor.move $y $title_x
        printf '╡ %s ╞' "$title"
    fi
}

# ============================================================================
# Box with Dividers
# ============================================================================

# Draw horizontal divider inside box
tui.box.divider_h(){
    local y=$1 x=$2 w=$3
    
    tui.cursor.move $y $x
    printf '├'
    local i
    for ((i=0; i<w-2; i++)); do
        printf '─'
    done
    printf '┤'
}

# Draw vertical divider inside box
tui.box.divider_v(){
    local y=$1 x=$2 h=$3
    
    local i
    for ((i=0; i<h; i++)); do
        if [ $i -eq 0 ]; then
            tui.cursor.move $((y+i)) $x
            printf '┬'
        elif [ $i -eq $((h-1)) ]; then
            tui.cursor.move $((y+i)) $x
            printf '┴'
        else
            tui.cursor.move $((y+i)) $x
            printf '│'
        fi
    done
}

# Draw cross (intersection)
tui.box.cross(){
    local y=$1 x=$2
    tui.cursor.move $y $x
    printf '┼'
}

# ============================================================================
# Specialty Boxes
# ============================================================================

# Draw a progress bar box
tui.box.progress(){
    local y=$1 x=$2 w=$3 percent=$4
    
    # Draw box
    tui.cursor.move $y $x
    printf '['
    
    # Calculate filled portion
    local bar_width=$((w - 2))
    local filled=$((bar_width * percent / 100))
    local empty=$((bar_width - filled))
    
    # Draw filled portion
    local i
    for ((i=0; i<filled; i++)); do
        printf '█'
    done
    
    # Draw empty portion
    for ((i=0; i<empty; i++)); do
        printf ' '
    done
    
    printf ']'
}

# Draw a shadow box (box with shadow effect)
tui.box.shadow(){
    local y=$1 x=$2 w=$3 h=$4
    
    # Draw main box
    tui.box.draw $y $x $w $h
    
    # Draw shadow (bottom and right)
    local i
    
    # Bottom shadow
    tui.cursor.move $((y+h)) $((x+1))
    for ((i=0; i<w; i++)); do
        printf '░'
    done
    
    # Right shadow
    for ((i=1; i<=h; i++)); do
        tui.cursor.move $((y+i)) $((x+w))
        printf '░'
    done
}

# Draw a panel (box with header)
tui.box.panel(){
    local y=$1 x=$2 w=$3 h=$4 title="$5"
    
    # Draw box
    tui.box.draw $y $x $w $h
    
    # Draw header separator
    tui.box.divider_h $((y+2)) $x $w
    
    # Add title in header
    if [[ -n $title ]]; then
        local title_len=${#title}
        local title_x=$((x + 2))
        tui.cursor.move $((y+1)) $title_x
        printf '%s' "$title"
    fi
}

# ============================================================================
# Utility Functions
# ============================================================================

# Draw text inside a box (centered)
tui.box.text_centered(){
    local y=$1 x=$2 w=$3 text="$4"
    
    local text_len=${#text}
    local text_x=$((x + (w - text_len) / 2))
    
    tui.cursor.move $y $text_x
    printf '%s' "$text"
}

# Draw text inside a box (left-aligned with padding)
tui.box.text_left(){
    local y=$1 x=$2 text="$3"
    local padding="${4:-2}"
    
    tui.cursor.move $y $((x + padding))
    printf '%s' "$text"
}

# Draw text inside a box (right-aligned with padding)
tui.box.text_right(){
    local y=$1 x=$2 w=$3 text="$4"
    local padding="${5:-2}"
    
    local text_len=${#text}
    local text_x=$((x + w - text_len - padding))
    
    tui.cursor.move $y $text_x
    printf '%s' "$text"
}

# Draw a window (box with title bar)
tui.box.window(){
    local y=$1 x=$2 w=$3 h=$4 title="$5"
    
    # Draw main box
    tui.box.draw $y $x $w $h
    
    # Draw title bar (filled header)
    tui.cursor.move $y $((x+1))
    local i
    for ((i=0; i<w-2; i++)); do
        printf '─'
    done
    
    # Add title
    if [[ -n $title ]]; then
        tui.box.text_centered $y $x $w " $title "
    fi
    
    # Draw title bar separator
    tui.box.divider_h $((y+1)) $x $w
}
