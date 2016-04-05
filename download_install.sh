#!/bin/bash
cd $2
while read -r line; do
    name="$line"
    echo "Downloading $name..."
    curl -O $name
done < $1

for pkg in $2/*.pkg; do
    echo "Installing $pkg file..."
    installer -pkg $pkg -target /
done

