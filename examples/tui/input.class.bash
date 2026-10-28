# input.class.bash - Keyboard input handling for ba.sh TUI library
# No dependencies

# Prevent double-loading
[[ -n $TUI_INPUT_LOADED ]] && return
TUI_INPUT_LOADED=1

# ============================================================================
# Basic Input
# ============================================================================

# Read a single character (no enter needed)
tui.input.char(){
    local char
    IFS= read -rsn1 char
    echo "$char"
}

# Read a line of text (with enter)
tui.input.line(){
    local line
    IFS= read -r line
    echo "$line"
}

# Read a line with prompt
tui.input.prompt(){
    local prompt="$1"
    local line
    printf "%s" "$prompt" > /dev/tty
    IFS= read -r line
    echo "$line"
}

# ============================================================================
# Special Key Detection
# ============================================================================

# Read a key with special key detection
# Returns: key name or character
# Special keys: UP, DOWN, LEFT, RIGHT, HOME, END, INSERT, DELETE, 
#               PAGEUP, PAGEDOWN, F1-F12, ENTER, ESC, BACKSPACE, TAB
#               ALT-A through ALT-Z, ALT-0 through ALT-9
#               CTRL-A through CTRL-Z (and some CTRL-number keys)
tui.input.key(){
    local key
    IFS= read -rsn1 key
    
    # Check for escape sequence (special keys start with ESC)
    if [[ $key == $'\033' ]]; then
        # Read next char to determine sequence type
        IFS= read -rsn1 -t 0.001 key
        
        if [[ $key == '[' ]]; then
            # CSI sequence (most special keys)
            IFS= read -rsn1 -t 0.001 key
            
            case "$key" in
                A) echo "UP" ;;
                B) echo "DOWN" ;;
                C) echo "RIGHT" ;;
                D) echo "LEFT" ;;
                H) echo "HOME" ;;
                F) echo "END" ;;
                
                # Multi-character sequences
                [0-9])
                    local seq="$key"
                    IFS= read -rsn1 -t 0.001 key
                    
                    if [[ $key == '~' ]]; then
                        case "$seq" in
                            1) echo "HOME" ;;
                            2) echo "INSERT" ;;
                            3) echo "DELETE" ;;
                            4) echo "END" ;;
                            5) echo "PAGEUP" ;;
                            6) echo "PAGEDOWN" ;;
                            7) echo "HOME" ;;
                            8) echo "END" ;;
                        esac
                    elif [[ $key == [0-9] ]]; then
                        # Function keys F1-F12
                        seq="$seq$key"
                        IFS= read -rsn1 -t 0.001 key
                        
                        if [[ $key == '~' ]]; then
                            case "$seq" in
                                11) echo "F1" ;;
                                12) echo "F2" ;;
                                13) echo "F3" ;;
                                14) echo "F4" ;;
                                15) echo "F5" ;;
                                17) echo "F6" ;;
                                18) echo "F7" ;;
                                19) echo "F8" ;;
                                20) echo "F9" ;;
                                21) echo "F10" ;;
                                23) echo "F11" ;;
                                24) echo "F12" ;;
                            esac
                        fi
                    fi
                    ;;
                    
                *) echo "ESC" ;;
            esac
        elif [[ $key == 'O' ]]; then
            # SS3 sequence (alternate function keys)
            IFS= read -rsn1 -t 0.001 key
            case "$key" in
                P) echo "F1" ;;
                Q) echo "F2" ;;
                R) echo "F3" ;;
                S) echo "F4" ;;
                H) echo "HOME" ;;
                F) echo "END" ;;
                *) echo "ESC" ;;
            esac
        elif [[ -n $key ]]; then
            # ESC followed by another character = Alt key
            # Convert to uppercase for consistency
            local upper_key="${key^^}"
            if [[ $upper_key =~ ^[A-Z]$ ]]; then
                echo "ALT-$upper_key"
            elif [[ $key =~ ^[0-9]$ ]]; then
                echo "ALT-$key"
            else
                # Unknown Alt combination, just return ESC
                echo "ESC"
            fi
        else
            # Just ESC key (no following character within timeout)
            echo "ESC"
        fi
    else
        # Regular character or control character
        case "$key" in
            '') echo "ENTER" ;;
            $'\x7f') echo "BACKSPACE" ;;
            $'\t') echo "TAB" ;;
            $'\x01') echo "CTRL-A" ;;
            $'\x02') echo "CTRL-B" ;;
            $'\x03') echo "CTRL-C" ;;
            $'\x04') echo "CTRL-D" ;;
            $'\x05') echo "CTRL-E" ;;
            $'\x06') echo "CTRL-F" ;;
            $'\x07') echo "CTRL-G" ;;
            $'\x08') echo "CTRL-H" ;;
            $'\x0a') echo "CTRL-J" ;;
            $'\x0b') echo "CTRL-K" ;;
            $'\x0c') echo "CTRL-L" ;;
            $'\x0d') echo "CTRL-M" ;;
            $'\x0e') echo "CTRL-N" ;;
            $'\x0f') echo "CTRL-O" ;;
            $'\x10') echo "CTRL-P" ;;
            $'\x11') echo "CTRL-Q" ;;
            $'\x12') echo "CTRL-R" ;;
            $'\x13') echo "CTRL-S" ;;
            $'\x14') echo "CTRL-T" ;;
            $'\x15') echo "CTRL-U" ;;
            $'\x16') echo "CTRL-V" ;;
            $'\x17') echo "CTRL-W" ;;
            $'\x18') echo "CTRL-X" ;;
            $'\x19') echo "CTRL-Y" ;;
            $'\x1a') echo "CTRL-Z" ;;
            # Ctrl+number keys have inconsistent codes, but some terminals use these
            $'\x00') echo "CTRL-2" ;;  # Null
            $'\x1b') echo "CTRL-3" ;;  # ESC (conflict, handled above)
            $'\x1c') echo "CTRL-4" ;;  # FS
            $'\x1d') echo "CTRL-5" ;;  # GS
            $'\x1e') echo "CTRL-6" ;;  # RS
            $'\x1f') echo "CTRL-7" ;;  # US
            # Note: Ctrl-1, Ctrl-8, Ctrl-9, Ctrl-0 often don't produce control codes
            *) echo "$key" ;;
        esac
    fi
}

