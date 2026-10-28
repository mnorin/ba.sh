#!/bin/bash
# test-cursor.sh - Test cursor.class.bash functionality

# Load modules
. cursor.class.bash
. screen.class.bash

echo "Testing cursor.class.bash..."
echo "Press Enter to continue through tests"
read

# Setup
tui.screen.alt
tui.screen.clear
tui.cursor.hide

# Test 1: Basic movement
tui.cursor.move 5 10
echo "Test 1: At position (5, 10)"
sleep 1

tui.cursor.move 10 20
echo "Test 2: At position (10, 20)"
sleep 1

# Test 2: Relative movement
tui.cursor.move 15 5
echo "Starting here"
tui.cursor.down 2
echo "Moved down 2"
tui.cursor.right 10
echo "Moved right 10"
sleep 2

# Test 3: Save and restore
tui.screen.clear
tui.cursor.move 5 5
echo "Original position (5, 5)"
tui.cursor.save

tui.cursor.move 10 20
echo "Moved to (10, 20)"
sleep 1

tui.cursor.restore
echo " <- Restored!"
sleep 2

# Test 4: Cursor styles
tui.screen.clear
tui.cursor.show
tui.cursor.move 5 5

echo "Testing cursor styles (watch the cursor):"
echo ""

tui.cursor.move 7 5
echo "1. Blinking block (default)"
tui.cursor.style 1
sleep 2

tui.cursor.move 8 5
echo "2. Steady block"
tui.cursor.style 2
sleep 2

tui.cursor.move 9 5
echo "3. Blinking underline"
tui.cursor.style 3
sleep 2

tui.cursor.move 10 5
echo "4. Steady underline"
tui.cursor.style 4
sleep 2

tui.cursor.move 11 5
echo "5. Blinking bar"
tui.cursor.style 5
sleep 2

tui.cursor.move 12 5
echo "6. Steady bar"
tui.cursor.style 6
sleep 2

# Test 5: Get position
tui.screen.clear
tui.cursor.move 8 15
echo "Moved to (8, 15)"
tui.cursor.move 10 5
echo -n "Getting position: "
pos=$(tui.cursor.get_position)
echo "$pos"
sleep 2

# Cleanup
tui.cursor.move 20 1
echo "Tests complete! Press Enter to exit"
read

tui.cursor.style 0
tui.cursor.show
tui.screen.main
