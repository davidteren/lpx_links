#!/bin/bash
for pkg in $1/*.pkg; do
    echo "Installing $pkg file..."
    installer -pkg $pkg -target /
done
