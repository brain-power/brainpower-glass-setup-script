#!/bin/bash
#This script displays a menu which can be used to upgrade Glass software to XE24 version along with installing and enabling BrainUpdater app.
#Author: Rakesh Gopathi
#Date: June 2021

HORIZONTALLINE="========================================================================================================="
HINT="HINT       :     "
ERROR="ERROR      :     "
MESSAGE="MESSAGE    :     "
DEVICE="DEVICE     :     "
INPUT="INPUT      :     "

XE24_ZIP_FILE_NAME=xe24.zip
ROOTED_BOOT_IMAGE_FILE_NAME=rooted_boot.img
SYSTEM_IMAGE_FILE_NAME=system.img
RECOVERY_IMAGE_FILE_NAME=recovery.img
BRAINUPDATER_APK_FILE_NAME=brainupdater-v7.5.apk

FILES_DIR_PATH=files
XE24_ZIP_FILE_PATH="$FILES_DIR_PATH/$XE24_ZIP_FILE_NAME"
ROOTED_BOOT_IMAGE_FILE_PATH="$FILES_DIR_PATH/$ROOTED_BOOT_IMAGE_FILE_NAME"
SYSTEM_IMAGE_FILE_PATH="$FILES_DIR_PATH/$SYSTEM_IMAGE_FILE_NAME"
RECOVERY_IMAGE_FILE_PATH="$FILES_DIR_PATH/$RECOVERY_IMAGE_FILE_NAME"
BRAINUPDATER_APK_FILE_PATH="$FILES_DIR_PATH/$BRAINUPDATER_APK_FILE_NAME"

XE24_SYSTEM_FILES_ZIP_DOWNLOAD_LINK=https://storage.googleapis.com/support-kms-prod/bTh25b2gcZx5f7apQdJU3lULYTTBoZDHqdsr
XE24_ROOTED_BOOT_FILE_DOWNLOAD_LINK=https://storage.googleapis.com/glass_gfw/glass_1-img-5585826/boot.img
BRAINUPDATER_APK_FILE_DOWNLOAD_LINK="https://ssl-empowered-brain.brainpower-api.com/api/brainupdater/package/com.brainpower.brainupdater/v/7.5?flavor=home&ts=5451089&sig=mbdLwefixOzzU9G4jZY3pJPn2GvYMMeuYEDQlcnauLs%3D"

InstallADB() {
    echo -e "$MESSAGE Attempting to install 'adb' command .... \n"
    sudo apt-get -qq update && sudo apt-get -qq --yes --allow-downgrades --allow-unauthenticated --allow-remove-essential install android-tools-adb
}

Installfastboot() {
    echo -e "$MESSAGE Attempting to install 'fastboot' command ....\n"
    sudo apt-get -qq update && sudo apt-get -qq --yes --allow-downgrades --allow-unauthenticated --allow-remove-essential install android-tools-fastboot
}

Installcurl() {
    echo -e "$MESSAGE Attempting to install 'curl' command ....\n"
    sudo apt-get -qq update && sudo apt-get -qq --yes --allow-downgrades --allow-unauthenticated --allow-remove-essential install curl
}


checkAndInstallShellCommands() {
    if ! command -v adb &> /dev/null; then
        InstallADB
    fi
    if ! command -v fastboot &> /dev/null; then
        Installfastboot
    fi
    if ! command -v curl &> /dev/null; then
        Installcurl
    fi
}

checkAndDownloadDependencies() {
    IS_SETUP_REQUIRED=false
    echo -e "$MESSAGE Starting dependency checks ....."
    echo -e "\n**** Shell command dependencies ****\n"
    if ! command -v adb &> /dev/null; then
        IS_SETUP_REQUIRED=true
        echo -e "$MESSAGE 'adb' command is not available"
    else
        echo -e "$MESSAGE 'adb' command is available"
    fi

    if ! command -v fastboot &> /dev/null; then
        IS_SETUP_REQUIRED=true
        echo -e "$MESSAGE 'fastboot' command is not available"
    else
        echo -e "$MESSAGE 'fastboot' command is available"
    fi

    if ! command -v curl &> /dev/null; then
        IS_SETUP_REQUIRED=true
        echo -e "$MESSAGE 'curl' command is not available"
    else
        echo -e "$MESSAGE 'curl' command is available"
    fi

    if "$IS_SETUP_REQUIRED"; then
        echo -e "$MESSAGE The script needs to download few shell commands to function properly"
        read -p "Press [ENTER] to continue installation: "

        checkAndInstallShellCommands
    else
        echo -e "$MESSAGE All the necessary shell command dependencies are available."
    fi

    echo -e "\n**** File dependencies ****\n"
    
    if test -f "$XE24_ZIP_FILE_PATH"; then
        echo -e "$MESSAGE XE24 system image exists on the system"
    else
        echo -e "$MESSAGE The script needs to download XE24 system image for Glass"
        echo -e "$MESSAGE Will download XE24 image lazily when needed"
    fi

    echo -e "\n**** Dependency checks completed ****\n"
}

