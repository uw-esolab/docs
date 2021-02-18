# Debug SSC in Linux using PySSC, SAM, Spyder and CodeLiteIDE

I got this to work on CodeLite IDE as well! CodeLite only offers C++ compiling and debugging, so the Python code will have to run on another IDE. If you download [Anaconda](https://www.anaconda.com/products/individual), you will have access to the Spyder IDE for Python. You could also use Visual Studio Code which works with Linux.

Much of these steps are mirrored in the other tutorial using the Eclipse IDE [here](https://github.com/uw-esolab/docs/blob/main/sam/debugSSCwithPySSC_Linux_EclipseIDE.md). I will replicate the steps here for running this in CodeLite and Spyder.

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
	
	>`cmake -G "CodeLite - Unix Makefiles" -DCMAKE_BUILD_TYPE:STRING=Debug -DCMAKE_SYSTEM_VERSION=10.0 ..`
	
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
		
		> `print('PID = ',pid)`
	
	- make sure all resource files have the correct address

7. In the `PySSC.py` file, make the following changes:

	- remove all the `if-else` statements and change the `self.pdll` declaration to the following code, remembering to change the `<path_to_sam_dev>` portion to the correct address:

	
		> `def __init__(self):`
		
		>         `self.pdll = CDLL('<path_to_sam_dev>/build/ssc/ssc/libsscd.so')`
	
	- change all calls to a `double` function to `float` (the former doesn't exist in Python)
	

---
## 4. Set up CodeLite IDE for Mixed-Mode Debugging

The CodeLite IDE can be used to run/debug C++ files. You can download CodeLite at [this link.](https://codelite.org/)

1. Open the CodeLite desktop app.

2. Run the Setup Wizard (automatic or go to *Help* > *Run Setup Wizard*)

	- Scan for a compiler and make sure you have GCC somewhere in there (in `/usr/bin`, there might be multiple versions but that's ok)
	
3. Open the SAM workspace found at `../sam_dev/build/system_advisor_model.workspace` and configure the project

	- Double click the project folder titled `sam_simulation_core` to make it the active project
	
	- Right-click the project and click *Settings*
	
	- The default settings work pretty well, here is a screenshot of them just in case they're different 
	
	![project settings][cpp_projectSettings]


	
---
## 5. Debugging with 'Attach to Process'

We can now run and debug Python scripts through a separate Python IDE that call the `libsscd.so` share object file, triggering CodeLite to open in debug mode once we set up the appropriate breakpoints.

1. There might be some permissions problems when using "Attach to Process." In an open terminal, enter

	> `echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope`
	
	to temporarily grant permissions. You can permanently fix this by changing the contents of that file, but that scares me.

2. Open Spyder (or your favorite Python IDE). If you have Anaconda, you can install and open Spyder in a terminal through

	> `conda install spyder`
	
	> `spyder`

3. In the Python IDE, open the `<project_name>.py` file and set a breakpoint around Line 257, where `ssc.module_exec(module,data)` is called.
	
4. In CodeLite, open the appropriate `cmod` C++ file. In this particular case it is the `cmod_tcsmolten_salt.cpp` file

	- The correct file is found in *Workspace View* at `system_advisor_model` > `sam_simulation_core` > `src` > `ssc` > `ssc` > `cmod_tcsmolten_salt.cpp`
	
	- Set a breakpoint after Line 626, in the scope of `void exec( ) override { }`
	
3. Begin **Python** debugging session

	- In Spyder, press the *Debug File* button or `CTRL` + `F5`
	
	- The breakpoint in the `<project_name>.py` file should catch, pausing in the *Console* tab as shown (note the printed PID)
	
	![First Breakpoint in main Python script][python_firstBreakpoint]
	
4. Begin **C++** debugging session

	- Go to *Debugger* > *Attach to Process*
	
	- An *Attach to Process* window should pop up. Enter the Python PID noted previously and click *Attach*
	
	![Attach to Process][cpp_attachToProcess]
	
	- Press the green *Play* button underneath the toolbar as shown
	
	![Press play][cpp_pressContinue]
	
5. Go back to Python IDE and continue the debugger by pressing `CTRL` + `F12`

6. CodeLite IDE should pop up and catch on the breakpoint you previously set!
	
	![First Breakpoint in C++][cpp_firstBreakpoint]
	
[cpp_projectSettings]: codelite_cpp_projectSettings.png
[python_firstBreakpoint]: spyder_python_firstBreakpoint.png
[cpp_attachToProcess]: codelite_cpp_attachToProcess.png
[cpp_pressContinue]: codelite_cpp_pressContinue.png
[cpp_firstBreakpoint]: codelite_cpp_firstBreakpoint.png

