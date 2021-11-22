# Configuring Python for Pyomo 

## Document info

| Last update | Author         | Notes or changes                    |
|-------------|----------------|-------------------------------------|
| 2021/11/22  | Wagner         | Updating CBC docs                   |
| 2020/10/13  | Wagner         | Initial creation                    |


## Operating System(s) and requirements
* Windows 10
* Python 3.8+ (miniconda)
* This procedure assumes prior installation of [Python](https://github.com/mjwagner2/esolab/blob/main/python/python.md)
* You may also want to install [VS Code](https://github.com/mjwagner2/esolab/blob/main/vscode/vscode.md)
* [Source code](https://github.com/uw-esolab/docs/blob/main/pyomo/mwe.py) for minimal working example

## Purpose
Configure Python 3+ installed on a local machine to be used with Pyomo, which is a optimization modeling language developed for compatibility with multiple open-source and commercial solvers, including CPLEX, Gurobi, GLPK, CBC, and others. 

## Procedure

### Windows 10
1. **Download and install the appropriate solver**
    1. **For CBC solver:**
        1. **Download binaries for CBC (COIN-OR).** These are used by Pyomo when solving the optimization problem.

                The direct link for the most recent download as of this date is [here](https://www.coin-or.org/download/binary/Cbc/Cbc-master-win64-msvc16-mt.zip). If your system is not Windows/64-bit, the link to the binary hosting webpage is [here](https://www.coin-or.org/download/binary/Cbc/?C=M;O=D). Locate the most recent distributable that is compatible with your system. 

                
            
        2. **Extract download files to a temporary folder.** You may not need to use all of the subfolders or extracted files.

        3. **Locate the executable (.exe) and dynamic link library (.dll) files**, likely in a "bin" folder. These are the binary files that execute the solver. The CBC solver files are located in the /bin/ folder as shown below:
            ![CBC binary files](./snip_cbc02.png)

        4. **Copy the binaries to the Python Scripts folder.** Navigate to your Python installation folder. This may be:
            `C:\ProgramData\Miniconda3\Scripts\`  
            `C:\Python38\Scripts\`

            You can locate the python installation folder by opening a command window and executing:  
            `> where python`

        5. CBC solver options are set using the same conventions as the command line interface, which are [documented here](https://projects.coin-or.org/CoinBinary/export/1059/OptimizationSuite/trunk/Installer/files/doc/cbcCommandLine.pdf). You can view option documentation through the command line interface. To do this, open a command line window in the folder containing the `cbc.exe` solver. Enter the command `cbc`.

            List the available commands by typing `?`. 
            
            Choose a command and type it's name followed by `??` to get full documentation. For example, the command `cutD??` yields: 

            ![CBC binary files](./snip_cbc02-1.png)


            In pyomo, enter the solver option and setting as follows, using the time limit "sec" as an example:
            ```
            solver = pyomo.SolverFactory('cbc')
            solver.options['sec'] = 5
            ```
            


    2. **For Gurobi:**
        1. Make an account on Gurobi using your University email ID. The link to the page is [here](https://www.gurobi.com/).
            ![](./Picture1_Gurobi.png)

        2. Click on “Gurobi Optimizer”
        3. Accept the End User License Agreement
            ![](./Picture2_Gurobi.png)
        4. Download the appropriate version
            ![](./Picture3_Gurobi.png)
        5. Run the installer 
            ![](./Picture4_Gurobi.png)
        6. Click on "Next"
            ![](./Picture5_Gurobi.png)
            ![](./Picture6_Gurobi.png)
        7.Choose the folder in which you would like to install Gurobi
            ![](./Picture7_Gurobi.png)
        8. Click on Install and Run as Administrator
            ![](./Picture8_Gurobi.png)
            ![](./Picture9_Gurobi.png)
        9. Go to "Downloads & Licenses" and click "Academic License"
            ![](./Picture14_Gurobi.png)
        10. You will be directed to a page with a license number.
            ![](./Picture15_Gurobi.png)
        11. Scroll down to find a key
            ![](./Picture16_Gurobi.png)
        12. Open command prompt and type in the key “grbgetkey 6a6e2fba-2e54-11eb…….”
        13. You will be asked to choose the directory in which the license key file should be downloaded. Enter the same directory as the one in which you installed Gurobi.
        14. Gurobi will automatically detect the license



5. **Install Pyomo.** Pyomo is best installed via `pip` or `conda` in the command window. 
    1. Open a command window (with admin rights, if you installed Python using admin rights). 

    2. Install Pyomo. You can refer to the [Pyomo documentation](https://pyomo.readthedocs.io/en/stable/installation.html) for the most recent instructions.    
        `>conda install -c conda-forge pyomo`

        Hit `[y]` when prompted to continue.


6. **Test your installation.**
    Create a new python file where we'll test whether the solver is working appropriately. Paste the following minimal working example into the solver:

    ```
    import pyomo.environ as pyomo
    import random 
    import matplotlib.pyplot as plt

    # Create a model
    model = pyomo.ConcreteModel()

    # Time series
    model.nt = pyomo.Param(initialize = 20)
    model.T = pyomo.Set(initialize = range(model.nt()))

    # Create some random input data
    xtmp = {}
    random.seed(123)
    for t in range(model.nt()):
        xtmp[t] = random.uniform(0,100)

    # Assign parameter values
    model.X_in = pyomo.Param(model.T, initialize=xtmp)
    model.XM = pyomo.Param(initialize=max(xtmp.values()))
    model.X0 = pyomo.Param(initialize=50)

    # setup an array of continuous and binary variables over the time domain
    model.x = pyomo.Var(model.T, domain=pyomo.NonNegativeReals)
    model.y = pyomo.Var(model.T, domain=pyomo.Binary)

    # Maximize x 
    def f_objective(model):
        return sum([model.x[t] for t in model.T])
    model.objective = pyomo.Objective(rule = f_objective, sense = pyomo.maximize)

    # ---Add some constraints

    # x[t] less than X_in for all t
    def f_x_lim(model, t):
        return model.x[t] <= model.X_in[t]
    model.c_x_lim = pyomo.Constraint(model.T, rule = f_x_lim)

    # x[t] is limited by value of binary y[t]
    def f_x_y(model, t):
        return model.x[t] <= model.XM()*model.y[t]
    model.c_x_y = pyomo.Constraint(model.T, rule = f_x_y)

    # y[t] can only be 1 when X_in[t] > X0
    def f_y_x0(model, t):
        return model.y[t] <= model.X_in[t] / model.X0
    model.c_y_x0 = pyomo.Constraint(model.T, rule = f_y_x0)

    # ------ solve and print out results
    #solver setup
    #solver = pyomo.SolverFactory('glpk')
    #solver = pyomo.SolverFactory('gurobi')
    solver = pyomo.SolverFactory('cbc')
    res = solver.solve(model)

    print(res)
    print(model.objective())

    # Space-separated list of variables to print
    pouts = "X_in x y".split()

    # Automatically handle printing
    print('t\t'+'\t'.join(pouts))

    for t in model.T:
        fmt = "{:d}" + "\t{:.1f}"*(len(pouts))
        outs = []
        for o in pouts:
            try:
                outs.append(model.__getattribute__(o)[t]() )
            except:
                outs.append(model.__getattribute__(o)[t] )
        print( fmt.format(*([t]+outs)) )

    plt.plot([mt for mt in model.T], [mx() for mx in model.x.values()], \
            [mt for mt in model.T], [mx for mx in model.X_in.values()], \)
            [0, model.nt()], [model.X0(), model.X0()], 'r--')
    plt.show()
    ```

    You should get something that qualitively looks like the following. The program considers input (orange) values, and maximizes output values (blue) while requiring that any value below the minimum threshold (the red dotted line at 50, in this case) be forced to zero by the binary variable:   

    ![MWE results](./snip_cbc04.png)

