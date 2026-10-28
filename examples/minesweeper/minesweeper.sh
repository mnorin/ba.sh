#!/bin/bash
# minesweeper.sh - Classic Minesweeper game using ba.sh TUI library

# Load TUI modules
. ../tui/cursor.class.bash
. ../tui/screen.class.bash
. ../tui/color.class.bash
. ../tui/box.class.bash
. ../tui/input.class.bash
. ../tui/mouse.class.bash

# Game configuration
GRID_ROWS=10
GRID_COLS=10
MINE_COUNT=15
CELL_WIDTH=3
CELL_HEIGHT=1

# Starting position for grid
GRID_START_ROW=5
GRID_START_COL=5

# Game state arrays
declare -a MINES        # 1 if mine, 0 if not
declare -a REVEALED     # 1 if revealed, 0 if not
declare -a FLAGGED      # 1 if flagged, 0 if not
declare -a NEIGHBORS    # Count of neighboring mines

GAME_OVER=0
GAME_WON=0

# Initialize game
init_game(){
    # Clear arrays
    MINES=()
    REVEALED=()
    FLAGGED=()
    NEIGHBORS=()
    
    # Initialize all cells
    local total=$((GRID_ROWS * GRID_COLS))
    for ((i=0; i<total; i++)); do
        MINES[$i]=0
        REVEALED[$i]=0
        FLAGGED[$i]=0
        NEIGHBORS[$i]=0
    done
    
    # Place mines randomly
    local placed=0
    while [ $placed -lt $MINE_COUNT ]; do
        local idx=$((RANDOM % total))
        if [ ${MINES[$idx]} -eq 0 ]; then
            MINES[$idx]=1
            ((placed++))
        fi
    done
    
    # Calculate neighbor counts
    for ((row=0; row<GRID_ROWS; row++)); do
        for ((col=0; col<GRID_COLS; col++)); do
            local idx=$((row * GRID_COLS + col))
            if [ ${MINES[$idx]} -eq 0 ]; then
                local count=0
                # Check all 8 neighbors
                for ((dr=-1; dr<=1; dr++)); do
                    for ((dc=-1; dc<=1; dc++)); do
                        if [ $dr -eq 0 ] && [ $dc -eq 0 ]; then
                            continue
                        fi
                        local nr=$((row + dr))
                        local nc=$((col + dc))
                        if [ $nr -ge 0 ] && [ $nr -lt $GRID_ROWS ] && [ $nc -ge 0 ] && [ $nc -lt $GRID_COLS ]; then
                            local nidx=$((nr * GRID_COLS + nc))
                            if [ ${MINES[$nidx]} -eq 1 ]; then
                                ((count++))
                            fi
                        fi
                    done
                done
                NEIGHBORS[$idx]=$count
            fi
        done
    done
    
    GAME_OVER=0
    GAME_WON=0
}

# Get cell position on screen
get_cell_screen_pos(){
    local row=$1
    local col=$2
    local screen_row=$((GRID_START_ROW + row))
    local screen_col=$((GRID_START_COL + col * CELL_WIDTH))
    echo "$screen_row $screen_col"
}

# Get cell from screen coordinates
get_cell_from_screen(){
    local screen_row=$1
    local screen_col=$2
    
    # Check if in grid area
    local row=$((screen_row - GRID_START_ROW))
    local col=$(( (screen_col - GRID_START_COL) / CELL_WIDTH ))
    
    if [ $row -ge 0 ] && [ $row -lt $GRID_ROWS ] && [ $col -ge 0 ] && [ $col -lt $GRID_COLS ]; then
        echo "$row $col"
        return 0
    fi
    
    return 1
}

