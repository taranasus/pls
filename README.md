# PLS3 and PLS4 by Taranasus

pls is a CLI tool that translates natural language into shell commands for MacOS. It might work on Linux too, I haven't tested it. It's based on https://github.com/MxDkl/pls

This is a copy and enhanced version of that tool that better suits my needs. This is a very wild, high risk version that does not wait for validation of the command you've requested, it will just run it. Use with care

Installation:
- Clone this repo
- Create a token.txt file in the pls folder with your openai api key in it
- In a terminal, in the folder of the repo, run "chmod +x pls3"
- In a terminal, in the folder of the repo, run "chmod +x pls4"
- Add the pls folder to your path. You can do this by using the terminal to write "pls4 add this folder to the PATH".

Requirements:
- jq binary (commandline JSON processor) - For pls3 and pls4
- openai api key in a token.txt file

Usage:
```
FOR GPT 3.5 TURBO:
> pls3 [natural language command] 
FOR GPT 4:
> pls4 [natural language command]
```
Examples:
```
pls3 list all files in the current directory
pls4 list all files in the current directory that contain "foo"
pls3 make a directory called "foo" with 3 files in it that each have 1000 random words
pls4 use iptables to forward all traffic from port 80 to port 8501
pls3 zip all files in the current directory that contain the word "foo" and save to desktop
```

Warning:
- be careful when running as root because it is unpredictable and could do anything