# ============================================================================
# Input with Timeout
# ============================================================================

# Read key with timeout (seconds)
# Returns key or empty string if timeout
tui.input.key_timeout(){
    local timeout=$1
    local key
    
    if IFS= read -rsn1 -t "$timeout" key; then
        # Got a character, check if it's an escape sequence
        if [[ $key == $'\033' ]]; then
            # Reconstruct the sequence for tui.input.key
            # This is a bit hacky but works
            echo -ne "$key" | { tui.input.key; }
        else
            case "$key" in
                '') echo "ENTER" ;;
                $'\x7f') echo "BACKSPACE" ;;
                $'\t') echo "TAB" ;;
                *) echo "$key" ;;
            esac
        fi
    else
        # Timeout
        echo ""
    fi
}

# Check if key is available (non-blocking)
# Returns 0 if key available, 1 if not
tui.input.available(){
    read -rsn1 -t 0.001
    return $?
}

# ============================================================================
# Utility Functions
# ============================================================================

# Wait for specific key
tui.input.wait_for(){
    local expected="$1"
    local key
    
    while true; do
        key=$(tui.input.key)
        if [[ $key == "$expected" ]]; then
            return 0
        fi
    done
}

# Wait for any key press
tui.input.wait_any(){
    tui.input.char >/dev/null
}

# Read yes/no input
# Returns 0 for yes, 1 for no
tui.input.yesno(){
    local prompt="${1:-Continue?}"
    local key
    
    printf "%s (y/n): " "$prompt" > /dev/tty
    
    while true; do
        key=$(tui.input.char)
        case "$key" in
            y|Y)
                echo "yes"
                return 0
                ;;
            n|N)
                echo "no"
                return 1
                ;;
        esac
    done
}

# Read number input
tui.input.number(){
    local prompt="${1:-Enter number:}"
    local value
    local number_regex='^-?[0-9]+$'
    
    while true; do
        printf "%s " "$prompt" > /dev/tty
        IFS= read -r value
        
        # Check if it's a valid number
        if [[ $value =~ $number_regex ]]; then
            echo "$value"
            return 0
        else
            printf "Invalid number. Try again.\n" > /dev/tty
        fi
    done
}

# Read password (hidden input)
tui.input.password(){
    local prompt="${1:-Password:}"
    local password
    
    printf "%s " "$prompt" > /dev/tty
    IFS= read -rs password
    echo  # New line after hidden input
    echo "$password"
}

# ============================================================================
# Input Validation
# ============================================================================

# Read input with validation function
# Usage: tui.input.validated "Prompt" validation_function
tui.input.validated(){
    local prompt="$1"
    local validator="$2"
    local value
    
    while true; do
        printf "%s " "$prompt" > /dev/tty
        IFS= read -r value
        
        if $validator "$value"; then
            echo "$value"
            return 0
        else
            printf "Invalid input. Try again.\n" > /dev/tty
        fi
    done
}

# Example validators (can be used with tui.input.validated)

# Validate email format
tui.input.validate_email(){
    local email_regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    [[ $1 =~ $email_regex ]]
}

# Validate non-empty
tui.input.validate_nonempty(){
    [[ -n $1 ]]
}

# Validate number
tui.input.validate_number(){
    local number_regex='^-?[0-9]+$'
    [[ $1 =~ $number_regex ]]
}

# Validate positive number
tui.input.validate_positive(){
    local positive_regex='^[0-9]+$'
    [[ $1 =~ $positive_regex ]] && [ "$1" -gt 0 ]
}