# Draw a single cell
draw_cell(){
    local row=$1
    local col=$2
    local idx=$((row * GRID_COLS + col))
    
    local pos=$(get_cell_screen_pos $row $col)
    local screen_row=${pos% *}
    local screen_col=${pos#* }
    
    tui.cursor.move $screen_row $screen_col
    
    if [ ${REVEALED[$idx]} -eq 1 ]; then
        # Revealed cell
        if [ ${MINES[$idx]} -eq 1 ]; then
            # Mine - red
            tui.color.bg_red
            tui.color.white
            printf " * "
            tui.color.reset
        else
            # Number or empty
            local count=${NEIGHBORS[$idx]}
            tui.color.bg_white
            if [ $count -eq 0 ]; then
                tui.color.black
                printf "   "
            else
                # Color based on number
                case $count in
                    1) tui.color.blue ;;
                    2) tui.color.green ;;
                    3) tui.color.red ;;
                    4) tui.color.magenta ;;
                    *) tui.color.black ;;
                esac
                printf " %d " $count
            fi
            tui.color.reset
        fi
    elif [ ${FLAGGED[$idx]} -eq 1 ]; then
        # Flagged cell - yellow
        tui.color.bg_yellow
        tui.color.black
        printf " F "
        tui.color.reset
    else
        # Unrevealed cell - gray
        tui.color.bg_bright_black
        printf "   "
        tui.color.reset
    fi
}

# Draw entire grid
draw_grid(){
    for ((row=0; row<GRID_ROWS; row++)); do
        for ((col=0; col<GRID_COLS; col++)); do
            draw_cell $row $col
        done
    done
}

