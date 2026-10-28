# color.class.bash - Color and text formatting for ba.sh TUI library
# No dependencies

# Prevent double-loading
[[ -n $TUI_COLOR_LOADED ]] && return
TUI_COLOR_LOADED=1

# ============================================================================
# Basic Colors (foreground)
# ============================================================================

# Set foreground color (30-37 for basic, 90-97 for bright)
tui.color.fg(){
    printf '\033[%dm' "$1"
}

# Named basic colors
tui.color.black(){ printf '\033[30m'; }
tui.color.red(){ printf '\033[31m'; }
tui.color.green(){ printf '\033[32m'; }
tui.color.yellow(){ printf '\033[33m'; }
tui.color.blue(){ printf '\033[34m'; }
tui.color.magenta(){ printf '\033[35m'; }
tui.color.cyan(){ printf '\033[36m'; }
tui.color.white(){ printf '\033[37m'; }

# Named bright colors
tui.color.bright_black(){ printf '\033[90m'; }
tui.color.bright_red(){ printf '\033[91m'; }
tui.color.bright_green(){ printf '\033[92m'; }
tui.color.bright_yellow(){ printf '\033[93m'; }
tui.color.bright_blue(){ printf '\033[94m'; }
tui.color.bright_magenta(){ printf '\033[95m'; }
tui.color.bright_cyan(){ printf '\033[96m'; }
tui.color.bright_white(){ printf '\033[97m'; }

# Aliases
tui.color.gray(){ tui.color.bright_black; }
tui.color.grey(){ tui.color.bright_black; }

# Default foreground color
tui.color.fg_default(){ printf '\033[39m'; }

# ============================================================================
# Basic Colors (background)
# ============================================================================

# Set background color (40-47 for basic, 100-107 for bright)
tui.color.bg(){
    printf '\033[%dm' "$1"
}

# Named basic backgrounds
tui.color.bg_black(){ printf '\033[40m'; }
tui.color.bg_red(){ printf '\033[41m'; }
tui.color.bg_green(){ printf '\033[42m'; }
tui.color.bg_yellow(){ printf '\033[43m'; }
tui.color.bg_blue(){ printf '\033[44m'; }
tui.color.bg_magenta(){ printf '\033[45m'; }
tui.color.bg_cyan(){ printf '\033[46m'; }
tui.color.bg_white(){ printf '\033[47m'; }

# Named bright backgrounds
tui.color.bg_bright_black(){ printf '\033[100m'; }
tui.color.bg_bright_red(){ printf '\033[101m'; }
tui.color.bg_bright_green(){ printf '\033[102m'; }
tui.color.bg_bright_yellow(){ printf '\033[103m'; }
tui.color.bg_bright_blue(){ printf '\033[104m'; }
tui.color.bg_bright_magenta(){ printf '\033[105m'; }
tui.color.bg_bright_cyan(){ printf '\033[106m'; }
tui.color.bg_bright_white(){ printf '\033[107m'; }

# Aliases
tui.color.bg_gray(){ tui.color.bg_bright_black; }
tui.color.bg_grey(){ tui.color.bg_bright_black; }

# Default background color
tui.color.bg_default(){ printf '\033[49m'; }

# ============================================================================
# Extended Colors (256 color palette)
# ============================================================================

# Set foreground to 256 color (0-255)
tui.color.c256(){
    printf '\033[38;5;%dm' "$1"
}

# Set background to 256 color (0-255)
tui.color.c256_bg(){
    printf '\033[48;5;%dm' "$1"
}

# ============================================================================
# True Color (RGB - 24-bit)
# ============================================================================

# Set foreground RGB color (r, g, b: 0-255)
tui.color.rgb(){
    printf '\033[38;2;%d;%d;%dm' "$1" "$2" "$3"
}

# Set background RGB color (r, g, b: 0-255)
tui.color.rgb_bg(){
    printf '\033[48;2;%d;%d;%dm' "$1" "$2" "$3"
}

# ============================================================================
# Text Formatting
# ============================================================================

# Bold / bright
tui.color.bold(){
    printf '\033[1m'
}

# Dim / faint
tui.color.dim(){
    printf '\033[2m'
}

# Italic
tui.color.italic(){
    printf '\033[3m'
}

# Underline
tui.color.underline(){
    printf '\033[4m'
}

# Blinking (slow)
tui.color.blink(){
    printf '\033[5m'
}

# Blinking (rapid) - rarely supported
tui.color.blink_rapid(){
    printf '\033[6m'
}

# Reverse / inverse (swap foreground and background)
tui.color.reverse(){
    printf '\033[7m'
}

# Hidden / invisible
tui.color.hidden(){
    printf '\033[8m'
}

# Strikethrough
tui.color.strikethrough(){
    printf '\033[9m'
}

# Double underline
tui.color.double_underline(){
    printf '\033[21m'
}

# Overlined
tui.color.overline(){
    printf '\033[53m'
}

# ============================================================================
# Reset Functions
# ============================================================================

# Reset all formatting (color, bold, etc)
tui.color.reset(){
    printf '\033[0m'
}

# Reset bold/dim only
tui.color.reset_bold(){
    printf '\033[22m'
}

# Reset italic only
tui.color.reset_italic(){
    printf '\033[23m'
}

# Reset underline only
tui.color.reset_underline(){
    printf '\033[24m'
}

# Reset blinking only
tui.color.reset_blink(){
    printf '\033[25m'
}

# Reset reverse only
tui.color.reset_reverse(){
    printf '\033[27m'
}

# Reset hidden only
tui.color.reset_hidden(){
    printf '\033[28m'
}

# Reset strikethrough only
tui.color.reset_strikethrough(){
    printf '\033[29m'
}

# ============================================================================
# Utility Functions
# ============================================================================

# Print colored text (foreground color, text)
tui.color.print(){
    local color=$1
    shift
    tui.color.fg "$color"
    echo "$@"
    tui.color.reset
}

# Print RGB colored text (r, g, b, text)
tui.color.print_rgb(){
    local r=$1 g=$2 b=$3
    shift 3
    tui.color.rgb "$r" "$g" "$b"
    echo "$@"
    tui.color.reset
}

# Print with both foreground and background
tui.color.print_fg_bg(){
    local fg=$1 bg=$2
    shift 2
    tui.color.fg "$fg"
    tui.color.bg "$bg"
    echo "$@"
    tui.color.reset
}
