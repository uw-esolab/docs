# Debug SSC in Linux using PySSC, SAM and Eclipse CDT

So far I have only gotten the mixed-mode debugging working on the Eclipse IDE. In this case, it involves running a Python script that calls a C++ shared object/dynamic library file (such as `libsscd.so`) and, after setting a breakpoint in an appropriate `.cpp` file, having the IDE catch the breakpoint and allow C++ debugging. You can download the Eclipse IDE [at the official site](https://www.eclipse.org/cdt/downloads.php).

---
## 1. Build SAM on Linux

First, follow the build instructions for Linux found through [this link](https://github.com/NREL/SAM/wiki/Linux-Build-Instructions). Ultimately, there will be separate directories for `LK`, `WEX`, `SSC`, and `SAM`. These will be housed in a parent directory, which is referred to as `sam_dev`. Some additional comments on the Linux instructions:

- Make sure you always build the Debug version of things

- [2.4](https://github.com/NREL/SAM/wiki/Linux-Build-Instructions#2-install-wxwidgets-311) : the complete path I used was 
`../sam_dev/wxWidgets-3.1.1/lib/wx-3.1.1`
- [3.0](https://github.com/NREL/SAM/wiki/Linux-Build-Instructions#3-install-googletest) : After entering the `cmake` command in the terminal for `googletest`, run

	>`make -j4` 

	Afterwards, I found four gtest library files under `../sam_dev/googletest/build/lib`. If you built the Debug version, they should look like `libgtest<d>.a` (without `<` and `>`). I copied and pasted all four files into `../sam_dev/googletest` and `../sam_dev/googletest/googletest`. This seemed to have fixed some linker errors when building the gtest files in `SSC` later. 
	
- [5.1](https://github.com/NREL/SAM/wiki/Linux-Build-Instructions#5-install-lk-wex-ssc-then-sam) In this step, create the build folder as `../sam_dev/build`. Make sure you have the CMakeLists.txt set up for bundling the four projects as a single project. Then, run `cmake` for the specific generator for the Eclipse IDE:

	>`mkdir build`
	
	>`cd build`
	
	>`cmake -G "Eclipse CDT4 - Unix Makefiles" -DCMAKE_BUILD_TYPE:STRING=Debug -DCMAKE_SYSTEM_VERSION=10.0 ..`
	
	>`make -j4`
	
	An optional flag to use in the third line above would be `-DSAM_SKIP_TESTS=true` if having trouble with the `gtest` linker errors.

After following all the Linux build steps, there will be separate folders for each individual project under the `../sam_dev/build` directory. Most important are the `ssc` and `sam` folders. Some notes before moving on:

- Within the `../sam_dev/build/sam` folder there will be a binary version of the SAM Desktop that will be used to auto-generate `python3` scripts using PySSC.

- Within the `../sam_dev/build/ssc` folder there will be an `ssc` library called `libssc<d>.so` (the Debug version, without the `<` and `>`). The `python3` scripts will manually be changed to call this file. 

- Within the parent directory `../sam_dev` there will be a `.cproject` and `.project` file, used as the workspace for the Eclipse IDE.

---	
## 2. Create a bash script for SAM Desktop

Once `sam` is successfully built, we want to run it to auto-generate `PySSC` scripts. However, a bash script wasn't automatically generated to run `SAM` in my case (if it was created on your system, feel free to skip to the next step).

1. Make sure the `SAM` binary file is located at the following address (noting that this is a Debug version):
	
	>`../sam_dev/build/sam/deploy/linux_64/SAM<d>.bin`
		
2. Open a new terminal in the build directory: `../sam_dev/build`

3. Create an empty bash script (feel free to name it however is most convenient) and open it in a text editor as follows:

	> `cd sam`

	> `touch sam_bash` 
	
	> `gedit sam_bash`
	
4. In the file, add:

    > `#!/bin/sh `

    > `cd <path_to_sam_dev>/build/sam/deploy `

    > `export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:<path_to_sam_dev>/build/sam/deploy/linux_64 `

    > `exec <path_to_sam_dev>/build/sam/deploy/linux_64/SAMd.bin `

	Save and close the file. For disambiguation, the full path I `cd`'d into on the second line was `/home/gabrielsoto/Documents/sam_dev/build/sam/deploy` (I also call `sam_dev` something else in my file system).
   
   
  	 **Note** I am missing something in the bash script that calls GTKTheme as follows: 
   > `export GTK2_RC_FILES=<path_to_sam_dev>/build/sam/deploy/linux_64/GtkTheme/gtk-2.0/gtkrc**`
   
 	  It doesn't affect the ability to run `SAM` but still worth noting. The `GtkTheme` subfolder was not created upon finishing the build.

5. Add the proper permissions to run the bash script and open SAM Desktop:

	> `chmod +x sam_bash`
	
	> `./sam_bash`

---
## 3. Generate Python3 Scripts using SAM Desktop


In `SAM` Desktop,

1. Select *Start a new project* > *Concentrating Solar Power* > *Power Tower Molten Salt* > *Power Purchase Agreement* > *Single Owner*

	In the top toolbar, there should be an *untitled* project tab.
	
2. (Optional) In the drop down menu of the *untitled* tab, select *Rename* to rename the project.

3. In the drop down menu of the project, select *Generate Code* > *Python 3*.

4. Choose a folder to place the generated scripts, weather files, etc. I put them in the following directory

	> `../sam_dev/build/ssc/samscripts`
	
	though the naming and location are probably unimportant. 

	There should be two `.py` files in this folder: one named after the project and one named `PySSC.py`. The former contains the main code.


5. Open both files in either a text editor or Python IDE. 

6. In the `<project_name>.py` file, make the following changes:

	- add `import os` before declaring the main code.

	- add the following code to display the process ID (used later to attach Python process to C++ actions)
	
		> `pid = os.getpid()`
		
		> `print('PID = '.pid)`
	
	- make sure all resource files have the correct address

7. In the `PySSC.py` file, make the following changes:

	- remove all the `if-else` statements and change the `self.pdll` declaration to the following code, remembering to change the `<path_to_sam_dev>` portion to the correct address:

	
		> `def __init__(self):`
		
		>         `self.pdll = CDLL('<path_to_sam_dev>/build/ssc/ssc/libsscd.so')`
	
	- change all calls to a `double` function to `float` (the former doesn't exist in Python)
	
	
---
## 4. Set up Eclipse IDE for Mixed-Mode Debugging

The Eclipse IDE can be used to run/debug both Python scripts and C++ files. 

1. Open the Eclipse desktop app.

2. In the *Eclipse IDE Launcher*, select `<path_to_sam_dev>` as the workspace directory and click *Launch*.
	
3. Enable/install PyDev to run and debug Python scripts

	- Go to *Help* > *Install New Software*
	
	- Under *Work with*, enter: `https://pydev.org/updates`
	
	- Select *PyDev* and finish the installation
	
4. Change the preferences of Eclipse+PyDev to run the correct Python interpreter

	- Go to *Window* > *Preferences* > *PyDev* > *Interpreters* > *Python Interpreters*
	
	- Select *Browse for python/pypy exe*
	
	- Find the location of your Python installation (for reference, I downloaded mine through Anaconda and is located at `/home/gabrielsoto/anaconda3/bin/python3`
	
5. Open the C++ build folder in the Project Explorer window. Do this through *File* > *Open Projects from File System*

	- Next to *Import Source*, click *Directory* and select `<path_to_sam_dev>/build`
	
	- In the window underneath, make sure `build` is selected and click *Finish*
	
	- The `build` folder should now appear in the *Project Explorer* window


6. Create a separate Python project to run the `PySSC` scripts

	- Go to *File* > *New* > *Project* > *PyDev* > *PyDev Project* and click *Next*
	
	- Name the project (e.g., `samscripts`)
	
	- Under *Directory* select the path to the generated Python3 scripts from Step 3
	
	- Choose project type as *Python*
	
	- Choose interpreter as the one selected in Step 4.4
	
	- Select *Add project directory to the PYTHONPATH* and click *Finish*
	
	- The `samscripts` folder should now appear in the *Project Explorer* window

7. Create a **Python** Debug configuration

	- Go to *Run* > *Debug Configuration*
	
	- Right-click *Python Run* and select *New Configuration* 
	
	- Name the configuration (e.g., `sampydev`)
	
	- Select the Python project `samscripts` created in Step 4.6
	
	- Under *Main Module* select the `<project_name>.py` file and click *Apply*

8. Create a **C++** Debug configuration

	- Go to *Run* > *Debug Configuration*
	
	- Right-click *C/C++ Attach to Application* and select *New Configuration* 
	
	- Name the configuration (e.g., `libsscd`)
	
	- Select the C++ project `build` created in Step 4.5
	
	- Under *C/C++ Application* select the shared object file found at `ssc/ssc/libsscd.so` (under the parent directory `<path_to_sam_dev>/build`)
	
	- Under the *Debugger* tab, select `gdb` as the debugger
	
---
## 5. Debugging with 'Attach to Process'

With Eclipse properly set up, we can now run and debug Python scripts that called the `libsscd.so` share object file.

1. Open the `<project_name>.py` file  and set a breakpoint around Line 257, where `ssc.module_exec(module,data)` is called
	
2. Open the appropriate `cmod` C++ file. In this particular case it is the `cmod_tcsmolten_salt.cpp` file

	- The correct file is found at `build` > `ssc` > `ssc` > `libsscd.so` > `cmod_tcsmolten_salt.cpp`
	
	- Set a breakpoint after Line 626, in the scope of `void exec( ) override { }`
	
3. Begin **Python** debugging session

	- Go to *Run* > *Debug Configuration* > *Python Run* > *sampydev* and click *Debug*
	
	- `sampydev` should show up in the Debug window
	
	- The breakpoint in the `<project_name>.py` file should catch, pausing in the *Console* tab as shown (note the printed PID)
	
	![First Breakpoint in main Python script][python_firstBreakpoint]{width=110%}
	
4. Begin **C++** debugging session

	- Go to *Run* > *Debug Configuration* > *C/C++ Attach to Application* > *libsscd* and click *Debug*
	
	- An *Attach to Process* window should pop up. Enter the Python PID noted previously and click *OK*
	
	![Attach to Process][python_attachToProcess]{width=60%}
	
	- `libsscd` should show up in the Debug window, with `python3` and `gdb` tabs. Highlight the *Thread* under `python3` tab that reads "Running: User Request"
	
	- Switch from *Console* to *Debugger Console* below, where there should be a `(gdb)` line waiting for input. Enter 'c' (for 'continue')
	
	![C++ debugger console][cpp_debuggerConsole]{width=100%}
	
	- Highlight `<module>[<project_name>]` underneath the `sampydev` run in the Debug window and press `F8` to continue the debugging session
	
	- The breakpoint in `cmod_tcsmolten_salt.cpp` file should catch. Happy debugging!
	
	![First Breakpoint in C++][cpp_firstBreakpoint]{width=110%}
	
[python_firstBreakpoint]: eclipse_python_firstBreakpoint.png
[python_attachToProcess]: eclipse_python_attachToProcess.png
[cpp_debuggerConsole]: eclipse_cpp_debuggerConsole.png
[cpp_firstBreakpoint]: eclipse_cpp_firstBreakpoint.png

