# Python Installation & Setup for Students

## Document info

| Last update | Author         | Notes or changes                    |
|-------------|----------------|-------------------------------------|
| 2022/07/08  | Wagner         | Adding learning resources           |
| 2020/10/14  | Wagner         | Moving to markdown format           |
| 2020/10/13  | Springate      | Initial creation                    |

## Learning resources
Once you've installed Python following the procedure outlined below, you may find the following resources useful in learning Python and its common packages:

* General text on programming with Python used as the language of implementation: [Think Python](https://greenteapress.com/wp/think-python-2e/)

The following packages are used by ESOLab students roughly in order of most common usage:
| Package   |   Description                                             |
|-----------|-----------------------------------------------------------|
| matplotlib| general purpose plotting and visualizaiton library        |
| numpy     | matrix and mathematical functions and operations          |
| pandas    | dataframe manipulations (think 'Excel' for Python)        |
| scipy     | algorithms for optimization, statistics, matrix inversion |
|           | _scipy.optimize_: function minimization and root finding    |
|           | _scipy.sparse_: tools for sparse matrix manipulation        |
|           | _scipy.sparse.linalg.spsolve_: sparse matrix inversion      |
| jupyter   | web-based interactive notebook for running python code    | 
| plotly    | browser-based interactive plotting and visualization      |
| multiprocessing| allows running processes in parallel                 | 
| pyomo     | optimization modeling language for interfacing with commercial or open-source solvers | 
| pvlib     | models of solar PV, sun position, clear sky irradiance    |
| scikit-learn | machine learning toolkit for python                    | 
| tslearn   | machine learning for time series data                     |
| pytorch   | deep learning using GPU and CPU processing                |
| iapws     | accurate steam properties from IAPWS                      |
| pint      | engineering unit management and conversion                | 
| django    | a toolkit for website development                         |
|||
|||



## Operating System(s) and requirements
* These instructions are based on Installation for a Windows 10, 64-bit operating system. 

## Purpose
Installs Python 3+ on a local machine.

## Procedure

1.	Visit [this page](https://docs.conda.io/en/latest/miniconda.html) to download Miniconda, a free minimal installer for Conda Python.

2. Choose the appropriate option for your system.

    ![](./image001.png)

3. A file named “Miniconda3-latest-Windows-x86_64” will start downloading. 

    ![](./image003.png)

4.	Double click the installer to begin the installation process. 
    * Select “I Agree”
    * Select “Just Me” for Installation Type 

        ![](./image005.png)
    
    * Select default location for Install Location

        ![](./image006.png)

    * Select all boxes for Advanced Installation Options

        ![](./image007.png)

    * Install
    * Finish

5. Install Common Python Packages

    * Open Command Prompt
    * Follow the commands in the window below to install commonly-used packages. Type “y” to proceed when prompted. 
        ```
        > conda install numpy
        > conda install pandas
        > conda install scipy
        > conda install matplotlib
        ```
        
    * For projects that require NREL's [PySAM](https://sam.nrel.gov/software-development-kit-sdk/pysam.html) package, add the NREL channel and the PySAM package:
        ```
        > conda config --env --append channels nrel
        > conda install nrel-pysam nrel-pysam-stubs
        ```
