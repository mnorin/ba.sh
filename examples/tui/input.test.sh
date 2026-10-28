#!/bin/bash
# input.test.sh - Test input.class.bash functionality

# Load modules
. cursor.class.bash
. screen.class.bash
. color.class.bash
. box.class.bash
. input.class.bash

# Setup
tui.screen.alt
tui.screen.clear

# Test 1: Basic character input
tui.cursor.move 2 2
tui.color.bold
echo "Test 1: Single Character Input"
tui.color.reset

tui.cursor.move 4 4
echo "Press any key..."
char=$(tui.input.char)
tui.cursor.move 5 4
echo "You pressed: '$char'"
sleep 2

# Test 2: Special key detection
tui.screen.clear
tui.cursor.move 2 2
tui.color.bold
echo "Test 2: Special Key Detection"
tui.color.reset

tui.cursor.move 4 4
echo "Press arrow keys, function keys, or special keys"
tui.cursor.move 5 4
echo "Press 'q' to continue to next test"
tui.cursor.move 7 4

row=7
while true; do
    key=$(tui.input.key)
    
    if [[ $key == "q" ]]; then
        break
    fi
    
    tui.cursor.move $row 4
    printf "%-60s" "Key detected: $key"
    
    row=$((row + 1))
    if [ $row -gt 20 ]; then
        row=7
    fi
done

sleep 1

# Test 3: Arrow key navigation
tui.screen.clear
tui.cursor.move 2 2
tui.color.bold
echo "Test 3: Arrow Key Navigation"
tui.color.reset

# Hide cursor for this test
tui.cursor.hide

tui.box.draw 5 10 60 15

# Draw a cursor that can be moved
cx=30
cy=10

tui.cursor.move 4 10
echo "Use arrow keys to move the @ cursor. Press ENTER to continue."

# Debug output area
tui.cursor.move 22 10
echo "Debug: Key="

tui.cursor.move 23 10
echo "       Pos="

tui.cursor.move 24 10
echo "       Drawing @ at:"

# Draw initial position
tui.cursor.move $cy $cx
tui.color.yellow
tui.color.bold
printf "@"
tui.color.reset

while true; do
    # Save old position
    old_cy=$cy
    old_cx=$cx
    
    # Read key
    key=$(tui.input.key)
    
    case "$key" in
        UP)
            cy=$((cy - 1))
            [[ $cy -lt 6 ]] && cy=6
            ;;
        DOWN)
            cy=$((cy + 1))
            [[ $cy -gt 18 ]] && cy=18
            ;;
        LEFT)
            cx=$((cx - 1))
            [[ $cx -lt 11 ]] && cx=11
            ;;
        RIGHT)
            cx=$((cx + 1))
            [[ $cx -gt 68 ]] && cx=68
            ;;
        ENTER)
            break
            ;;
    esac
    
    # Debug output
    tui.cursor.move 22 22
    printf "%-20s" "$key"
    tui.cursor.move 23 22
    printf "row=%2d col=%2d    " $cy $cx
    tui.cursor.move 24 30
    printf "(%2d,%2d)" $cy $cx
    
    # Only redraw if position changed
    if [ $old_cy -ne $cy ] || [ $old_cx -ne $cx ]; then
        # Clear old position
        tui.cursor.move $old_cy $old_cx
        printf " "
        
        # Draw new position
        tui.cursor.move $cy $cx
        tui.color.yellow
        tui.color.bold
        printf "@"
        tui.color.reset
    fi
done

# Show cursor again
tui.cursor.show

sleep 1

# Test 4: Line input
tui.screen.clear
tui.cursor.move 2 2
tui.color.bold
echo "Test 4: Line Input"
tui.color.reset

tui.cursor.move 4 4
name=$(tui.input.prompt "Enter your name: ")

tui.cursor.move 6 4
tui.color.green
echo "Hello, $name!"
tui.color.reset

sleep 2

# Test 5: Password input
tui.screen.clear
tui.cursor.move 2 2
tui.color.bold
echo "Test 5: Password Input (hidden)"
tui.color.reset

tui.cursor.move 4 4
password=$(tui.input.password "Enter password:")

tui.cursor.move 6 4
echo "Password length: ${#password} characters"
tui.cursor.move 7 4
tui.color.dim
echo "(Your password was: $password)"
tui.color.reset

sleep 2

# Test 6: Yes/No input
tui.screen.clear
tui.cursor.move 2 2
tui.color.bold
echo "Test 6: Yes/No Input"
tui.color.reset

