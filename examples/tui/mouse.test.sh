#!/bin/bash
# mouse.test.sh - Test mouse.class.bash functionality

# Load modules
. cursor.class.bash
. screen.class.bash
. color.class.bash
. box.class.bash
. input.class.bash
. mouse.class.bash

# Setup
tui.screen.alt
tui.cursor.hide

# Test 1: Basic mouse click detection
tui.screen.clear
tui.cursor.move 2 2
tui.color.bold
echo "Test 1: Basic Mouse Click Detection"
tui.color.reset

tui.cursor.move 4 4
echo "Click anywhere on the screen"
tui.cursor.move 5 4
echo "Press 'q' to continue to next test"

tui.mouse.enable

tui.cursor.move 7 4
echo "Waiting for clicks..."

# Event loop
while true; do
    # Try to read input (could be keyboard or mouse)
    char=
    if IFS= read -rsn1 -t 0.1 char; then
        # Check if it's ESC (start of mouse event or keyboard)
        if [[ $char == $'\033' ]]; then
            # Might be mouse event
            next=
            IFS= read -rsn1 -t 0.001 next
            if [[ $next == '[' ]]; then
                IFS= read -rsn1 -t 0.001 next
                if [[ $next == '<' ]]; then
                    # It's a mouse event - read the rest
                    data=""
                    action=
                    while IFS= read -rsn1 -t 0.001 char && [[ $char != [Mm] ]]; do
                        data+="$char"
                    done
                    action="$char"
                    
                    # Parse
                    button= x= y=
                    IFS=';' read -r button x y <<< "$data"
                    
                    # Display
                    tui.cursor.move 9 4
                    printf "%-60s" "Click detected at ($y, $x) - button: $button action: $action"
                    
                    # Mark the spot
                    tui.cursor.move $y $x
                    tui.color.red
                    printf "X"
                    tui.color.reset
                fi
            fi
        elif [[ $char == "q" ]]; then
            break
        fi
    fi
done

sleep 1

# Test 2: Click inside a box
tui.screen.clear
tui.cursor.move 2 2
tui.color.bold
echo "Test 2: Click Detection in Box"
tui.color.reset

tui.box.draw 5 10 40 10
tui.box.text_centered 7 10 40 "Click inside this box"
tui.box.text_centered 9 10 40 "Press 'q' to continue"

tui.cursor.move 16 10
echo "Status: Waiting for click..."

while true; do
    char=
    if IFS= read -rsn1 -t 0.1 char; then
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
                    
                    # Only check on press events
                    if [[ $action == "M" ]]; then
                        # Check if inside box (interior: rows 6-14, cols 11-49)
                        if [[ $y -ge 6 && $y -le 14 && $x -ge 11 && $x -lt 50 ]]; then
                            tui.cursor.move 16 10
                            tui.color.green
                            printf "%-60s" "✓ Click INSIDE box at ($y, $x)"
                            tui.color.reset
                        else
                            tui.cursor.move 16 10
                            tui.color.red
                            printf "%-60s" "✗ Click OUTSIDE box at ($y, $x)"
                            tui.color.reset
                        fi
                    fi
                fi
            fi
        elif [[ $char == "q" ]]; then
            break
        fi
    fi
done

sleep 1

# Test 3: Clickable buttons
tui.screen.clear
tui.cursor.move 2 2
tui.color.bold
echo "Test 3: Clickable Buttons"
tui.color.reset

# Draw three buttons
tui.box.draw 5 10 20 3
tui.box.text_centered 6 10 20 "Button 1"

tui.box.draw 5 35 20 3
tui.box.text_centered 6 35 20 "Button 2"

tui.box.draw 5 60 20 3
tui.box.text_centered 6 60 20 "Exit"

tui.cursor.move 10 10
echo "Click on a button..."

while true; do
    char=
    if IFS= read -rsn1 -t 0.1 char; then
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
                    
                    if [[ $action == "M" ]]; then
                        # Check Button 1 (rows 5-7, cols 10-29)
                        if [[ $y -ge 5 && $y -le 7 && $x -ge 10 && $x -lt 30 ]]; then
                            tui.cursor.move 12 10
                            tui.color.green
                            printf "%-60s" "Button 1 clicked!"
                            tui.color.reset
                        # Check Button 2 (rows 5-7, cols 35-54)
                        elif [[ $y -ge 5 && $y -le 7 && $x -ge 35 && $x -lt 55 ]]; then
                            tui.cursor.move 12 10
                            tui.color.yellow
                            printf "%-60s" "Button 2 clicked!"
                            tui.color.reset
                        # Check Exit button (rows 5-7, cols 60-79)
                        elif [[ $y -ge 5 && $y -le 7 && $x -ge 60 && $x -lt 80 ]]; then
                            tui.cursor.move 12 10
                            tui.color.red
                            printf "Exit button clicked! Exiting..."
                            tui.color.reset
                            echo
                            sleep 1
                            break
                        fi
                    fi
                fi
            fi
        fi
    fi
