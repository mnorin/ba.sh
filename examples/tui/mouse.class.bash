# mouse.class.bash - Mouse tracking and event handling for ba.sh TUI library
# No dependencies

# Prevent double-loading
[[ -n $TUI_MOUSE_LOADED ]] && return
TUI_MOUSE_LOADED=1

# ============================================================================
# Mouse Mode Control
# ============================================================================

# Enable mouse tracking (basic button events)
tui.mouse.enable(){
    printf '\033[?1000h'  # Enable mouse tracking
    printf '\033[?1006h'  # Enable SGR extended mode
}

# Disable mouse tracking
tui.mouse.disable(){
    printf '\033[?1006l'  # Disable SGR mode
    printf '\033[?1000l'  # Disable mouse tracking
}

# Enable button event tracking (press and release)
tui.mouse.enable_buttons(){
    printf '\033[?1002h'  # Button event tracking
    printf '\033[?1006h'  # SGR mode
}

# Enable all events including motion
tui.mouse.enable_motion(){
    printf '\033[?1003h'  # Any event tracking
    printf '\033[?1006h'  # SGR mode
}

# Enable focus events
tui.mouse.enable_focus(){
    printf '\033[?1004h'
}

# Disable focus events
tui.mouse.disable_focus(){
    printf '\033[?1004l'
}

# ============================================================================
# Mouse Event Reading
# ============================================================================

# Read a mouse event (blocking)
# Returns: button x y action (space-separated)
# Example: "0 10 5 M" = left button press at column 10, row 5
tui.mouse.read(){
    local char seq button x y action
    
    # Read escape sequence
    IFS= read -rsn1 char
    
    if [[ $char == $'\033' ]]; then
        IFS= read -rsn1 char
        if [[ $char == '[' ]]; then
            IFS= read -rsn1 char
            if [[ $char == '<' ]]; then
                # SGR mouse event: ESC[<button;x;y[Mm]
                local data=""
                while IFS= read -rsn1 char && [[ $char != [Mm] ]]; do
                    data+="$char"
                done
                action="$char"
                
                # Parse button;x;y
                IFS=';' read -r button x y <<< "$data"
                
                echo "$button $x $y $action"
                return 0
            fi
        fi
    fi
    
    # Not a mouse event
    return 1
}

# Read mouse event with timeout (seconds)
tui.mouse.read_timeout(){
    local timeout=$1
    local char seq button x y action
    
    # Read with timeout
    if ! IFS= read -rsn1 -t "$timeout" char; then
        return 1
    fi
    
    if [[ $char == $'\033' ]]; then
        IFS= read -rsn1 -t 0.001 char
        if [[ $char == '[' ]]; then
            IFS= read -rsn1 -t 0.001 char
            if [[ $char == '<' ]]; then
                # SGR mouse event
                local data=""
                while IFS= read -rsn1 -t 0.001 char && [[ $char != [Mm] ]]; do
                    data+="$char"
                done
                action="$char"
                
                IFS=';' read -r button x y <<< "$data"
                
                echo "$button $x $y $action"
                return 0
            fi
        fi
    fi
    
    return 1
}

# ============================================================================
# Mouse Event Parsing
# ============================================================================

# Parse mouse event into components
# Usage: tui.mouse.parse "0 10 5 M"
# Sets global variables: MOUSE_BUTTON MOUSE_X MOUSE_Y MOUSE_ACTION 
#                        MOUSE_SHIFT MOUSE_META MOUSE_CTRL MOUSE_MOTION
tui.mouse.parse(){
    local event="$1"
    local button x y action
    
    read button x y action <<< "$event"
    
    # Decode button
    MOUSE_BUTTON=$((button & 3))
    MOUSE_MOTION=$((button & 64))
    MOUSE_SHIFT=$((button & 4))
    MOUSE_META=$((button & 8))
    MOUSE_CTRL=$((button & 16))
    
    # Coordinates
    MOUSE_X=$x
    MOUSE_Y=$y
    
    # Action (M = press, m = release)
    MOUSE_ACTION=$action
}

