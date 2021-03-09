# Adding New Files to SSC
---
## New Modules
By new module, I mean adding a new `cmod` file into the `ssc/ssc` subfolder. Note that this is the standalone `ssc` repository folder, not the subfolder under `build`. There is a handy guide in the NREL github wiki found [here](https://github.com/NREL/ssc/wiki/SSC-Compute-Modules). Here are some linux-specific notes in addition to what is already in that wiki:

- Add `cmod_<name>.o` to `ssc/build_android/Makefile-ssc` under 'Objects'
- Add `cmod_<name>.o` to `ssc/build_ios/Makefile-ssc` under 'Objects'
- Add `cmod_<name>.cpp` to `ssc/ssc/CMakeLists.txt`

All other linux-specific rules in the wiki apply. I noted that the `Makefile-ssc` file was supposed to be in the `ssc/build_linux` subfolder but instead found it both in the `ios` and `android` subfolders. 

## Solvers and Other Files
These solvers and other files would be found in the `ssc/tcs` subfolder. They can be solvers or util files with helper methods, etc. For instance, this is where I created a new child class of the `pt_receiver` that acts like a simplified nuclear reactor. 

The same guidance applies from the wiki: start with an existing template and start modifying it from there. Make sure to find the parent/abstract class to understand the existing member functions and constructors, then overload them correctly. 

When creating a new solver, the nomenclature seems to be to name it `csp_solver_<name>` then create both a `.cpp` and `.h` file with that same name. The header files declares member functions, variables, and structs while the `.cpp` file implements them. 

After creating the two corresponding files, add them to SSC by following these steps:

- Add `csp_solver_<name>.o` to `ssc/build_android/Makefile-tcs` under 'Objects'
- Add `csp_solver_<name>.o` to `ssc/build_ios/Makefile-tcs` under 'Objects'
- Add `csp_solver_<name>.cpp` and `csp_solver_<name>.h` to `ssc/tcs/CMakeLists.txt`

No additional steps are necessary (you only add `cmod` module files to `ssc_api`, not solvers). 