done

sleep 1

# Test 4: Mouse event details
tui.screen.clear
tui.cursor.move 2 2
tui.color.bold
echo "Test 4: Mouse Event Details"
tui.color.reset

tui.cursor.move 4 4
echo "Try different mouse actions:"
tui.cursor.move 5 6
echo "• Left click"
tui.cursor.move 6 6
echo "• Right click"
tui.cursor.move 7 6
echo "• Scroll wheel"
tui.cursor.move 8 6
echo "• Click with Shift/Ctrl/Alt (if your terminal supports it)"
tui.cursor.move 10 4
echo "Press 'q' to continue"

tui.cursor.move 12 4
echo "Event details:"

while true; do
    char=
    if IFS= read -rsn1 -t 0.1 char; then
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
                    
                    # Decode button
                    btn=$((button & 3))
                    shift=$((button & 4))
                    meta=$((button & 8))
                    ctrl=$((button & 16))
                    motion=$((button & 64))
                    
                    # Button name
                    btn_name=
                    case $btn in
                        0) btn_name="Left" ;;
                        1) btn_name="Middle" ;;
                        2) btn_name="Right" ;;
                        3) btn_name="Release" ;;
                    esac
                    
                    # Check for scroll
                    if [[ $button -eq 64 ]]; then btn_name="Scroll Up"; fi
                    if [[ $button -eq 65 ]]; then btn_name="Scroll Down"; fi
                    
                    # Action
                    act_name=
                    if [[ $action == "M" ]]; then
                        act_name="Press"
                    else
                        act_name="Release"
                    fi
                    
                    # Display
                    tui.cursor.move 14 4
                    printf "%-70s" "Button: $btn_name ($btn) | Action: $act_name | Position: ($y, $x)"
                    
                    tui.cursor.move 15 4
                    mods=""
                    [[ $shift -ne 0 ]] && mods+="Shift "
                    [[ $meta -ne 0 ]] && mods+="Meta "
                    [[ $ctrl -ne 0 ]] && mods+="Ctrl "
                    [[ $motion -ne 0 ]] && mods+="Motion "
                    [[ -z $mods ]] && mods="None"
                    printf "%-70s" "Modifiers: $mods"
                fi
            fi
        elif [[ $char == "q" ]]; then
            break
        fi
    fi
done

sleep 1

# Test 5: Drawing with mouse
tui.screen.clear
tui.cursor.move 2 2
tui.color.bold
echo "Test 5: Draw with Mouse"
tui.color.reset

tui.box.draw 5 5 70 15

tui.cursor.move 4 5
echo "Click and drag to draw (hold left button and move)"
tui.cursor.move 21 5
echo "Press 'q' to exit"

tui.cursor.move 22 5
echo "Debug: button value="

# Enable motion tracking for drag
tui.mouse.enable_motion

while true; do
    char=
    if IFS= read -rsn1 -t 0.1 char; then
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
                    
                    # Debug - show button value
                    tui.cursor.move 22 25
                    printf "%-20s" "$button at ($y,$x) action=$action"
                    
                    # Draw on press OR motion with button held (button 32 or 64 = motion with left button)
                    if [[ ($button -eq 0 || $button -eq 32 || $button -eq 64) && $action == "M" ]]; then
                        # Check if inside box
                        if [[ $y -gt 5 && $y -lt 20 && $x -gt 5 && $x -lt 75 ]]; then
                            tui.cursor.move $y $x
                            tui.color.cyan
                            printf "●"
                            tui.color.reset
                        fi
                    fi
                fi
            fi
        elif [[ $char == "q" ]]; then
            break
        fi
    fi
done

# Disable motion tracking
tui.mouse.disable
tui.cursor.show
tui.screen.clear

tui.cursor.move 10 5
tui.color.green
tui.color.bold
echo "All mouse tests complete!"
tui.color.reset

tui.cursor.move 12 5
echo "Press any key to exit..."
read -n1

tui.screen.main