# Get button name from button number
tui.mouse.button_name(){
    local button=$1
    
    case $button in
        0) echo "LEFT" ;;
        1) echo "MIDDLE" ;;
        2) echo "RIGHT" ;;
        3) echo "RELEASE" ;;
        4) echo "SCROLL_UP" ;;
        5) echo "SCROLL_DOWN" ;;
        6) echo "SCROLL_LEFT" ;;
        7) echo "SCROLL_RIGHT" ;;
        *) echo "UNKNOWN" ;;
    esac
}

# Get full button description with modifiers
tui.mouse.describe(){
    local event="$1"
    tui.mouse.parse "$event"
    
    local desc=""
    
    # Modifiers
    [[ $MOUSE_SHIFT -ne 0 ]] && desc+="Shift+"
    [[ $MOUSE_META -ne 0 ]] && desc+="Meta+"
    [[ $MOUSE_CTRL -ne 0 ]] && desc+="Ctrl+"
    
    # Motion
    if [[ $MOUSE_MOTION -ne 0 ]]; then
        desc+="Motion("
        desc+=$(tui.mouse.button_name $MOUSE_BUTTON)
        desc+=")"
    else
        desc+=$(tui.mouse.button_name $MOUSE_BUTTON)
    fi
    
    # Action
    if [[ $MOUSE_ACTION == "M" ]]; then
        desc+=" Press"
    else
        desc+=" Release"
    fi
    
    # Coordinates
    desc+=" at ($MOUSE_Y,$MOUSE_X)"
    
    echo "$desc"
}

# ============================================================================
# Hit Testing
# ============================================================================

# Check if mouse click is inside a rectangular area
# Usage: tui.mouse.in_rect row col width height mouse_event
# Returns: 0 if inside, 1 if outside
tui.mouse.in_rect(){
    local rect_y=$1 rect_x=$2 rect_w=$3 rect_h=$4 event="$5"
    
    tui.mouse.parse "$event"
    
    [[ $MOUSE_X -ge $rect_x ]] && \
    [[ $MOUSE_X -lt $((rect_x + rect_w)) ]] && \
    [[ $MOUSE_Y -ge $rect_y ]] && \
    [[ $MOUSE_Y -lt $((rect_y + rect_h)) ]]
}

# Check if mouse is in a button (same as rect but clearer name)
tui.mouse.in_button(){
    tui.mouse.in_rect "$@"
}

# Check if this is a left click
tui.mouse.is_left_click(){
    local event="$1"
    tui.mouse.parse "$event"
    
    [[ $MOUSE_BUTTON -eq 0 ]] && [[ $MOUSE_ACTION == "M" ]]
}

# Check if this is a right click
tui.mouse.is_right_click(){
    local event="$1"
    tui.mouse.parse "$event"
    
    [[ $MOUSE_BUTTON -eq 2 ]] && [[ $MOUSE_ACTION == "M" ]]
}

# Check if this is a scroll up
tui.mouse.is_scroll_up(){
    local event="$1"
    tui.mouse.parse "$event"
    
    [[ $MOUSE_BUTTON -eq 4 ]]
}

# Check if this is a scroll down
tui.mouse.is_scroll_down(){
    local event="$1"
    tui.mouse.parse "$event"
    
    [[ $MOUSE_BUTTON -eq 5 ]]
}

# Check if this is a release event
tui.mouse.is_release(){
    local event="$1"
    tui.mouse.parse "$event"
    
    [[ $MOUSE_ACTION == "m" ]]
}

# Check if this is a press event
tui.mouse.is_press(){
    local event="$1"
    tui.mouse.parse "$event"
    
    [[ $MOUSE_ACTION == "M" ]]
}

# ============================================================================
# Utility Functions
# ============================================================================

# Wait for a mouse click
# Returns the mouse event
tui.mouse.wait_click(){
    while true; do
        local event=$(tui.mouse.read)
        if tui.mouse.is_press "$event"; then
            echo "$event"
            return 0
        fi
    done
}

# Wait for a click in a specific area
# Usage: tui.mouse.wait_click_in row col width height
tui.mouse.wait_click_in(){
    local rect_y=$1 rect_x=$2 rect_w=$3 rect_h=$4
    
    while true; do
        local event=$(tui.mouse.read)
        if tui.mouse.is_press "$event" && tui.mouse.in_rect $rect_y $rect_x $rect_w $rect_h "$event"; then
            echo "$event"
            return 0
        fi
    done
}
