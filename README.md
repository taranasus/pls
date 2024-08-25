# PLS by Taranasus

PLS (Please) is a command-line interface (CLI) tool that translates natural language into shell commands for macOS. While it's primarily designed for macOS, it might work on Linux too, although this hasn't been tested. PLS is based on [MxDkl/pls](https://github.com/MxDkl/pls), with enhancements to better suit specific needs.

This is a high-risk version that does not wait for validation of the command you’ve requested—it will run immediately. Use with care, especially when running as root.

## Features
- Translate natural language commands directly into shell commands.
- Execute commands immediately, without confirmation.
- Supports macOS and potentially Linux (not tested).
- Includes debugging mode for inspecting API responses.

## Installation

### Clone the Repository
To install PLS, clone this repository to your local machine:
```
git clone https://github.com/taranasus/pls.git
```

### Create a Token File
1. Navigate to the cloned repository folder:
   ```
   cd pls
   ```
2. Create a file named `token.txt` in the root of the repository:
   ```
   touch token.txt
   ```
3. Add your OpenAI API key to this file:
   - Open the `token.txt` file in a text editor.
   - Paste your OpenAI API key into the file in the following format:
     ```
     sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
     ```
   - Save and close the file.

### Make the Script Executable
1. Open a terminal and navigate to the folder containing the repository.
2. Make the script executable by running:
   ```
   chmod +x pls
   ```

### Add the Folder to Your PATH
1. Still in the terminal, run the following command to add the repository folder to your system's `PATH` environment variable, making `pls` runnable from any folder:
   ```
   echo 'export PATH=$PATH:'$(pwd) >> ~/.bash_profile
   ```
2. Reload your terminal session to apply the changes:
   ```
   source ~/.bash_profile
   ```

## Requirements
- **jq**: A command-line JSON processor. You can install it using `brew` on macOS or your preferred package manager:
  ```
  brew install jq
  ```
- **OpenAI API key**: Obtain an API key from OpenAI and place it in a file named `token.txt` as described above.

## Usage
To use PLS, simply type your natural language command after the `pls` command:
```
> pls [natural language command]
```

### Example Commands
```
pls list all files in the current directory
pls list all files in the current directory that contain "foo"
pls make a directory called "foo" with 3 files in it that each have 1000 random words
pls use iptables to forward all traffic from port 80 to port 8501
pls zip all files in the current directory that contain the word "foo" and save to desktop
```

### Example Output
```
taranasus@taranasus-MacBook-Air _Unsorted % pls give me a totla filecount including subfolders
[GPT] [$0.00002] find . -type f | wc -l
   21884
```

### Flags
- **-a**: Use the advanced model (`gpt-4o`) instead of the default (`gpt-4o-mini`).
  ```
  pls -a [natural language command]
  ```
- **-d**: Enable debug mode, which prints out the full JSON response from OpenAI instead of executing the command.
  ```
  pls -d [natural language command]
  ```
- You can combine the `-a` and `-d` flags:
  ```
  pls -a -d [natural language command]
  ```

## Warning
- **Caution**: This tool runs commands immediately and does not wait for user confirmation. Be especially careful when running commands as root, as it could execute destructive actions.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.