#!/bin/bash
# nano.sh - A minimal text editor using ba.sh TUI library

# Load TUI modules
. ../tui/cursor.class.bash
. ../tui/screen.class.bash
. ../tui/color.class.bash
. ../tui/box.class.bash
. ../tui/input.class.bash

# Editor configuration
EDITOR_NAME="nano.sh"
STATUS_BAR_ROW=1
EDITOR_START_ROW=3
HELP_BAR_ROW=0  # Will be set based on terminal size

# File state
FILENAME=""
declare -a LINES
MODIFIED=0

# Cursor position (in file coordinates)
CURSOR_ROW=0
CURSOR_COL=0

# Viewport (which part of file is visible)
VIEWPORT_TOP=0
VIEWPORT_LEFT=0
VIEWPORT_HEIGHT=20  # Will be set based on terminal size
VIEWPORT_WIDTH=80   # Will be set based on terminal size

# Initialize editor
init_editor(){
    local file=$1
    
    FILENAME="$file"
    LINES=()
    MODIFIED=0
    CURSOR_ROW=0
    CURSOR_COL=0
    VIEWPORT_TOP=0
    VIEWPORT_LEFT=0
    
    # Get terminal size
    local size=$(tui.screen.size)
    local rows=${size% *}
    local cols=${size#* }
    
    VIEWPORT_HEIGHT=$((rows - 4))  # Leave room for status and help bars
    VIEWPORT_WIDTH=$((cols - 1))
    HELP_BAR_ROW=$((rows - 1))
    
    # Load file if it exists
    if [ -f "$FILENAME" ]; then
        local i=0
        while IFS= read -r line; do
            LINES[$i]="$line"
            ((i++))
        done < "$FILENAME"
        
        # Ensure at least one line
        if [ ${#LINES[@]} -eq 0 ]; then
            LINES[0]=""
        fi
    else
        # New file - start with one empty line
        LINES[0]=""
    fi
}

# Save file
save_file(){
    # Write all lines to file
    printf "%s\n" "${LINES[@]}" > "$FILENAME"
    MODIFIED=0
}

# Get visible line (with viewport offset)
get_visible_line(){
    local file_row=$1
    local line="${LINES[$file_row]}"
    
    # Apply horizontal scroll
    if [ ${#line} -gt $VIEWPORT_LEFT ]; then
        line="${line:$VIEWPORT_LEFT:$VIEWPORT_WIDTH}"
    else
        line=""
    fi
    
    echo "$line"
}

# Draw the editor content
draw_content(){
    local screen_row=$EDITOR_START_ROW
    
    for ((i=0; i<VIEWPORT_HEIGHT; i++)); do
        local file_row=$((VIEWPORT_TOP + i))
        
        tui.cursor.move $screen_row 1
        tui.color.reset
        
        # Clear line
        printf "%${VIEWPORT_WIDTH}s" ""
        
        tui.cursor.move $screen_row 1
        
        if [ $file_row -lt ${#LINES[@]} ]; then
            # Show line content
            local line=$(get_visible_line $file_row)
            printf "%s" "$line"
        else
            # Show tilde for lines beyond end of file
            tui.color.blue
            printf "~"
            tui.color.reset
        fi
        
        ((screen_row++))
    done
}

# Draw status bar
draw_status_bar(){
    tui.cursor.move $STATUS_BAR_ROW 1
    tui.color.reverse
    
    # Build status - show filename
    local status="  $FILENAME"
    
    # Show current state
    if [ $MODIFIED -eq 1 ]; then
        status+=" [Modified]"
    else
        status+=" [Saved]"
    fi
    
    # Position info
    local pos_info="Ln $((CURSOR_ROW + 1)), Col $((CURSOR_COL + 1))"
    
    # Pad and show
    local padding=$((VIEWPORT_WIDTH - ${#status} - ${#pos_info}))
    printf "%s%${padding}s%s" "$status" "" "$pos_info"
    
    tui.color.reset
}

# Draw help bar
draw_help_bar(){
    tui.cursor.move $HELP_BAR_ROW 1
    tui.color.black
    tui.color.bg_white
    
    printf "^X Exit  ^O Save  ^W Search  Arrow keys to move"
    printf "%$((VIEWPORT_WIDTH - 48))s" ""
    
    tui.color.reset
}

# Draw entire screen
draw_screen(){
    tui.screen.clear
    draw_status_bar
    draw_content
    draw_help_bar
    update_cursor_position
}

# Update cursor position on screen
update_cursor_position(){
    local screen_row=$((EDITOR_START_ROW + CURSOR_ROW - VIEWPORT_TOP))
    local screen_col=$((1 + CURSOR_COL - VIEWPORT_LEFT))
    
    tui.cursor.move $screen_row $screen_col
}

# Adjust viewport to keep cursor visible
adjust_viewport(){
    # Vertical scrolling
    if [ $CURSOR_ROW -lt $VIEWPORT_TOP ]; then
        VIEWPORT_TOP=$CURSOR_ROW
    elif [ $CURSOR_ROW -ge $((VIEWPORT_TOP + VIEWPORT_HEIGHT)) ]; then
        VIEWPORT_TOP=$((CURSOR_ROW - VIEWPORT_HEIGHT + 1))
    fi
    
    # Horizontal scrolling
    if [ $CURSOR_COL -lt $VIEWPORT_LEFT ]; then
        VIEWPORT_LEFT=$CURSOR_COL
    elif [ $CURSOR_COL -ge $((VIEWPORT_LEFT + VIEWPORT_WIDTH)) ]; then
        VIEWPORT_LEFT=$((CURSOR_COL - VIEWPORT_WIDTH + 1))
    fi
}

# Move cursor
move_cursor(){
    local direction=$1
    
    case $direction in
        UP)
            if [ $CURSOR_ROW -gt 0 ]; then
                ((CURSOR_ROW--))
                # Clamp column to line length
                local line_len=${#LINES[$CURSOR_ROW]}
                if [ $CURSOR_COL -gt $line_len ]; then
                    CURSOR_COL=$line_len
                fi
            fi
            ;;
        DOWN)
            if [ $CURSOR_ROW -lt $((${#LINES[@]} - 1)) ]; then
                ((CURSOR_ROW++))
                # Clamp column to line length
                local line_len=${#LINES[$CURSOR_ROW]}
                if [ $CURSOR_COL -gt $line_len ]; then
                    CURSOR_COL=$line_len
                fi
            fi
            ;;
        LEFT)
            if [ $CURSOR_COL -gt 0 ]; then
                ((CURSOR_COL--))
            elif [ $CURSOR_ROW -gt 0 ]; then
                # Move to end of previous line
                ((CURSOR_ROW--))
                CURSOR_COL=${#LINES[$CURSOR_ROW]}
            fi
            ;;
        RIGHT)
            local line_len=${#LINES[$CURSOR_ROW]}
            if [ $CURSOR_COL -lt $line_len ]; then
                ((CURSOR_COL++))
            elif [ $CURSOR_ROW -lt $((${#LINES[@]} - 1)) ]; then
                # Move to start of next line
                ((CURSOR_ROW++))
                CURSOR_COL=0
            fi
            ;;
        HOME)
            CURSOR_COL=0
            ;;
        END)
            CURSOR_COL=${#LINES[$CURSOR_ROW]}
            ;;
    esac
    
    adjust_viewport
}

# Insert character at cursor
insert_char(){
    local char=$1
    local line="${LINES[$CURSOR_ROW]}"
    
    # Insert character
    LINES[$CURSOR_ROW]="${line:0:$CURSOR_COL}${char}${line:$CURSOR_COL}"
    
    # Move cursor forward
    ((CURSOR_COL++))
    MODIFIED=1
    
    adjust_viewport
}

# Handle backspace
handle_backspace(){
    if [ $CURSOR_COL -gt 0 ]; then
        # Delete character before cursor
        local line="${LINES[$CURSOR_ROW]}"
        LINES[$CURSOR_ROW]="${line:0:$((CURSOR_COL-1))}${line:$CURSOR_COL}"
        ((CURSOR_COL--))
        MODIFIED=1
    elif [ $CURSOR_ROW -gt 0 ]; then
        # Join with previous line
        local prev_len=${#LINES[$((CURSOR_ROW - 1))]}
        LINES[$((CURSOR_ROW - 1))]+="${LINES[$CURSOR_ROW]}"
        
        # Remove current line
        unset LINES[$CURSOR_ROW]
        LINES=("${LINES[@]}")  # Re-index array
        
        # Move cursor
        ((CURSOR_ROW--))
        CURSOR_COL=$prev_len
        MODIFIED=1
    fi
    
    adjust_viewport
}

# Handle delete key
handle_delete(){
    local line="${LINES[$CURSOR_ROW]}"
    local line_len=${#line}
    
    if [ $CURSOR_COL -lt $line_len ]; then
        # Delete character at cursor
        LINES[$CURSOR_ROW]="${line:0:$CURSOR_COL}${line:$((CURSOR_COL+1))}"
        MODIFIED=1
    elif [ $CURSOR_ROW -lt $((${#LINES[@]} - 1)) ]; then
        # Join with next line
        LINES[$CURSOR_ROW]+="${LINES[$((CURSOR_ROW + 1))]}"
        
        # Remove next line
        unset LINES[$((CURSOR_ROW + 1))]
        LINES=("${LINES[@]}")  # Re-index array
        MODIFIED=1
    fi
}

# Handle enter key
handle_enter(){
    local line="${LINES[$CURSOR_ROW]}"
    
    # Split line at cursor
    local before="${line:0:$CURSOR_COL}"
    local after="${line:$CURSOR_COL}"
    
    LINES[$CURSOR_ROW]="$before"
    
    # Insert new line after current
    local new_lines=()
    for ((i=0; i<=CURSOR_ROW; i++)); do
        new_lines+=("${LINES[$i]}")
    done
    new_lines+=("$after")
    for ((i=CURSOR_ROW+1; i<${#LINES[@]}; i++)); do
        new_lines+=("${LINES[$i]}")
    done
    LINES=("${new_lines[@]}")
    
    # Move cursor to start of new line
    ((CURSOR_ROW++))
    CURSOR_COL=0
    MODIFIED=1
    
    adjust_viewport
}

# Main editor loop
editor_loop(){
    draw_screen
    
    while true; do
        # Read key
        local key=$(tui.input.key)
        
        case "$key" in
            # Navigation
            UP|DOWN|LEFT|RIGHT|HOME|END)
                move_cursor "$key"
                draw_content
                draw_status_bar
                update_cursor_position
                ;;
            
            # Enter
            ENTER)
                handle_enter
                draw_screen
                ;;
            
            # Backspace
            BACKSPACE)
                handle_backspace
                draw_screen
                ;;
            
            # Delete
            DELETE)
                handle_delete
                draw_screen
                ;;
            
            # Save (Ctrl+O)
            CTRL-O)
                save_file
                draw_status_bar
                update_cursor_position
                ;;
            
            # Exit (Ctrl+X)
            CTRL-X)
                if [ $MODIFIED -eq 1 ]; then
                    # TODO: Ask to save
                    save_file
                fi
                break
                ;;
            
            # Regular character
            *)
                # Only accept printable characters
                if [ ${#key} -eq 1 ]; then
                    insert_char "$key"
                    draw_content
                    draw_status_bar
                    update_cursor_position
                fi
                ;;
        esac
    done
}

# Main
if [ -z "$1" ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

# Disable XON/XOFF flow control (Ctrl+S/Ctrl+Q)
stty -ixon

tui.screen.alt
tui.cursor.show

init_editor "$1"
editor_loop

# Cleanup
tui.screen.clear
tui.cursor.show
tui.screen.main

# Re-enable flow control
stty ixon
