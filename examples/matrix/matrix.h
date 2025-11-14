matrix(){
    local class_code=$(<matrix.class);
    local generated_code="${class_code//__OBJECT__/$1}";
    eval "$generated_code"
}

