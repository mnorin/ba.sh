waitgroup(){
    local class_code=$(<waitgroup.class)
    . <(printf '%s' "${class_code//__OBJECT__/$1}")
}

