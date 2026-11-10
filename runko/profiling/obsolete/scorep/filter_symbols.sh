#!/bin/bash

# Parse command line arguments
file_patterns=""
function_patterns=""
object_file=""

for arg in "$@"; do
    case "$arg" in
        --file-patterns=*)
            # Extract the comma-separated list after the equals sign
            file_patterns="${arg#--file-patterns=}"
            ;;
        --function-patterns=*)
            # Extract the comma-separated list after the equals sign
            function_patterns="${arg#--function-patterns=}"
            ;;
        *)
            # Treat as object file
            object_file="$arg"
            ;;
    esac
done

# Check if object file was provided
if [[ -z "$object_file" ]]; then
    echo "Error: object file is required" >&2
    exit 1
fi

# Check if object file exists
if [[ ! -f "$object_file" ]]; then
    echo "Error: object file '$object_file' not found" >&2
    exit 1
fi

# Don't use demangle with nm as it fails on many mangled names
# Pipeline:
# nm gets us lines with addersses, sections, symbols and file names (using debug info)
# If the user defined any excluded files, we feed those to sed and generate grep arguments from those:
# if file_patterns=foo,bar,baz/foobar,\,,barfoo
# then the sed expression generates --regexp=foo --regexp=bar --regexp=baz/foobar --regexp=, --regexp=barfoo
# and passes that to grep. There we inverse match, i.e. print only those lines that don't match with any of the above.
# Then we use awk to print the mangled symbol name (field 2),
# demangle those with llvm-cxxfilt,
# then do the same sed/grep inverse matching but on human readable functions this time.
# Then we sort and throw away dublicates.
nm --line-numbers --defined-only "$object_file" | \
    if [ -n $file_patterns ]; then \
        grep --invert-match --extended-regexp $(echo $file_patterns | sed -E 's/\\?([^,]*|,),?/--regexp=\1 /g'); \
    else \
        cat; \
    fi | \
    awk '$2 ~ /[tT]/ {print $3}' | \
    ./llvm-cxxfilt | \
    if [ -n "$function_patterns" ]; then \
        grep --invert-match --extended-regexp $(echo $function_patterns | sed -E 's/\\?([^,]*|,),?/--regexp=\1 /g'); \
    else \
        cat; \
    fi | \
    sort | \
    uniq | \
    sed 's/,/\\,/g' | \
    tr '\n' ',' | \
    less

#sed -E 's/^([^<(\[]*)(.*)$/\1/' | \
#sed -E 's/.* ([^ ]+)$/\1/' | \
