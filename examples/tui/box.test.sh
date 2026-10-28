#!/bin/bash
# test-box.sh - Test box.class.bash functionality

# Load modules
. cursor.class.bash
. screen.class.bash
. color.class.bash
. box.class.bash

echo "Testing box.class.bash..."
echo "Press Enter to continue through tests"
read

# Setup
tui.screen.alt
tui.cursor.hide

# Test 1: Basic boxes
tui.screen.clear
tui.cursor.move 2 2
echo "Test 1: Basic Box Styles"

tui.box.draw 4 5 30 8
tui.box.text_centered 5 5 30 "Single Line Box"

tui.box.draw_double 4 40 30 8
tui.box.text_centered 5 40 30 "Double Line Box"

tui.box.draw_rounded 13 5 30 8
tui.box.text_centered 14 5 30 "Rounded Corners"

tui.box.filled 13 40 30 8 '░'
tui.box.text_centered 16 40 30 "Filled Box"

sleep 3

# Test 2: Lines
tui.screen.clear
tui.cursor.move 2 2
echo "Test 2: Line Drawing"

tui.box.hline 5 10 40
tui.cursor.move 5 52
echo "Horizontal line"

tui.box.vline 7 10 10
tui.cursor.move 11 15
echo "Vertical line"

tui.box.hline_double 18 10 40
tui.cursor.move 18 52
echo "Double horizontal"

tui.box.vline_double 7 55 10
tui.cursor.move 11 60
echo "Double vertical"

sleep 3

# Test 3: Titled boxes
tui.screen.clear
tui.cursor.move 2 2
echo "Test 3: Boxes with Titles"

tui.box.titled 5 5 35 10 "User Information"
tui.box.text_left 7 5 "Name: John Doe"
tui.box.text_left 8 5 "Email: john@example.com"
tui.box.text_left 9 5 "Role: Administrator"

tui.box.titled_double 5 45 35 10 "System Status"
tui.box.text_left 7 45 "CPU: 45%"
tui.box.text_left 8 45 "Memory: 2.1GB / 8GB"
tui.box.text_left 9 45 "Disk: 150GB free"

sleep 3

# Test 4: Dividers
tui.screen.clear
tui.cursor.move 2 2
echo "Test 4: Boxes with Dividers"

tui.box.draw 5 10 60 15

# Horizontal dividers
tui.box.divider_h 8 10 60
tui.box.divider_h 11 10 60
tui.box.divider_h 14 10 60

# Vertical divider
tui.box.divider_v 5 40 15

# Text in sections
tui.box.text_centered 6 10 29 "Top Left"
tui.box.text_centered 6 40 29 "Top Right"
tui.box.text_centered 9 10 29 "Middle Left"
tui.box.text_centered 9 40 29 "Middle Right"
tui.box.text_centered 12 10 29 "Bottom Left"
tui.box.text_centered 12 40 29 "Bottom Right"

sleep 3

# Test 5: Progress bars
tui.screen.clear
tui.cursor.move 2 2
echo "Test 5: Progress Bars"

tui.cursor.move 5 10
echo "Loading resources..."
tui.box.progress 6 10 50 25

tui.cursor.move 8 10
echo "Processing data..."
tui.box.progress 9 10 50 60

tui.cursor.move 11 10
echo "Upload complete:"
tui.color.green
tui.box.progress 12 10 50 100
tui.color.reset

sleep 3

# Test 6: Animated progress bar
tui.screen.clear
tui.cursor.move 2 2
echo "Test 6: Animated Progress Bar"

tui.cursor.move 5 10
echo "Installing packages..."

for i in {0..100..5}; do
    tui.cursor.move 6 10
    if [ $i -lt 30 ]; then
        tui.color.red
    elif [ $i -lt 70 ]; then
        tui.color.yellow
    else
        tui.color.green
    fi
    tui.box.progress 6 10 60 $i
    tui.color.reset
    
    tui.cursor.move 6 72
    printf "%3d%%" $i
    
    sleep 0.1
done

sleep 2

# Test 7: Shadow boxes
tui.screen.clear
tui.cursor.move 2 2
echo "Test 7: Shadow Effect"

tui.box.shadow 5 10 40 10
tui.box.text_centered 7 10 40 "Box with Shadow"
tui.box.text_centered 9 10 40 "Creates depth illusion"

tui.box.shadow 5 55 30 8
tui.box.text_centered 7 55 30 "Another Shadow"

sleep 3

# Test 8: Panel
tui.screen.clear
tui.cursor.move 2 2
echo "Test 8: Panel with Header"

tui.box.panel 5 10 60 15 "Configuration Panel"

tui.box.text_left 6 10 "Settings:" 2
tui.box.text_left 8 10 "• Auto-save: Enabled" 4
tui.box.text_left 9 10 "• Theme: Dark" 4
tui.box.text_left 10 10 "• Language: English" 4
tui.box.text_left 11 10 "• Notifications: On" 4

sleep 3

# Test 9: Window
tui.screen.clear
tui.cursor.move 2 2
echo "Test 9: Window Style"

tui.box.window 5 15 50 12 "Application Window"

tui.box.text_left 8 15 "Welcome to the TUI library demo!" 2
tui.box.text_left 10 15 "This is a window-style box" 2
tui.box.text_left 11 15 "with a title bar." 2

sleep 3

# Test 10: Complex layout
tui.screen.clear
tui.cursor.move 2 2
tui.color.bold
echo "Test 10: Complex Layout"
tui.color.reset

# Main window
tui.box.window 4 5 70 18 "Dashboard"

# Top section - stats
tui.box.draw 7 7 20 5
tui.box.text_centered 8 7 20 "Users"
tui.color.green
tui.box.text_centered 9 7 20 "1,234"
tui.color.reset

tui.box.draw 7 29 20 5
tui.box.text_centered 8 29 20 "Revenue"
tui.color.yellow
tui.box.text_centered 9 29 20 "$56,789"
tui.color.reset

tui.box.draw 7 51 20 5
tui.box.text_centered 8 51 20 "Status"
tui.color.green
tui.box.text_centered 9 51 20 "Online"
tui.color.reset

# Bottom section - recent activity
tui.box.titled 13 7 64 7 "Recent Activity"
tui.box.text_left 15 7 "• User login: admin@example.com" 2
tui.box.text_left 16 7 "• Database backup completed" 2
tui.box.text_left 17 7 "• New order #12345 received" 2

sleep 4

# Test 11: All text alignments
tui.screen.clear
tui.cursor.move 2 2
echo "Test 11: Text Alignment"

tui.box.draw 5 10 60 10

tui.box.text_left 7 10 "Left aligned text" 2
tui.box.text_centered 8 10 60 "Centered text"
tui.box.text_right 9 10 60 "Right aligned text" 2

tui.box.divider_h 10 10 60

tui.box.text_left 11 10 "Item 1" 2
tui.box.text_right 11 10 60 "$10.00" 2

tui.box.text_left 12 10 "Item 2" 2
tui.box.text_right 12 10 60 "$25.50" 2

sleep 3

# Cleanup
tui.screen.clear
tui.cursor.move 10 5
tui.color.green
tui.color.bold
echo "All box tests complete!"
tui.color.reset

tui.cursor.move 12 5
echo "Press Enter to exit"
read

tui.cursor.show
tui.screen.main
