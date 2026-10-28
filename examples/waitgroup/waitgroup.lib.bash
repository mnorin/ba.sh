waitgroup(){
    local class_code=$(<waitgroup.class.bash)
    . <(printf '%s' "${class_code//__OBJECT__/$1}")
}