# Reveal cell (with flood fill for empty cells)
reveal_cell(){
    local start_row=$1
    local start_col=$2
    local start_idx=$((start_row * GRID_COLS + start_col))
    
    # Already revealed or flagged
    if [ ${REVEALED[$start_idx]} -eq 1 ] || [ ${FLAGGED[$start_idx]} -eq 1 ]; then
        return
    fi
    
    # Hit a mine
    if [ ${MINES[$start_idx]} -eq 1 ]; then
        REVEALED[$start_idx]=1
        GAME_OVER=1
        return
    fi
    
    # Use queue for flood fill (iterative, not recursive)
    local queue=("$start_row $start_col")
    
    while [ ${#queue[@]} -gt 0 ]; do
        # Pop from queue
        local cell="${queue[0]}"
        queue=("${queue[@]:1}")
        
        local row=${cell% *}
        local col=${cell#* }
        local idx=$((row * GRID_COLS + col))
        
        # Skip if already revealed
        if [ ${REVEALED[$idx]} -eq 1 ]; then
            continue
        fi
        
        # Skip if flagged
        if [ ${FLAGGED[$idx]} -eq 1 ]; then
            continue
        fi
        
        # Reveal this cell
        REVEALED[$idx]=1
        
        # If this cell has neighbors, don't add its neighbors to queue
        if [ ${NEIGHBORS[$idx]} -ne 0 ]; then
            continue
        fi
        
        # This cell is empty (0 neighbors), add all unrevealed neighbors to queue
        for ((dr=-1; dr<=1; dr++)); do
            for ((dc=-1; dc<=1; dc++)); do
                if [ $dr -eq 0 ] && [ $dc -eq 0 ]; then
                    continue
                fi
                local nr=$((row + dr))
                local nc=$((col + dc))
                if [ $nr -ge 0 ] && [ $nr -lt $GRID_ROWS ] && [ $nc -ge 0 ] && [ $nc -lt $GRID_COLS ]; then
                    local nidx=$((nr * GRID_COLS + nc))
                    # Add to queue if not revealed and not already in queue
                    if [ ${REVEALED[$nidx]} -eq 0 ]; then
                        queue+=("$nr $nc")
                    fi
                fi
            done
        done
    done
}

# Toggle flag
toggle_flag(){
    local row=$1
    local col=$2
    local idx=$((row * GRID_COLS + col))
    
    # Can't flag revealed cells
    if [ ${REVEALED[$idx]} -eq 1 ]; then
        return
    fi
    
    if [ ${FLAGGED[$idx]} -eq 1 ]; then
        FLAGGED[$idx]=0
    else
        FLAGGED[$idx]=1
    fi
}

# Check win condition
check_win(){
    local total=$((GRID_ROWS * GRID_COLS))
    local revealed_count=0
    
    for ((i=0; i<total; i++)); do
        if [ ${REVEALED[$i]} -eq 1 ]; then
            ((revealed_count++))
        fi
    done
    
    # Win if all non-mine cells are revealed
    if [ $revealed_count -eq $((total - MINE_COUNT)) ]; then
        GAME_WON=1
    fi
}

# Reveal all mines (game over)
reveal_all_mines(){
    for ((row=0; row<GRID_ROWS; row++)); do
        for ((col=0; col<GRID_COLS; col++)); do
            local idx=$((row * GRID_COLS + col))
            if [ ${MINES[$idx]} -eq 1 ]; then
                REVEALED[$idx]=1
            fi
        done
    done
}

# Draw UI
draw_ui(){
    tui.screen.clear
    
    tui.cursor.move 1 5
    tui.color.bold
    echo "MINESWEEPER"
    tui.color.reset
    
    tui.cursor.move 2 5
    echo "Mines: $MINE_COUNT | Left-click: Reveal | Right-click: Flag | Q: Quit"
    
    # Draw grid border
    local grid_width=$((GRID_COLS * CELL_WIDTH + 2))
    local grid_height=$((GRID_ROWS + 2))
    tui.box.draw $((GRID_START_ROW - 1)) $((GRID_START_COL - 1)) $grid_width $grid_height
    
    draw_grid
    
    # Status area
    tui.cursor.move $((GRID_START_ROW + grid_height + 1)) 5
    if [ $GAME_OVER -eq 1 ]; then
        tui.color.red
        tui.color.bold
        echo "GAME OVER! You hit a mine. Press R to restart or Q to quit."
        tui.color.reset
    elif [ $GAME_WON -eq 1 ]; then
        tui.color.green
        tui.color.bold
        echo "YOU WIN! All mines found. Press R to restart or Q to quit."
        tui.color.reset
    else
        echo "Click to reveal, right-click to flag"
    fi
}

# Main game loop
game_loop(){
    while true; do
        draw_ui
        
        # Read input
        char=
        if IFS= read -rsn1 -t 0.1 char; then
            # Check for keyboard input
            if [[ $char == "q" ]] || [[ $char == "Q" ]]; then
                break
            elif [[ $char == "r" ]] || [[ $char == "R" ]]; then
                init_game
                continue
            fi
            
            # Check for mouse event
            if [[ $char == $'\033' ]]; then
                next=
                IFS= read -rsn1 -t 0.001 next
                if [[ $next == '[' ]]; then
                    IFS= read -rsn1 -t 0.001 next
                    if [[ $next == '<' ]]; then
                        data=""
                        action=
                        while IFS= read -rsn1 -t 0.001 char && [[ $char != [Mm] ]]; do
                            data+="$char"
                        done
                        action="$char"
                        
                        button= x= y=
                        IFS=';' read -r button x y <<< "$data"
                        
                        # Only process on click (press)
                        if [[ $action == "M" ]] && [ $GAME_OVER -eq 0 ] && [ $GAME_WON -eq 0 ]; then
                            # Get cell coordinates
                            cell_pos=$(get_cell_from_screen $y $x)
                            if [ $? -eq 0 ]; then
                                cell_row=${cell_pos% *}
                                cell_col=${cell_pos#* }
                                
                                if [ $button -eq 0 ]; then
                                    # Left click - reveal
                                    reveal_cell $cell_row $cell_col
                                    if [ $GAME_OVER -eq 1 ]; then
                                        reveal_all_mines
                                    else
                                        check_win
                                    fi
                                elif [ $button -eq 2 ]; then
                                    # Right click - flag
                                    toggle_flag $cell_row $cell_col
                                fi
                            fi
                        fi
                    fi
                fi
            fi
        fi
    done
}

# Main
tui.screen.alt
tui.cursor.hide
tui.mouse.enable

init_game
game_loop

# Cleanup
tui.mouse.disable
tui.cursor.show
tui.screen.main
