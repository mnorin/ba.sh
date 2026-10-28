#!/bin/bash
# test-color.sh - Test color.class.bash functionality

# Load modules
. color.class.bash
. screen.class.bash
. cursor.class.bash

echo "Testing color.class.bash..."
echo "Press Enter to start tests"
read

# Setup
tui.screen.alt
tui.screen.clear

# Test 1: Basic colors
tui.cursor.move 2 2
echo "Test 1: Basic Foreground Colors"
tui.cursor.move 3 2

tui.color.black; echo -n "Black "
tui.color.red; echo -n "Red "
tui.color.green; echo -n "Green "
tui.color.yellow; echo -n "Yellow "
tui.color.blue; echo -n "Blue "
tui.color.magenta; echo -n "Magenta "
tui.color.cyan; echo -n "Cyan "
tui.color.white; echo "White"
tui.color.reset

sleep 2

# Test 2: Bright colors
tui.cursor.move 5 2
echo "Test 2: Bright Foreground Colors"
tui.cursor.move 6 2

tui.color.bright_black; echo -n "Gray "
tui.color.bright_red; echo -n "BrightRed "
tui.color.bright_green; echo -n "BrightGreen "
tui.color.bright_yellow; echo -n "BrightYellow "
tui.color.bright_blue; echo -n "BrightBlue "
tui.color.bright_magenta; echo -n "BrightMagenta "
tui.color.bright_cyan; echo -n "BrightCyan "
tui.color.bright_white; echo "BrightWhite"
tui.color.reset

sleep 2

# Test 3: Background colors
tui.cursor.move 8 2
echo "Test 3: Background Colors"
tui.cursor.move 9 2

tui.color.bg_red; echo -n " Red BG "
tui.color.reset; echo -n " "
tui.color.bg_green; echo -n " Green BG "
tui.color.reset; echo -n " "
tui.color.bg_blue; echo -n " Blue BG "
tui.color.reset; echo -n " "
tui.color.bg_yellow; tui.color.black; echo -n " Yellow BG "
tui.color.reset
echo

sleep 2

# Test 4: Text formatting
tui.cursor.move 11 2
echo "Test 4: Text Formatting"
tui.cursor.move 12 2

tui.color.bold; echo -n "Bold "
tui.color.reset
tui.color.dim; echo -n "Dim "
tui.color.reset
tui.color.italic; echo -n "Italic "
tui.color.reset
tui.color.underline; echo -n "Underline "
tui.color.reset
tui.color.reverse; echo -n "Reverse "
tui.color.reset
tui.color.strikethrough; echo -n "Strikethrough"
tui.color.reset
echo

sleep 2

# Test 5: Combined formatting
tui.cursor.move 14 2
echo "Test 5: Combined Formatting"
tui.cursor.move 15 2

tui.color.bold
tui.color.red
echo -n "Bold Red "
tui.color.reset

tui.color.italic
tui.color.green
tui.color.bg_black
echo -n "Italic Green on Black "
tui.color.reset

tui.color.underline
tui.color.blue
echo "Underlined Blue"
tui.color.reset

sleep 2

# Test 6: RGB colors (true color)
tui.screen.clear
tui.cursor.move 2 2
echo "Test 6: RGB True Color (if supported)"
tui.cursor.move 3 2

# Orange
tui.color.rgb 255 128 0
echo -n "Orange (255,128,0) "
tui.color.reset

# Pink
tui.color.rgb 255 192 203
echo -n "Pink (255,192,203) "
tui.color.reset

# Purple
tui.color.rgb 128 0 128
echo "Purple (128,0,128)"
tui.color.reset

sleep 2

# Test 7: RGB backgrounds
tui.cursor.move 5 2
echo "Test 7: RGB Backgrounds"
tui.cursor.move 6 2

tui.color.rgb_bg 64 128 192
echo -n " Blue gradient "
tui.color.reset; echo -n " "

tui.color.rgb_bg 192 64 64
echo -n " Red gradient "
tui.color.reset; echo -n " "

tui.color.rgb_bg 64 192 64
echo " Green gradient "
tui.color.reset

sleep 2

# Test 8: 256 color palette sample
tui.screen.clear
tui.cursor.move 2 2
echo "Test 8: 256 Color Palette (sample)"
tui.cursor.move 3 2

# Show first 16 colors
for i in {0..15}; do
    tui.color.c256_bg $i
    printf "  "
    tui.color.reset
done
echo

# Show some colors from 6x6x6 cube
tui.cursor.move 4 2
for i in {16..51}; do
    tui.color.c256_bg $i
    printf "  "
    tui.color.reset
done
echo

# Show some grayscale
tui.cursor.move 5 2
for i in {232..255}; do
    tui.color.c256_bg $i
    printf "  "
    tui.color.reset
done
echo

sleep 3

# Test 9: Utility functions
tui.screen.clear
tui.cursor.move 2 2
echo "Test 9: Utility Functions"
tui.cursor.move 4 2

tui.color.print 31 "This is red text using print()"
tui.color.print 32 "This is green text using print()"
tui.color.print_rgb 255 128 0 "This is orange using print_rgb()"
tui.color.print_fg_bg 33 44 "Yellow on blue using print_fg_bg()"

sleep 3

# Test 10: RGB Color Gradient
tui.screen.clear
tui.cursor.move 2 2
echo "Test 10: RGB Color Gradient"
tui.cursor.move 4 2

for i in {0..50}; do
    r=$((255 - i * 5))        # Remove 'local'
    g=$((i * 5))              # Remove 'local'
    tui.color.rgb $r $g 128
    echo -n "█"
done
tui.color.reset
echo

sleep 3

# Cleanup
tui.screen.clear
tui.cursor.move 10 5
tui.color.green
tui.color.bold
echo "All color tests complete!"
tui.color.reset

tui.cursor.move 12 5
echo "Press Enter to exit"
read

tui.screen.main
