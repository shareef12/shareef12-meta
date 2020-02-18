#!/bin/sh -e

parse_file()
{
    while read line; do
        # Strip whitespace and comments
        line="$(echo $line | xargs echo -n | sed -e 's/^#.*//')"
        if [ ! -z "$line" ]; then
            echo $line
        fi
    done < $1 | sort -u | tr '\n' ',' | sed -e 's/,/, /g' -e 's/..$//'
}

dependencies="$(parse_file depends)"
recommends="$(parse_file recommends)"

echo "package:Depends=$dependencies" >> debian/shareef12-desktop.substvars
echo "package:Recommends=$recommends" >> debian/shareef12-desktop.substvars
