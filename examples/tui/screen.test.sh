#!/bin/bash
# test-screen.sh - Test screen.class.bash functionality

# Load modules
. screen.class.bash
. cursor.class.bash

echo "Testing screen.class.bash..."
echo "Press Enter to continue through tests"
read

# Test 1: Alternative screen buffer
echo "Switching to alternative screen..."
tui.screen.alt
tui.screen.clear
tui.cursor.move 5 5
echo "Now in alternative screen buffer"
echo "Your previous terminal content is saved"
sleep 2

# Test 2: Clear operations
tui.screen.clear
tui.cursor.move 1 1
echo "Line 1"
echo "Line 2"
echo "Line 3"
echo "Line 4"
echo "Line 5"

sleep 1
tui.cursor.move 3 1
echo -n "Clearing this line in 2 seconds..."
sleep 2
tui.screen.clear_line
echo "Line 3 cleared!"
sleep 2

# Test 3: Clear to end/start
tui.screen.clear
tui.cursor.move 1 1
echo "Top line"
echo "Middle line 1"
echo "Middle line 2"
echo "Middle line 3"
echo "Bottom line"

tui.cursor.move 3 1
echo -n "Clearing from here to end of screen..."
sleep 2
tui.screen.clear_to_end
sleep 2

# Test 4: Line clearing variations
tui.screen.clear
tui.cursor.move 5 1
echo "This is a long line of text that will be partially cleared"
sleep 1

tui.cursor.move 5 20
echo -n "Clearing to end..."
sleep 1
tui.screen.clear_line_to_end
sleep 2

tui.cursor.move 7 1
echo "Another long line of text for testing"
tui.cursor.move 7 15
echo -n "Clearing to start..."
sleep 1
tui.cursor.move 7 15
tui.screen.clear_line_to_start
sleep 2

# Test 5: Scrolling
tui.screen.clear
for i in {1..20}; do
    echo "Line $i"
done

tui.cursor.move 12 1
echo "Scrolling up in 2 seconds..."
sleep 2
tui.screen.scroll_up 5
sleep 2

# Test 6: Scroll region
tui.screen.clear
tui.cursor.move 5 1
echo "┌────────────────────────┐"
echo "│ Scroll region (5-15)   │"
echo "│                        │"
echo "│                        │"
echo "│                        │"
echo "│                        │"
echo "│                        │"
echo "│                        │"
echo "│                        │"
echo "│                        │"
echo "│                        │"
echo "└────────────────────────┘"

tui.screen.scroll_region 7 15
tui.cursor.move 7 3

echo "Filling scroll region..."
sleep 1
for i in {1..20}; do
    echo "  Scrolling line $i"
    sleep 0.1
done

tui.screen.scroll_region_reset
sleep 2

# Test 7: Get terminal size
tui.screen.clear
tui.cursor.move 5 5
echo "Getting terminal size..."
size=$(tui.screen.size)
tui.cursor.move 6 5
echo "Terminal size: $size (rows cols)"
sleep 3

# Test 8: Wrap mode
tui.screen.clear
tui.cursor.move 3 1
echo "Testing line wrap..."
echo ""
echo "With wrap disabled:"
tui.screen.wrap_off
echo "This is a very long line that would normally wrap but won't because we disabled wrapping and it will just get cut off at the edge of the terminal window"
sleep 3

tui.cursor.move 8 1
echo "With wrap enabled:"
tui.screen.wrap_on
echo "This is a very long line that will wrap normally because we enabled wrapping and you should see it continue on the next line automatically"
sleep 3

# Cleanup
tui.screen.clear
tui.cursor.move 10 5
echo "Tests complete! Returning to main screen in 2 seconds..."
sleep 2

tui.screen.main
echo "Back to normal terminal"
