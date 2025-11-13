#!/usr/bin/env bash

echo "=========================================="
echo "ba.sh Constructor Performance Comparison"
echo "=========================================="
echo ""
echo "Bash version: ${BASH_VERSION}"
echo ""

# Create test class file (bash 3 compatible)
cat > test.class << 'EOF'
__TEST___properties=()

__TEST__.property(){
    # Property IDs for indexed arrays
    local title=0
    local description=1
    local priority=2
    
    if [ "$2" = "=" ]; then
        __TEST___properties[${!1}]="$3"
    else
        echo ${__TEST___properties[${!1}]}
    fi
}

__TEST__.title(){
    if [ "$1" = "=" ]; then
        __TEST__.property title = "$2"
    else
        __TEST__.property title
    fi
}

__TEST__.description(){
    if [ "$1" = "=" ]; then
        __TEST__.property description = "$2"
    else
        __TEST__.property description
    fi
}

__TEST__.priority(){
    if [ "$1" = "=" ]; then
        # Simple validation (bash 3 compatible)
        case "$2" in
            1|2|3|4|5)
                __TEST__.property priority = "$2"
                ;;
            *)
                echo "Error: Priority must be 1-5" >&2
                return 1
                ;;
        esac
    else
        __TEST__.property priority
    fi
}

__TEST__.display(){
    local p=$(__TEST__.priority)
    local t=$(__TEST__.title)
    echo "[$p] $t"
}
EOF

# Constructor 1: sed (legacy)
test_sed(){
    . <(sed "s/__TEST__/$1/g" test.class)
}

# Constructor 2: Pure bash 4+ (printf + process substitution)
test_bash4(){
    local class_code=$(<test.class)
    . <(printf '%s' "${class_code//__TEST__/$1}")
}

# Constructor 3: Bash 3 compatible (eval)
test_bash3(){
    local class_code=$(<test.class)
    local generated_code="${class_code//__TEST__/$1}"
    eval "$generated_code"
}

# Determine bash version
BASH_MAJOR_VERSION=${BASH_VERSION%%.*}

echo "=========================================="
echo "TEST 1: Functionality Check"
echo "=========================================="
echo ""

# Test sed constructor
echo "Testing sed constructor..."
if test_sed sed_obj 2>/dev/null; then
    sed_obj.title = "Sed Test"
    sed_obj.priority = 1
    result=$(sed_obj.title)
    prio=$(sed_obj.priority)
    if [ -n "$result" ]; then
        echo "Result: $result - Priority: $prio"
        echo "✓ sed constructor works"
        SED_WORKS=1
    else
        echo "✗ sed constructor failed"
        SED_WORKS=0
    fi
else
    echo "✗ sed constructor not supported on bash $BASH_MAJOR_VERSION"
    SED_WORKS=0
fi
echo ""

# Test bash 4+ constructor
if [ "$BASH_MAJOR_VERSION" -ge 4 ]; then
    echo "Testing bash 4+ constructor (printf + process substitution)..."
    if test_bash4 bash4_obj 2>/dev/null; then
        bash4_obj.title = "Bash 4 Test"
        bash4_obj.priority = 2
        result=$(bash4_obj.title)
        prio=$(bash4_obj.priority)
        echo "Result: $result - Priority: $prio"
        echo "✓ bash 4+ constructor works"
        BASH4_WORKS=1
    else
        echo "✗ bash 4+ constructor failed"
        BASH4_WORKS=0
    fi
    echo ""
fi

# Test bash 3 constructor
echo "Testing bash 3 compatible constructor (eval)..."
if test_bash3 bash3_obj 2>/dev/null; then
    bash3_obj.title = "Bash 3 Test"
    bash3_obj.priority = 3
    result=$(bash3_obj.title)
    prio=$(bash3_obj.priority)
    echo "Result: $result - Priority: $prio"
    echo "✓ bash 3 compatible constructor works"
    BASH3_WORKS=1
else
    echo "✗ bash 3 constructor failed"
    BASH3_WORKS=0
fi
echo ""

# Performance tests
echo "=========================================="
echo "TEST 2: Performance Benchmark"
echo "=========================================="
echo ""