printFastbootMenuHeader() {
    clear
    echo -e "\n$HORIZONTALLINE"
    echo "              BrainPower Glass Setup -> Flash Glass device to firmare version XE-24"
    echo $HORIZONTALLINE
}

printGoBackOrExitMenu() {
    echo -e "\nSelect an option from the menu below to continue: "
    echo -e "1) Go back to main menu"
    echo -e "2) Exit\n"
}

handleGoBackAndExitMenu() {
    read -p "Please type the menu option number you selected (1 or 2): " option
    if [ "$option" -eq "$option" 2> /dev/null ]; then
        if [ $option -lt 1 -o $option -gt 2 ]; then
            echo -e "$ERROR The provided selection is not valid"
            echo -e "$HINT Please enter an option between 1 and 2"
            handleGoBackAndExitMenu
        elif [ $option -eq 1 ]; then 
            printAndHandleMainMenu
        elif [ $option -eq 2 ]; then
            echo -e "\n$MESSAGE Adios!\n"
            exit
        fi
    else
        echo -e "$ERROR The provided selection is not a number"
        echo -e "$HINT Please enter an option between 1 and 2"
        handleGoBackAndExitMenu
    fi
}

printAndHandleGoBackAndExitMenu() {
    printGoBackOrExitMenu
    handleGoBackAndExitMenu
}

printTryAgainMenu() {
    echo -e "\nSelect an option from the menu below to continue: "
    echo -e "1) Check for connected devices again"
    echo -e "2) Go back to main menu"
    echo -e "3) Exit\n"
}

handleTryAgainMenuForFastboot() {
    read -p "Please type the menu option number you selected : " option
    if [ "$option" -eq "$option" 2> /dev/null ]; then
        if [ $option -lt 1 -o $option -gt 3 ]; then
            echo -e "$ERROR The provided selection is not valid"
            echo -e "$HINT Please enter an option between 1 and 3"
            handleTryAgainMenuForFastboot
        elif [ $option -eq 1 ]; then 
            handleFastbootMenu
        elif [ $option -eq 2 ]; then
            printAndHandleMainMenu
        elif [ $option -eq 3 ]; then
            echo -e "\n$MESSAGE Adios!\n"
            exit
        fi
    else
        echo -e "$ERROR The provided selection is not a number"
        echo -e "$HINT Please enter an option between 1 and 3"
        handleTryAgainMenuForFastboot
    fi
}

printAndHandleTryAgainMenuForFastboot() {
    printTryAgainMenu
    handleTryAgainMenuForFastboot
}

handleTryAgainMenuForBrainUpdater() {
    read -p "Please type the menu option number you selected : " option
    if [ "$option" -eq "$option" 2> /dev/null ]; then
        if [ $option -lt 1 -o $option -gt 3 ]; then
            echo -e "$ERROR The provided selection is not valid"
            echo -e "$HINT Please enter an option between 1 and 3"
            handleTryAgainMenuForBrainUpdater
        elif [ $option -eq 1 ]; then 
            handleBrainUpdaterMenu
        elif [ $option -eq 2 ]; then
            printAndHandleMainMenu
        elif [ $option -eq 3 ]; then
            echo -e "\n$MESSAGE Adios!\n"
            exit
        fi
    else
        echo -e "$ERROR The provided selection is not a number"
        echo -e "$HINT Please enter an option between 1 and 3"
        handleTryAgainMenuForBrainUpdater
    fi
}

printAndHandleTryAgainMenuForBrainUpdater() {
    printTryAgainMenu
    handleTryAgainMenuForBrainUpdater
}

handleTryAgainMenuForEnableBrainUpdaterApp() {
    read -p "Please type the menu option number you selected : " option
    if [ "$option" -eq "$option" 2> /dev/null ]; then
        if [ $option -lt 1 -o $option -gt 3 ]; then
            echo -e "$ERROR The provided selection is not valid"
            echo -e "$HINT Please enter an option between 1 and 3"
            handleTryAgainMenuForEnableBrainUpdaterApp
        elif [ $option -eq 1 ]; then 
            handleEnableBrainUpdaterApp
        elif [ $option -eq 2 ]; then
            printAndHandleMainMenu
        elif [ $option -eq 3 ]; then
            echo -e "\n$MESSAGE Adios!\n"
            exit
        fi
    else
        echo -e "$ERROR The provided selection is not a number"
        echo -e "$HINT Please enter an option between 1 and 3"
        handleTryAgainMenuForEnableBrainUpdaterApp
    fi
}

