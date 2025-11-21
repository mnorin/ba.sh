service(){
    local class_code=$(<service.class)
    local generated_code="${class_code//__SERVICE__/$1}"
    # bash-3-compatible constructor
    eval "$generated_code"
}

