__OBJECT___max_jobs=10

__OBJECT__.limit(){
    if [ "$1" = "=" ]
    then
        __OBJECT___max_jobs="$2"
    else
        echo ${__OBJECT___max_jobs}
    fi
}

# Run a job
__OBJECT__.run(){
    local running=($(jobs -r -p))
    while [ ${#running[@]} -ge $__OBJECT___max_jobs ]; do
        sleep 0.1
        running=($(jobs -r -p))
    done
    "$@" &
}

# Wait for all
__OBJECT__.wait(){
    wait
}

