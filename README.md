# Please CLI

Please is a CLI tool that translates natural language into shell commands. 
This is a copy and enhanced version of that tool that better suits my needs. This is a very wild high risk version that does not wait for validation of the command you've requested, it will just run it. Use with care

Installation:
- clone this repo
- add your openai api key to the pls file
- chmod +x pls
- add pls to your path

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