printAndHandleTryAgainMenuForEnableBrainUpdaterApp() {
    printTryAgainMenu
    handleTryAgainMenuForEnableBrainUpdaterApp
}

checkAndDownloadXE24SystemImageForGlass() {
    if ! test -d "$FILES_DIR_PATH"; then
        mkdir $FILES_DIR_PATH
    fi
    if test -f "$XE24_ZIP_FILE_PATH"; then
        if ! test -f "$SYSTEM_IMAGE_FILE_PATH"; then
            unzip $XE24_ZIP_FILE_PATH -d $FILES_DIR_PATH
        fi
    else
        echo -e "$ERROR Missing XE24 system image zip file"
        echo -e "$MESSAGE The script needs to download XE24 system image zip to continue"
        read -p "Press [ENTER] to start download: "
        echo -e "$MESSAGE Downloading XE24 system image for Glass"
        curl $XE24_SYSTEM_FILES_ZIP_DOWNLOAD_LINK --output $XE24_ZIP_FILE_PATH
        echo -e "$MESSAGE Unzipping the XE24 system image download"
        unzip $XE24_ZIP_FILE_PATH -d $FILES_DIR_PATH
        echo -e "$MESSAGE Completed the download and extraction of XE24 system image for Glass"
    fi
}

checkAndDownloadXE24RootedBootImageForGlass() {
    if ! test -f "$ROOTED_BOOT_IMAGE_FILE_PATH"; then
        echo -e "$ERROR Missing rooted boot image file"
        echo -e "$MESSAGE The script needs to download rooted boot image to continue"
        read -p "Press [ENTER] to start download: "
        echo -e "$MESSAGE Downloading rooted boot image for Glass"
        curl $XE24_ROOTED_BOOT_FILE_DOWNLOAD_LINK --output $ROOTED_BOOT_IMAGE_FILE_PATH
        echo -e "$MESSAGE Completed download of rooted boot image for Glass"
    fi
}

checkAndDownloadBrainUpdaterAPKFileForGlass() {
   if ! test -f "$BRAINUPDATER_APK_FILE_PATH"; then
        echo -e "$ERROR Missing the BrainUpdater APK file"
        echo -e "$MESSAGE The script needs to download the BrainUpdater APK file to continue"
        read -p "Press [ENTER] to start download: "
        echo -e "$MESSAGE Downloading the BrainUpdater APK file"
        curl $BRAINUPDATER_APK_FILE_DOWNLOAD_LINK --output $BRAINUPDATER_APK_FILE_PATH
        echo -e "$MESSAGE Completed download of the BrainUpdater APK file"
    fi
}

handleFastbootMenu() {
    INDEX=0
    for device in `fastboot devices | grep fastboot | awk '{print $1}'`; do
        if [ $INDEX -eq 0 ]; then
            echo -e "$MESSAGE Found the following devices accessible through fastboot \n"
        fi
        let INDEX=${INDEX}+1
        echo -e "$DEVICE [${INDEX}] Device Id -> $device\n"
    done
    if [ $INDEX -eq 0 ]; then
        echo -e "$ERROR Didn't find any devices connected in fastboot mode"
        echo -e "$HINT Please ensure that the device is connected to this computer and is in fastboot mode"
        printAndHandleTryAgainMenuForFastboot
    else
        read -p "Press [ENTER] to upgrade Glass firmare to XE24 on above devices: "

        for device in `fastboot devices 2>&1 | grep -v -e daemon -v -e devices | awk '{print $1}'`; do
            let INDEX=${INDEX}+1
            echo "$MESSAGE [`date +%Y-%m-%d_%H:%M:%S`] Starting to process device[$INDEX] $device " 2>&1 | tee -a setup_device.log

            echo "*** Unlocking device[$INDEX] $device ***" 2>&1 | tee -a setup_device.log
            sudo fastboot -s $device oem unlock 
            sudo fastboot -s $device oem unlock
            echo "$MESSAGE Device[$INDEX] $device unlocked at `date +%Y-%m-%d_%H:%M:%S`" 2>&1 | tee -a setup_device.log

            sudo fastboot -s $device flash boot $ROOTED_BOOT_IMAGE_FILE_PATH
            sudo fastboot -s $device flash recovery $RECOVERY_IMAGE_FILE_PATH
            sudo fastboot -s $device flash system $SYSTEM_IMAGE_FILE_PATH
            echo "$MESSAGE Device[$INDEX] $device all partitions flashed at `date +%Y-%m-%d_%H:%M:%S`" 2>&1 | tee -a setup_device.log

            sudo fastboot -s $device reboot 
            echo "$MESSAGE [`date +%Y-%m-%d_%H:%M:%S`] Device[$INDEX] $device completed if no errors logged here" 2>&1 |tee -a setup_device.log;
        done

        printAndHandleGoBackAndExitMenu
    fi
}

