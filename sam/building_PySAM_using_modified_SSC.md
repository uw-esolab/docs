# Building PySAM using Modified SSC 

## The Goal <a id="goal"></a>


At the end of this process, we will build an `Export` version of an `ssc` library and a `SAM_api` library. These will be used to auto-generate `.c` and `.pyi` files for each module from `ssc`. `PySAM` will then generate extensions to individual libraries for each module and ultimately a `.whl` file that you can use to `pip install` your bespoke version of `PySAM`! 

---
## 0. Some Setup <a id="setupbash"></a>
Note: This process assumes you are running Linux.

I am working off some parent `sam_dev` directory in which I will clone and build all necessary repositories and files. Bash is pretty fun, so I set a environment variable by running
```
gedit $HOME/.bashrc
```
and adding a new line stating
```
export DEVDIR=<full_path_to_sam_dev>
```
ending with 
```
source $HOME/.bashrc
```
to enact the changes and use the new environment variable. I will use `$DEVDIR` frequently in the command line in the rest of the doc to represent the full path to the `sam_dev` directory.



## 1. Install wxWidgets-3.1.1
---

Make sure `wxWidgets-3.1.1` is installed and linked properly by following [Step 2](https://github.com/NREL/SAM/wiki/Linux-Build-Instructions#2-install-wxwidgets-311) in the original Linux wiki from NREL. **This only needs to be done once on your machine**.

There is an extra note on Step 2.4 [here](https://github.com/uw-esolab/docs/blob/main/sam/debugSSCwithPySSC_Linux_CodeLiteIDE.md#1-build-sam-on-linux).


## 2. Install googletest
---
1. Starting in the `$DEVDIR` directory, clone `googletest`.

    ```
    cd $DEVDIR

    git clone https://github.com/google/googletest.git
    ```

2. Build googletest in the Release configuration. I made it with an additional CodeLite workspace which could be useful later.

    ```
    mkdir googletest/build

    cd googletest/build

    cmake -G "CodeLite - Unix Makefiles" -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_SYSTEM_VERSION=10.0 -Dgtest_force_shared_crt=ON ..

    make -j6
    ```

    If successful, you will see the files `libgtest.a` and `libgtest_main.a` in the `$DEVDIR/googletest/build/lib` directory.

    Change the `-j[N]` flag if you want to build using more jobs/cores (currently using `N=6` jobs).


## 3. Install and Build the LK Repository
---
1. Clone `lk` from the standard NREL repository:

    ```
    cd $DEVDIR

    git clone https://github.com/NREL/lk.git
    ```

2. Build `lk` in the Release configuration within a build folder

    ```
    mkdir lk/build

    cd lk/build

    cmake -DCMAKE_BUILD_TYPE=Release ..

    make -j6
    ```
    You should see `lk.a` in the `$DEVDIR/lk/build` directory.


## 4. Install and Build the WEX Repository
---
1. Clone `wex` from the standard NREL repository:

    ```
    cd $DEVDIR

    git clone https://github.com/NREL/wex.git
    ```

2. Build `wex` in the Release configuration within a build folder

    ```
    mkdir wex/build

    cd wex/build

    cmake -DCMAKE_BUILD_TYPE=Release -DSAM_SKIP_TOOLS=1 ..

    make -j6
    ```
    Here, we skip building `SAM` tools for a faster build. You should see `wex.a` in the `$DEVDIR/wex/build` directory.


## 5. Install Your Modified SSC Repository
---
1. Clone your modified repository, wherever it may be. For the NE2 project, I am used a double-forked repository:

    ```
    cd $DEVDIR

    git clone https://github.com/gjsoto/ssc.git
    ```

2. Check out the relevant branch:

    ```
    cd ssc
    git checkout model1testmerge
    ```
    NOTE: this branch is subject to change. The current branch should work.


## 6. Install SAM and PySAM Repositories
---
1. Clone the `SAM` repository and checkout the most current, stable, `PySAM`-friendly branch:

    ```
    cd $DEVDIR

    git clone https://github.com/NREL/sam.git
    
    cd sam

    git checkout pysam-v2.2.2
    ```

3. Clone the `PySAM` repository, the default branch should be fine:

    ```
    cd $DEVDIR

    git clone https://github.com/NREL/pysam.git
    ```

## 7. Set Environment Variables
---
Make sure all environment variables in the `$HOME/.bashrc` script are set correctly, as was done in [Step 0](#setupbash), as follows:

    
    export GTEST=$DEVDIR/googletest
    export GTEST_LIB=$DEVDIR/googletest/build/lib/libgtest.a
    export LKDIR=$DEVDIR/lk
    export WEXDIR=$DEVDIR/wex
    export SSCDIR=$DEVDIR/ssc
    export SAMNTDIR=$DEVDIR/sam
    export PYSAMDIR=$DEVDIR/pysam 

These are set everytime a terminal is opened.

Note: make sure that the `$PYSAMDIR` last folder is all lowercase as shown. 

## 8. Modify PySAM Auto-Generated Files <a id="modifypysam"></a>
---
Delete all files in the following folders:
```
$DEVDIR/pysam/docs/modules
$DEVDIR/pysam/modules
$DEVDIR/pysam/stubs/stubs
$DEVDIR/pysam/files #get rid of libraries if they exist
$DEVDIR/pysam/dist #if it exists
```

## 9. Build Modified SSC
---

Once environment variables are set, whether in terminal or in `bashrc`, we can build `ssc` within a `build` folder as follows:

```
cd $DEVDIR

mkdir build_ssc

cd build_ssc

cmake ${SSCDIR} -DCMAKE_BUILD_TYPE=Export -DSAM_SKIP_TOOLS=1 -DSAMAPI_EXPORT=1 -DSAM_SKIP_TESTS=1 ../ssc/

make -j6
```

The big difference here is that we are specified the Export configuration and allowing SAM API export. If the build is successful, you will find `libssc.so` in the `$DEVDIR/build_ssc/ssc` directory.

Some major changes that make `DAO-tk` things play nice with newer `SAM` and `PySAM` features:

- in the file `$DEVDIR/ssc/ssc/sscapi.cpp`, renamed the method `ssc_stateful_module_create` to `ssc_stateful_module_setup`. This now matches current `SAM`

## 10. Build SAM + API
---

1. Create a new folder to build `sam`:

    ```
    cd $DEVDIR

    mkdir build_sam

    cd build_sam
    ```

2. Define environment variables in the terminal to accurately point to `ssc` libraries:

    ```
    export SSC_LIB=$DEVDIR/build_ssc/ssc

    export SSCE_LIB=$DEVDIR/build_ssc/ssc
    ```

3. Need to modify `CMakeLists` because it is outdated and reads `ssc.so` rather than `libssc.so`:

    ```
    gedit ../sam/api/api_autogen/CMakeLists.txt
    ```

    In Line 145-146, which should read:

    ```
        find_library( SSC_LIB
            NAMES ssc.dylib ssc.lib ssc.so
    ```
    change the third instance of `NAMES` from "`ssc.so`" to "`libssc.so`". 

    **NOTE**: this might be fixed in a future NREL/sam commit.

4. Create CMake files and build `sam`:

    ```
    cmake ${SAMNTDIR}/api -DCMAKE_BUILD_TYPE=Export -DSAMAPI_EXPORT=1 -DSAM_SKIP_AUTOGEN=0 ../sam/api

    make -j6
    ```

    The main difference here is to disable the "skip autogen" feature. This forces the process to parse through the list of `cmod` modules defined in the `module_table` within `$DEVDIR/ssc/sscapi.cpp`.


    At this point, here are things that should have happened to `$DEVDIR/pysam`:

    - `$DEVDIR/pysam/files` should now have `libssc.so` and `libSAM_api.so`
    - `$DEVDIR/pysam/docs/modules` should now have regenerated some `.rst` files for all modules in our modified `ssc`
    - `$DEVDIR/pysam/modules` should now have generated `.c` files for all modules
    - `$DEVDIR/pysam/stubs/stubs` should now have generated `.pyi` files for all modules




## 11. Build PySAM
---
Here, this mimicks the steps outlined within the `build_manylinux.sh` script within the `PySAM`. 

1. Make sure you are in your desired Python environment, or create a new one with some version of Python 3

    ```
    cd $DEVDIR/pysam

    conda create --name pysam_env python=3.7 -y

    conda activate pysam_env
    ```

    You can skip the second line if you already have a preferred Python environment in conda. Could also do this through standard Python environments, but I usually use conda. 

2. Install PySAM requirements and remove current versions

    ```
    pip install -r tests/requirements.txt

    pip uninstall NREL-PySAM NREL-PySAM-stubs
    ```

3. Run the `PySAM` installation, making sure the relevant files are deleted as stated in [this step](#modifypysam):

    ```
    python setup.py install
    ```

    There should now be a file in `$DEVDIR/pysam/dist` called `NREL-PySAM-v2.2.2-cp37-linux_x86_64.egg`.

4. Run tests

    ```
    python -m pytest -s tests
    ```

    Last time I ran this, I got 22 `PASSED` and 7 `WARNINGS`.

5. Create `.whl` file for `PySAM`

    ```
    python setup.py bdist_wheel
    ```

    There should now be a file in `$DEVDIR/pysam/dist` called `NREL-PySAM-v2.2.2-cp37-linux_x86_64.whl`. 

6. Manually `pip` install this new version of `PySAM`

    ```
    pip install dist/NREL-PySAM-v2.2.2-cp37-linux_x86_64.whl
    ```
    being sure to substitute the actual name of the `.whl` file. 

7. You can now use the custom version of `PySAM` and new modules you may have created in `ssc`!