tui.cursor.move 4 4
if tui.input.yesno "Do you like this TUI library?"; then
    tui.cursor.move 6 4
    tui.color.green
    echo "Great! Glad you like it! 😊"
    tui.color.reset
else
    tui.cursor.move 6 4
    tui.color.yellow
    echo "That's okay, we're still building it!"
    tui.color.reset
fi

sleep 2

# Test 7: Number input
tui.screen.clear
tui.cursor.move 2 2
tui.color.bold
echo "Test 7: Number Input"
tui.color.reset

tui.cursor.move 4 4
number=$(tui.input.number "Enter a number:")

tui.cursor.move 6 4
echo "You entered: $number"
tui.cursor.move 7 4
if [[ -n $number ]]; then
    echo "Double that is: $((number * 2))"
else
    echo "No number entered"
fi

sleep 2

# Test 8: Validated input
tui.screen.clear
tui.cursor.move 2 2
tui.color.bold
echo "Test 8: Validated Input"
tui.color.reset

tui.cursor.move 4 4
echo "Enter a valid email address (we'll validate it)"

tui.cursor.move 6 4
email=$(tui.input.validated "Email:" tui.input.validate_email)

tui.cursor.move 8 4
tui.color.green
echo "✓ Valid email: $email"
tui.color.reset

sleep 2

# Test 9: Control keys
tui.screen.clear
tui.cursor.move 2 2
tui.color.bold
echo "Test 9: Control Key Detection"
tui.color.reset

tui.cursor.move 4 4
echo "Press Ctrl+D, Ctrl+A, or other control keys"
tui.cursor.move 5 4
echo "(Note: Ctrl+C will exit the script)"
tui.cursor.move 6 4
echo "Press 'q' to continue"
tui.cursor.move 8 4

row=8
while true; do
    key=$(tui.input.key)
    
    if [[ $key == "q" ]]; then
        break
    fi
    
    tui.cursor.move $row 4
    printf "%-60s" "Key: $key"
    
    row=$((row + 1))
    if [ $row -gt 20 ]; then
        row=7
    fi
done

sleep 1

# Test 10: Key timeout
tui.screen.clear
tui.cursor.move 2 2
tui.color.bold
echo "Test 10: Input with Timeout"
tui.color.reset

tui.cursor.move 4 4
echo "Press any key within 5 seconds..."

tui.cursor.move 6 4
key=$(tui.input.key_timeout 5)

if [[ -n $key ]]; then
    tui.cursor.move 8 4
    tui.color.green
    echo "You pressed: $key"
    tui.color.reset
else
    tui.cursor.move 8 4
    tui.color.red
    echo "Timeout! No key pressed."
    tui.color.reset
fi

sleep 2

# Test 11: Menu simulation
tui.screen.clear
tui.cursor.move 2 2
tui.color.bold
echo "Test 11: Simple Menu Navigation"
tui.color.reset

items=("Option 1" "Option 2" "Option 3" "Option 4" "Exit")
selected=0

while true; do
    # Draw menu
    tui.box.draw 5 10 40 10
    tui.box.text_centered 6 10 40 "Main Menu"
    tui.box.divider_h 7 10 40
    
    # Draw items
    for i in "${!items[@]}"; do
        tui.cursor.move $((9 + i)) 12
        
        if [ $i -eq $selected ]; then
            tui.color.reverse
            printf "► %-35s" "${items[$i]}"
            tui.color.reset
        else
            printf "  %-35s" "${items[$i]}"
        fi
    done
    
    # Read key
    key=$(tui.input.key)
    
    case "$key" in
        UP)
            [[ $selected -gt 0 ]] && selected=$((selected - 1))
            ;;
        DOWN)
            [[ $selected -lt $((${#items[@]} - 1)) ]] && selected=$((selected + 1))
            ;;
        ENTER)
            if [ $selected -eq 4 ]; then
                break
            else
                tui.cursor.move 17 10
                tui.color.green
                echo "Selected: ${items[$selected]}"
                tui.color.reset
                sleep 1
                tui.cursor.move 17 10
                printf "%-40s" ""
            fi
            ;;
    esac
done

# Final screen
tui.screen.clear
tui.cursor.move 10 5
tui.color.green
tui.color.bold
echo "All input tests complete!"
tui.color.reset

tui.cursor.move 12 5
echo "Press any key to exit..."
tui.input.wait_any

# Cleanup
tui.screen.main
