# PLS by Taranasus

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
  - Run "chmod +x pls" to make the script executable.
- Add the folder to your path:
  - Still in the terminal, run "pls add this folder to the PATH" to add the repository folder to your system's PATH environment variable. This will make pls runnable from any folder

Requirements:
- jq binary (commandline JSON processor)
- openai api key in a token.txt file

Usage:
```
> pls [natural language command]
```

Example commands:
```
pls list all files in the current directory
pls list all files in the current directory that contain "foo"
pls make a directory called "foo" with 3 files in it that each have 1000 random words
pls use iptables to forward all traffic from port 80 to port 8501
pls zip all files in the current directory that contain the word "foo" and save to desktop
```

Example output:
```
taranasus@taranasus-MacBook-Air _Unsorted % pls give me a totla filecount including subfolders
[GPT] [$0.00002] find . -type f | wc -l
   21884
```

Warning:
- be careful when running as root because it is unpredictable and could do anything