printAndHandleFastbootMenu() {
    clear
    printFastbootMenuHeader
    checkAndDownloadXE24SystemImageForGlass
    checkAndDownloadXE24RootedBootImageForGlass
    handleFastbootMenu
}

printBrainUpdaterMenuHeader() {
    echo -e "\n$HORIZONTALLINE"
    echo "              BrainPower Glass Setup -> Install latest version of BrainUpdater app"
    echo $HORIZONTALLINE
}

handleBrainUpdaterMenu() {
    checkAndDownloadBrainUpdaterAPKFileForGlass

    INDEX=0
    for device in `adb devices 2>&1 | grep -v -e daemon -v -e devices | awk '{print $1}'`; do
        if [ $INDEX -eq 0 ]; then
            echo -e "$MESSAGE Found the following devices accessible through adb"
        fi
        let INDEX=${INDEX}+1
        echo -e "$DEVICE [${INDEX}] Device Id -> $device\n"
    done

    if [ $INDEX -eq 0 ]; then
        echo -e "$ERROR Didn't find any devices connected through adb"
        echo -e "$HINT Please ensure that adb is enabled on the device and connected to this computer"
        printAndHandleTryAgainMenuForBrainUpdater
    else
        read -p "Press [ENTER] to continue installation: "

        INDEX=0
        for device in `adb devices 2>&1 | grep -v -e daemon -v -e devices | awk '{print $1}'`; do 
            let INDEX=${INDEX}+1
            # pushes apk file on Glass device and installs it as a system app
            echo "$MESSAGE Started installing BrainUpdater on device[$INDEX] $device $3"

            echo "*** Pushing APK file to device[$2] $device ***" 2>&1
            adb -s $device push $BRAINUPDATER_APK_FILE_PATH /data/local/tmp
            adb -s $device shell mount -o remount,rw /system
            adb -s $device shell "ls -d /system/priv-app/* | grep "brainupdater" | xargs rm -f"
            adb -s $device shell cp /data/local/tmp/$BRAINUPDATER_APK_FILE_NAME /system/priv-app
            adb -s $device reboot
            echo -e "$MESSAGE Installation of BrainUpdater APK -> $BRAINUPDATER_APK_NAME on Device $device is successful"
        done

        printAndHandleGoBackAndExitMenu
    fi
}

printAndHandleBrainUpdaterMenu() {
    clear
    printBrainUpdaterMenuHeader
    handleBrainUpdaterMenu
}

printEnableBrainUpdaterMenuHeader() {
    echo -e "\n$HORIZONTALLINE"
    echo "              BrainPower Glass Setup -> Enable BrainUpdater app"
    echo $HORIZONTALLINE
}

handleEnableBrainUpdaterApp() {
    INDEX=0
    for device in `adb devices 2>&1 | grep -v -e daemon -v -e devices | awk '{print $1}'`; do
        if [ $INDEX -eq 0 ]; then
            echo -e "$MESSAGE Found the following devices accessible through adb"
        fi
        let INDEX=${INDEX}+1
        echo -e "$DEVICE [${INDEX}] Device Id -> $device\n"
    done

  if [ $INDEX -eq 0 ]; then
        echo -e "$ERROR Didn't find any devices connected through adb"
        echo -e "$HINT Please ensure that adb is enabled on the device and connected to this computer"
        printAndHandleTryAgainMenuForEnableBrainUpdaterApp
    else
        read -p "Press [ENTER] to register BrainUpdater app with necessary services and braodcast recievers: "

        INDEX=0
        for device in `adb devices 2>&1 | grep -v -e daemon -v -e devices | awk '{print $1}'`; do 
            let INDEX=${INDEX}+1
            echo "$MESSAGE Started MainActivity in BrainUpdater App on device[$INDEX] $device $3"
            adb -s $device shell am start -n "com.brainpower.brainupdater/.MainActivity"
            echo -e "$MESSAGE Command executed"
        done

        printAndHandleGoBackAndExitMenu
    fi
}

