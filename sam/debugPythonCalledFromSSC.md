# Debug Pyomo when called by SSC (in Linux)
Here, we assume that we start with a main Python script that is told the location of a shared object file for `libsscd.so`. It calls this through a separate Python script called `PySSC.py` using `cdll`. We open a separate C++ IDE called CodeLite to set breakpoints in the `SSC` C++ code. Once the module in the main Python script is executed, breakpoints in the `SSC` code in CodeLite are triggered and debugging is conducted there. This process is described in [this link](https://github.com/uw-esolab/docs/blob/main/sam/debugSSCwithPySSC_Linux_CodeLiteIDE.md).

Eventually, we call *another* Python script to run Pyomo optimization. The `SSC` code executes a system command that works as a shell script, we just need to specify a character string for that command. This system command is found in `../tcs/csp_dispatch.cpp` in the `csp_dispatch_opt::optimize_ampl` method. The call looks like:

```
    system( solver_params.ampl_exec_call.c_str() );
```
We need to provide the string for `ampl_exec_call` to **RUN** and **DEBUG** the pyomo optimization.

Note that I am using the Spyder IDE for running Python code. Here is the intended debug process:

1. [Python, Spyder IDE] main Python script -> start Debug
2. [Python, Spyder IDE] main Python script -> hits breakpoint before module exec
3. [C++, CodeLite IDE] `/ssc/cmod_tcsmolten_salt.cpp` -> Attach To Process and set breakpoint
4. [Python, Spyder IDE] main Python script -> continue running the debug process, calls `PySSC.py`
5. [Python, Spyder IDE] `PySSC.py` -> calls the true module exec through `libsscd.so`
6. [C++, CodeLite IDE] `/ssc/cmod_tcsmolten_salt.cpp` -> hits breakpoint
7. [C++, CodeLite IDE] `/tcs/csp_dispatch.cpp` -> executes bash script to call external dispatch optimization
8. [bash] `pyomo.sh` -> creates new terminal, activates correct conda environment and runs pyomo script
9. [Gnome Terminal] `pyomo.py` -> hits breakpoint manually set through `pdb`

On **Step 7**, I initially just tried to run the Python script directly from CodeLite. It would run, and outputs were printed in the console of Spyder where it was still paused on the breakpoint hit in **Step 2**. But I couldn't figure out how to trigger a new debug session in Spyder for this new pyomo process.  Manually including breakpoints in the code didn't work, it would just quit out of them. So I wrote a bash script instead to run the Python script in a new terminal where the debug session could be triggered.

**NOTE**: We can skip **Step 8** and **9** by just calling `pyomo.py` directly when we run the code like normal, those steps are just to help debug.

**NOTE**: This debugging could potentially work in a more elegant way by creating a Spyder or Jupyter Python kernel in a terminal and somehow use the bash script to run the pyomo code there? It would create a kernel `JSON` file we could call. Haven't figured this one out, unfortunately. 



## Using a bash script for Python call

We can write a bash script to properly call the pyomo script in the correct environment (was having trouble with this earlier). 

1. Create the bash script with
```
    touch pyomo.sh
    gedit pyomo.sh
```

2. Write the following in the text file:
```
	#!/bin.bash
	
	gnome-terminal -- bash -c "
	source /home/gabrielsoto/anaconda3/etc/profile.d/conda.sh;
	conda activate pysam_daotk && python pyomo.py "
```

>In this step, I am creating a new terminal and running the python code there before exiting. I got the recommendation from [this link](https://unix.stackexchange.com/questions/373186/open-gnome-terminal-window-and-execute-2-commands). `gnome-terminal` creates a new terminal and executes the command in between the quotation marks, where `;` declares the end of one command. The first command specifies the location of anaconda and the `conda` command. The second command activates the correct conda environment (in this case, it is called `pysam_daotk`) and runs the python script we want. 

3. Add perimissions to this new bash script by:
```
	chmod +x pyomo.sh
```
## main Python Script 

In the main Python script (which originally executes ssc module through PySSCC), we need to define a couple more flags/variables:

```
    ssc.data_set_number( data, b'is_ampl_engine', 1)
    ssc.data_set_number( data, b'is_write_ampl_dat', 1)
    ssc.data_set_string( data, b'ampl_data_dir', b'/home/gabrielsoto/Documents/NE2/sam_scripts/')
    ssc.data_set_string( data, b'ampl_exec_call', b'./pyomo.sh' ) 
```
These should be added before calling `ssc.module_exec(module, data)`.

## Pyomo Python Script

In this pyomo script (I am currently substituting this with a dummy Python script), we can manually trigger a debug session in the terminal. We just need to add:
```
	import pdb
	pdb.set_trace()
```
which automatically triggers a debugging session. In the terminal you will see a line
```
(Pdb) 
```
waiting for input. Enter `q` to exit. Enter `c` to continue running the file. **Don't declare any variables named `q` or `c`.** Learn from my mistakes!

This process has the potential for danger. I added a line 
```
	import time
	time.sleep(5)
```
to pause the script for 5 seconds during debugging so that we don't get 48 terminals opening and closing at the same time. Definitely not an elegant debugging process, but hey, it worked for me?

## Notes for the Actual Debug Process

When you're on **Step 7** on the line
```
	system( solver_params.ampl_exec_call.c_str() );
```
and press continue on the debugger, it doesn't automatically stop on the pyomo `pdb` breakpoint in the terminal for some reason. So what I do is I use *Step Into* on the line above. I typically hit that button a couple dozen times (ugh) while some magic occurs in CodeLite IDE until the Terminal pops up with the `(Pdb)` line open!

