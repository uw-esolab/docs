# Git (and Git Bash) Installation & Setup for Students

## Document info

| Last update | Author         | Notes or changes                    |
|-------------|----------------|-------------------------------------|
| 2020/10/13  | Springate      | Initial creation                    |


## Operating System(s) and requirements
* These instructions are based on Installation for a Windows 10, 64-bit operating system. 

## External references and procedures

* [Installing Python with miniconda]()
* [Installing VS Code]()
* [Windows admin rights]()

## Purpose
Install the Git-SCM command window client and Git toolsets on a local machine.

## Procedure

1. 1)	Visit [this link](https://git-scm.com/downloads) to download Git

2.	Choose the appropriate option for your system. 
    ![](./image024.png)



3.	A file named “Git-2.28.0-64-bit” will start downloading.
    ![](./image026.png)


4.	Double click the installer to begin the installation process
    * Select the default location for Destination Location

        ![](./image028.png)

    * Select the default options for Components
        
        ![](./image029.png)

    * Select the default option for Start Menu Folder
        
        ![](./image030.png)

    * Select “Use Visual Studio Code as Git’s default editor”
        ![](./image031.png)

    * Select “Use Git from Git Bash only” for adjusting PATH environment
        ![](./image032.png)

    * Select “Use the OpenSSL library” for HTTPS transport backend
        ![](./image033.png)
        
    * Select “Checkout Windows-style, commit Unix-style line endings”
        ![](./image034.png)
        
    * Select “Use MinTTY” for terminal emulator to use with Git Bash
        ![](./image035.png)
        
    * Select “Default (fast-forward or merge)” for ‘git pull’ behavior
        ![](./image036.png)
        
    * Select “Git Credential Manager” 
        ![](./image037.png)

    * Select “Enable file system caching” for extra options
        ![](./image038.png)

    * Install

5. A window like this will open
    ![](./image039.png)

6. By default, Git Bash will launch in a folder like "Documents," but you may prefer to have it launch with the current working directory in the place where you store your repositories. To change the default working directory:
    * In the Windows launch area, search for "Bash"

        ![](./image040.png)

    * Right click and select "Open File Location"

    * In Windows Explorer, right click the "Git Bash" shortcut and select "Properties"
        ![](./image041.png)

    * On the Shortcut tab, the default settings for "Target" and "Start in" should be changed. To start, you might see:
        ![](./image042.png)

    * Remove `--cd-to-home` from Target, and set the Start In path to the folder where you keep your repositories.
        ![](./image043.png) 

    * Click Ok, and re-launch Bash. 