printAndHandleEnableBrainUpdaterApp() {
    clear
    printEnableBrainUpdaterMenuHeader
    handleEnableBrainUpdaterApp
}

printHeader() {
    echo -e "\n$HORIZONTALLINE"
    echo "                                  BrainPower Glass Setup                                      "
    echo $HORIZONTALLINE
}

printHandleBPAppsInstalled() {
    echo -e "\n$HORIZONTALLINE"
    echo "              BrainPower Glass Setup -> Print installed brainpower apps"
    echo $HORIZONTALLINE
}

handleBPAppsInstalled() {
    INDEX=0
    for device in `adb devices 2>&1 | grep -v -e daemon -v -e devices | awk '{print $1}'`; do
        if [ $INDEX -eq 0 ]; then
            echo -e "$MESSAGE Found the following devices accessible through adb"
        fi
        let INDEX=${INDEX}+1
        echo -e "$DEVICE [${INDEX}] Device Id -> $device\n"
    done

  if [ $INDEX -eq 0 ]; then
        echo -e "$ERROR Didn't find any devices connected through adb"
        echo -e "$HINT Please ensure that adb is enabled on the device and connected to this computer"
        printAndHandleTryAgainMenuForBPAppsInstalled
    else
        read -p "Press [ENTER] to print package names of all brainpower apps installed on the connected devices "

        INDEX=0
        for device in `adb devices 2>&1 | grep -v -e daemon -v -e devices | awk '{print $1}'`; do 
            let INDEX=${INDEX}+1
            echo "$MESSAGE Installed BrainPower apps on device[$INDEX] $device $3"
            adb -s $device shell pm list packages | grep brainpower
            echo -e "\n"
        done

        printAndHandleGoBackAndExitMenu
    fi
}

printAndHandleTryAgainMenuForBPAppsInstalled() {
    printTryAgainMenu
    handleTryAgainMenuForBPAppsInstalled
}

handleTryAgainMenuForBPAppsInstalled() {
     read -p "Please type the menu option number you selected : " option
    if [ "$option" -eq "$option" 2> /dev/null ]; then
        if [ $option -lt 1 -o $option -gt 3 ]; then
            echo -e "$ERROR The provided selection is not valid"
            echo -e "$HINT Please enter an option between 1 and 3"
            handleTryAgainMenuForEnableBrainUpdaterApp
        elif [ $option -eq 1 ]; then 
            handleEnableBrainUpdaterApp
        elif [ $option -eq 2 ]; then
            printAndHandleMainMenu
        elif [ $option -eq 3 ]; then
            echo -e "\n$MESSAGE Adios!\n"
            exit
        fi
    else
        echo -e "$ERROR The provided selection is not a number"
        echo -e "$HINT Please enter an option between 1 and 3"
        handleTryAgainMenuForEnableBrainUpdaterApp
    fi
}

printAndHandleBPAppsInstalled() {
    clear
    printHandleBPAppsInstalled
    handleBPAppsInstalled
}

printMenuOptions() {
    echo "1) Update Glass device to firmware version XE-24"
    echo "2) Install the latest version of the BrainUpdater app"
    echo "3) Enable the BrainUpdater app"
    echo "4) Print installed brainpower apps on connected android devices"
    echo "5) Exit"
    echo -e "$HORIZONTALLINE\n"
}

printMainMenu() {
    clear
    printHeader
    printMenuOptions
}

handleMainMenuInteraction() {
    read -p "Please type the menu option number you selected: " option

    if [ "$option" -eq "$option" 2> /dev/null ]; then
        if [ $option -lt 1 -o $option -gt 5 ]; then
            echo -e "$ERROR The provided selection is not valid"
            echo -e "$HINT Please enter an option between 1 and 5"
            handleMainMenuInteraction
        elif [ $option -eq 1 ]; then 
            printAndHandleFastbootMenu
        elif [ $option -eq 2 ]; then
            printAndHandleBrainUpdaterMenu
        elif [ $option -eq 3 ]; then
            printAndHandleEnableBrainUpdaterApp
        elif [ $option -eq 4 ]; then
            printAndHandleBPAppsInstalled
        elif [ $option -eq 5 ]; then
            echo -e "\n$MESSAGE Adios!\n"
            exit
        fi
    else
        echo -e "$ERROR The provided selection is not a number"
        echo -e "$HINT Please enter an option between 1 and 4"
        handleMainMenuInteraction
    fi
}

printAndHandleMainMenu() {
    printMainMenu
    handleMainMenuInteraction
}

printHeader
checkAndDownloadDependencies
printAndHandleMainMenu



