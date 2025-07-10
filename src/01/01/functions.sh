#!/bin/bash

# functions.sh

is_alphabetic() {
    local input="$1"
    [[ "$input" =~ ^[a-zA-Z]+$ ]]
}
