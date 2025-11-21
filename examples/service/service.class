##
## General service unit file to be placed in /etc/init.d
##

# Service properties (initialized empty)

__SERVICE___properties=()

__SERVICE__.property(){
    local name=0
    local pidfile=1
    local user=2
    local logfile=3
    local datadir=4
    local binary=5
    local client=6
    local admin=7
    local startCommand=8
    local stopCommand=9
    local statusCommand=10

    if [ "$2" = "=" ]; then
        __SERVICE___properties[$1]="$3"
    else
        echo "${__SERVICE___properties[$1]}"
    fi
}

# Simplified property generation - creates getters and setters for all properties
for prop in "name" "pidfile" "user" "logfile" "datadir" "binary" "client" "admin" "startCommand" "stopCommand" "statusCommand"
do
    eval "__SERVICE__.${prop}(){
        __SERVICE__.property ${prop} \"\$1\" \"\$2\"
    }"
done
unset prop

# Service management methods
__SERVICE__.isRunning(){
    local pidfile=$(__SERVICE__.pidfile)
    
    if [ -f "$pidfile" ]; then
        local pid=$(cat "$pidfile")
        if ps -p "$pid" > /dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

__SERVICE__.start(){
    local name=$(__SERVICE__.name)
    local pidfile=$(__SERVICE__.pidfile)
    local startCmd=$(__SERVICE__.startCommand)
    
    echo -n "Starting $name: "
    
    if __SERVICE__.isRunning; then
        echo "already running."
        return 0
    fi
    
    # Ensure pid directory exists
    local piddir=$(dirname "$pidfile")
    if [ ! -d "$piddir" ]; then
        mkdir -p "$piddir"
        chown $(__SERVICE__.user) "$piddir"
    fi
    
    # Execute start command
    if [ -n "$startCmd" ]; then
        $startCmd
        sleep 2
        
        if __SERVICE__.isRunning; then
            echo "done."
            return 0
        else
            echo "failed."
            return 1
        fi
    else
        echo "no start command defined."
        return 1
    fi
}

__SERVICE__.stop(){
    local name=$(__SERVICE__.name)
    local pidfile=$(__SERVICE__.pidfile)
    local stopCmd=$(__SERVICE__.stopCommand)
    
    echo -n "Stopping $name: "
    
    if ! __SERVICE__.isRunning; then
        echo "not running."
        return 0
    fi
    
    # Execute stop command
    if [ -n "$stopCmd" ]; then
        $stopCmd
        
        # Wait for process to stop
        local timeout=30
        while [ $timeout -gt 0 ]; do
            if ! __SERVICE__.isRunning; then
                echo "done."
                rm -f "$pidfile"
                return 0
            fi
            sleep 1
            timeout=$((timeout - 1))
        done
        
        # Force kill if still running
        echo -n "timeout, forcing... "
        local pid=$(cat "$pidfile" 2>/dev/null)
        if [ -n "$pid" ]; then
            kill -9 "$pid" 2>/dev/null
            rm -f "$pidfile"
        fi
        echo "done."
        return 0
    else
        # Default: kill by PID
        local pid=$(cat "$pidfile" 2>/dev/null)
        if [ -n "$pid" ]; then
            kill "$pid" 2>/dev/null
            sleep 2
            
            if ! __SERVICE__.isRunning; then
                echo "done."
                rm -f "$pidfile"
                return 0
            else
                kill -9 "$pid" 2>/dev/null
                rm -f "$pidfile"
                echo "forced."
                return 0
            fi
        fi
        echo "failed."
        return 1
    fi
}

__SERVICE__.restart(){
    __SERVICE__.stop
    sleep 1
    __SERVICE__.start
}

__SERVICE__.reload(){
    local name=$(__SERVICE__.name)
    local pidfile=$(__SERVICE__.pidfile)
    
    echo -n "Reloading $name: "
    
    if ! __SERVICE__.isRunning; then
        echo "not running."
        return 1
    fi
    
    local pid=$(cat "$pidfile" 2>/dev/null)
    if [ -n "$pid" ]; then
        kill -HUP "$pid" 2>/dev/null
        echo "done."
        return 0
    else
        echo "failed."
        return 1
    fi
}

__SERVICE__.status(){
    local name=$(__SERVICE__.name)
    local statusCmd=$(__SERVICE__.statusCommand)
    
    # Use custom status command if available
    if [ -n "$statusCmd" ]; then
        if $statusCmd > /dev/null 2>&1; then
            echo "$name is running"
            return 0
        else
            echo "$name is not running"
            return 3
        fi
    fi
    
    # Default: check PID
    if __SERVICE__.isRunning; then
        local pidfile=$(__SERVICE__.pidfile)
        local pid=$(cat "$pidfile")
        echo "$name is running (PID: $pid)"
        return 0
    else
        echo "$name is not running"
        return 3
    fi
}