# Test with different object counts
for count in 10 100 1000; do
    echo "Creating $count objects with each constructor:"
    echo ""
    
    # Benchmark sed if it works
    if [ "$SED_WORKS" = "1" ]; then
        echo -n "  sed constructor:        "
        
        # Use time command for bash 3 compatibility
        if [ "$BASH_MAJOR_VERSION" -lt 4 ]; then
            # Bash 3: use time command and capture output
            TIME_OUTPUT=$( { time for i in $(seq 1 $count); do test_sed "sed_perf_${i}" 2>/dev/null; done; } 2>&1 )
            # Extract real time (format: 0m0.123s)
            sed_time=$(echo "$TIME_OUTPUT" | grep real | sed 's/real[^0-9]*//;s/m/*60+/;s/s/*1000/' | bc 2>/dev/null || echo "0")
            sed_time=${sed_time%.*}  # Remove decimal part
        else
            # Bash 4+: use nanosecond precision
            start=$(date +%s%N)
            for i in $(seq 1 $count); do
                test_sed "sed_perf_${i}" 2>/dev/null
            done
            end=$(date +%s%N)
            sed_time=$(( (end - start) / 1000000 ))
        fi
        echo "${sed_time}ms"
    fi
    
    # Benchmark bash 4+ if available and works
    if [ "$BASH_MAJOR_VERSION" -ge 4 ] && [ "$BASH4_WORKS" = "1" ]; then
        echo -n "  bash 4+ constructor:    "
        start=$(date +%s%N)
        for i in $(seq 1 $count); do
            test_bash4 "bash4_perf_${i}" 2>/dev/null
        done
        end=$(date +%s%N)
        bash4_time=$(( (end - start) / 1000000 ))
        echo "${bash4_time}ms"
    fi
    
    # Benchmark bash 3 if it works
    if [ "$BASH3_WORKS" = "1" ]; then
        echo -n "  bash 3 constructor:     "
        
        if [ "$BASH_MAJOR_VERSION" -lt 4 ]; then
            # Bash 3: use time command
            TIME_OUTPUT=$( { time for i in $(seq 1 $count); do test_bash3 "bash3_perf_${i}" 2>/dev/null; done; } 2>&1 )
            bash3_time=$(echo "$TIME_OUTPUT" | grep real | sed 's/real[^0-9]*//;s/m/*60+/;s/s/*1000/' | bc 2>/dev/null || echo "0")
            bash3_time=${bash3_time%.*}
        else
            # Bash 4+: use nanosecond precision
            start=$(date +%s%N)
            for i in $(seq 1 $count); do
                test_bash3 "bash3_perf_${i}" 2>/dev/null
            done
            end=$(date +%s%N)
            bash3_time=$(( (end - start) / 1000000 ))
        fi
        echo "${bash3_time}ms"
    fi
    
    echo ""
    
    # Analysis
    echo "  Analysis ($count objects):"
    
    if [ "$BASH_MAJOR_VERSION" -ge 4 ] && [ "$BASH4_WORKS" = "1" ] && [ "$SED_WORKS" = "1" ]; then
        # Compare bash4 vs sed
        if [ "$sed_time" -gt 0 ]; then
            diff_bash4_sed=$((bash4_time - sed_time))
            if [ $diff_bash4_sed -lt 0 ]; then
                percent=$(( (-diff_bash4_sed) * 100 / sed_time ))
                echo "    • bash 4+ is ${percent}% faster than sed ($((-diff_bash4_sed))ms difference)"
            else
                percent=$(( diff_bash4_sed * 100 / sed_time ))
                echo "    • sed is ${percent}% faster than bash 4+ (${diff_bash4_sed}ms difference)"
            fi
        fi
    fi
    
    if [ "$BASH3_WORKS" = "1" ] && [ "$SED_WORKS" = "1" ]; then
        # Compare bash3 vs sed
        if [ "$sed_time" -gt 0 ]; then
            diff_bash3_sed=$((bash3_time - sed_time))
            if [ $diff_bash3_sed -lt 0 ]; then
                percent=$(( (-diff_bash3_sed) * 100 / sed_time ))
                echo "    • bash 3 is ${percent}% faster than sed ($((-diff_bash3_sed))ms difference)"
            else
                percent=$(( diff_bash3_sed * 100 / sed_time ))
                echo "    • sed is ${percent}% faster than bash 3 (${diff_bash3_sed}ms difference)"
            fi
        fi
    fi
    
    if [ "$BASH_MAJOR_VERSION" -ge 4 ] && [ "$BASH4_WORKS" = "1" ] && [ "$BASH3_WORKS" = "1" ]; then
        # Compare bash4 vs bash3
        if [ "$bash3_time" -gt 0 ]; then
            diff_bash4_bash3=$((bash4_time - bash3_time))
            if [ $diff_bash4_bash3 -lt 0 ]; then
                percent=$(( (-diff_bash4_bash3) * 100 / bash3_time ))
                echo "    • bash 4+ is ${percent}% faster than bash 3 ($((-diff_bash4_bash3))ms difference)"
            else
                percent=$(( diff_bash4_bash3 * 100 / bash3_time ))
                echo "    • bash 3 is ${percent}% faster than bash 4+ (${diff_bash4_bash3}ms difference)"
            fi
        fi
    fi
    
    echo ""
done

# Cleanup
rm -f test.class

echo "=========================================="
echo "SUMMARY"
echo "=========================================="
echo ""
echo "Tested on bash ${BASH_VERSION}"
echo ""
echo "Constructor compatibility:"
if [ "$SED_WORKS" = "1" ]; then
    echo "  ✓ sed constructor works"
else
    echo "  ✗ sed constructor not supported"
fi
if [ "$BASH_MAJOR_VERSION" -ge 4 ]; then
    if [ "$BASH4_WORKS" = "1" ]; then
        echo "  ✓ bash 4+ constructor works"
    else
        echo "  ✗ bash 4+ constructor failed"
    fi
fi
if [ "$BASH3_WORKS" = "1" ]; then
    echo "  ✓ bash 3 constructor works"
else
    echo "  ✗ bash 3 constructor failed"
fi
echo ""

if [ "$BASH_MAJOR_VERSION" -ge 4 ]; then
    echo "Recommendation for bash 4+:"
    if [ "$BASH3_WORKS" = "1" ]; then
        echo "  Use bash 3 style (eval) for best performance"
        echo "  (eval is safe when code is from your own class files)"
    elif [ "$BASH4_WORKS" = "1" ]; then
        echo "  Use bash 4+ constructor (printf + process substitution)"
    elif [ "$SED_WORKS" = "1" ]; then
        echo "  Use sed constructor"
    fi
else
    echo "Recommendation for bash 3:"
    if [ "$BASH3_WORKS" = "1" ]; then
        echo "  Use bash 3 constructor (eval-based) for zero dependencies"
    elif [ "$SED_WORKS" = "1" ]; then
        echo "  Use sed constructor"
    fi
fi
echo ""
echo "=========================================="