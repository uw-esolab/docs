# Create an Ubuntu Virtual Machine on Windows 10 Host with Hyper-V

## Document info

| Last update | Author         | Notes or changes                    |
|-------------|----------------|-------------------------------------|
| 2020/12/09  | Wagner         | Initial creation                    |


## Operating System(s) and requirements
* Windows 10
* Hyper-V support
* [Admin rights](https://github.com/uw-esolab/docs/blob/main/admin/admin.md)

## Purpose


## Procedure

1. Make sure Hyper-V capabilities are enabled
    * Open the **Turn Windows features on or off** dialog. You will need admin rights.

    ![](./image001.png)

    * Enable Hypervisor features

    ![](./image002.png)

    ![](./image003.png)

    * Restart your computer. When restarting, launch the BIOS option by repeatedly hitting **F12** during boot. 
        * In the BIOS menu, go to the _Secure Boot_ menu and make sure the option is enabled. Save if needed, and exit.

    * You may need to reboot again.

2. Launch Hyper-V Quick Create

    * Admin rights are required. 
    * If you don't see the Hyper-V Quick Create option in the Windows start menu, then you have not correctly enabled the Hyper-V capabilities in the Windows Features dialog.
    
        ![](./image011.png)
    

    * You should see the following interface. Rename the machine if desired, and select the **Ubuntu 20.04.1 LTS** OS and click "Create Virtual Machine"
    
        ![](./image012.png)

    * Note that the default size for the virtual machine's hard disk is 12GB. This is insufficient for most things you'll want to do with the machine. Unfortunately, Hyper-V doesn't provide an easy way to set the disk size, so we need to take several steps to modify it ourselves. This will involve both editing the virtual machine settings through the Hyper-V tools and running a partition editor from within the virtual machine:

    * Click Edit Settings

        ![](./image013.png)

    * Go to the **Hard Drive** tab and click **Edit** under the Virtual Hard Disk toggle.

        ![](./image014.png)

    * Click **Next**

        ![](./image015.png)

    * Click **Expand**

        ![](./image016.png)

    * Choose a larger hard drive size. The default of 12 GB is almost certainly too small for anything you'll want to do. 32GB is a reasonable size.

        ![](./image017.png)

    * Click **Next** 

        ![](./image018.png)

    * You should return back to the **Edit Settings** dialog.

3. Now **WAIT** and don't click finish or connect yet!! The hard disk size can't be expanded using the Hyper-V dialog alone. We also need to download a disk partitioning tool called _gparted_ and manually modify the disk size.     
        * Go to the [gparted download site](https://gparted.org/download.php) and download the `gparted-live-1.1.0-8-i686.iso` installer (amd64 option didn't work for me)

    * Add a DVD drive to your virtual machine using the SCSI Controller tab

        ![](./image020.png)

    * Configure the DVD drive to use _Location 2_ (or the next unused location), and to point to the _gparted_ image file that you just downloaded. Click Apply.

        ![](./image021.png)

    * Go to the **Firmware** menu and move the DVD drive boot order up to the top of the list.

        ![](./image022.png)

    * Click OK and connect to the machine.

4. When connecting to the machine, you will boot into the _gparted_ iso from the virtual DVD drive. 
    * Hit **Enter** to run the default edition.

        ![](./image030.png)

    * Don't change the keymap

        ![](./image031.png)

    * Use the default settings when prompted

        ![](./image032.png)

    * After booting, you may be prompted to "Fix" a size issue. Click the option to fix. If not, launch the partition editor. Select `/dev/sda1` as the partition to edit. You should see unallocated space to the right of this partition.

        ![](./image034.png)

    * Enter the maximum drive size to use all unallocated space. The drive partition should expand to fill the full space, then click **Resize/Move**

        ![](./image035.png)

    * Apply the changes. The summary dialog should show that the changes were successful.

        ![](./image036.png)

    * Close the partition editor and then choose to **Exit** the session using the icon on the desktop. Choose **Shutdown**.

        ![](./image037.png)

    * Go back into the VM settings and move the boot order of the DVD drive back down to the bottom of the list, then apply settings.

        ![](./image038.png)

5. Connect to the machine. You should be prompted to run through the Ubuntu install process. Complete as desired.

    * If prompted to _Revert_ or _Continue_, choose to **_Continue_**

    * After completing the install, check that your hard drive size was correctly expanded. Open a terminal window ``CTRL+ALT+T``, and type ``df -h``. You should see a list of drive sizes with `/dev/sda1` corresponding to the disk size you specified in step (4). 

        ![](./image039.png)

    
6. When you're done using the virtual machine, turn it off using the Ubuntu (guest) power menu. You can close the Hyper-V host. The state of your machine should be saved for next time. 

7. To connect to the machine in future uses, you will need to launch the Hyper-V Manager software (NOT the Hyper-V Quick Create!!). Make sure to launch the manager using Admin rights, or your virtual machine(s) will not appear in the list when you open the manager.

    ![](./image040.png)

    ![](./image041.png)