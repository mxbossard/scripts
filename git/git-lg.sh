#!/bin/sh

# Create a powerfull alias to watch git log history
# https://coderwall.com/p/euwpig

git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
