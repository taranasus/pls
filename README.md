# PLS3 and PLS4 by Taranasus

pls is a CLI tool that translates natural language into shell commands for MacOS. It might work on Linux too, I haven't tested it. It's based on https://github.com/MxDkl/pls

This is a copy and enhanced version of that tool that better suits my needs. This is a very wild, high risk version that does not wait for validation of the command you've requested, it will just run it. Use with care

Installation:
- Clone this repo 
  - Run git clone https://github.com/taranasus/pls.git to clone the repo into your local machine.
- Create a token file
  - Navigate to the cloned repo's folder and create a file named token.txt.
  - Add your OpenAI API key to this file and save it.
- Make Scripts Executable:
  - Open a terminal and navigate to the folder containing the repo.
  - Run "chmod +x pls3 pls4" to make the pls3 and pls4 scripts executable.
- Add the folder to your path:
  - Still in the terminal, run "pls4 add this folder to the PATH" to add the repository folder to your system's PATH environment variable. This will make pls3 and pls4 runnable from any folder

Requirements:
- jq binary (commandline JSON processor)
- openai api key in a token.txt file

Note:
- The pls file is only there so I can merge from MxDkl's repo if he makes any changes. It's not used by my version of the tool.

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