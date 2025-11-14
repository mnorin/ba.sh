#!/usr/bin/env bash

. matrix.h

echo "=========================================="
echo "ba.sh 2D Array (Matrix) Example"
echo "=========================================="
echo ""

# Create a matrix
echo "Creating 5x5 matrix..."
matrix m1
m1.setSize 5 5
echo "Matrix size: $(m1.getSize)"
echo ""

# Set some values
echo "Setting values..."
m1.set 0 0 10
m1.set 1 1 20
m1.set 2 2 30
m1.set 3 3 40
m1.set 4 4 50

m1.set 0 4 99
m1.set 4 0 88
echo ""

# Get values
echo "Getting individual values:"
echo "  m1.get 0 0 = $(m1.get 0 0)"
echo "  m1.get 1 1 = $(m1.get 1 1)"
echo "  m1.get 2 2 = $(m1.get 2 2)"
echo ""

# Display matrix
echo "Display full matrix:"
m1.display
echo ""

# Get a row
echo "Getting row 1:"
echo "  $(m1.getRow 1)"
echo ""

# Fill matrix with a value
echo "Creating another matrix and filling with zeros..."
matrix m2
m2.setSize 3 4
m2.fill 0
m2.display
echo ""

# Set some values in second matrix
echo "Setting some values in m2..."
m2.set 0 0 1
m2.set 0 1 2
m2.set 1 2 5
m2.set 2 3 9
m2.display
echo ""

# Test bounds checking
echo "Testing bounds checking (should fail)..."
m1.set 10 10 100 2>/dev/null
if [ $? -ne 0 ]; then
    echo "  ✓ Bounds checking works!"
fi
echo ""

# Compact display
echo "Compact display of m2:"
m2.displayCompact
echo ""

# Multiple matrices
echo "Creating third matrix to show isolation..."
matrix m3
m3.setSize 2 2
m3.set 0 0 "A"
m3.set 0 1 "B"
m3.set 1 0 "C"
m3.set 1 1 "D"
echo "m3 (string matrix):"
m3.display
echo ""

echo "All three matrices are independent!"
echo "m1 size: $(m1.getSize)"
echo "m2 size: $(m2.getSize)"
echo "m3 size: $(m3.getSize)"
echo ""

echo "=========================================="
echo "Example complete!"
echo "=========================================="

