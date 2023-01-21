#!/bin/bash

# Functions to be shared amongs scripts

scriptDir=$( dirname "${BASH_SOURCE[0]}" );
source ${scriptDir}/settings;

addSudo () {
    if [ "${NEED_SUDO}" == true ]; then
        echo "sudo";
        return 0;
    fi
    return 0;
}
