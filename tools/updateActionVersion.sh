#!/bin/bash
action="$1"
shift
oldVer="$1"
shift
newVer="$1"
shift

STS=0

################
##
function showUsage
{
cat<<EOH
    Usage: $0 action oldVer newVer dir
    
        Changes string "actions/action@oldVer" to "actions/action@newVer"
        in all *.yml files in the 'dir' directory tree.

        Default directory is './'
EOH
exit 9
}
################################################################
## Useful functions

################
## Reports a message to STDOUT
function reportMsg
{
    for thisLine in "$@"
    do
        echo "${thisLine}"
    done
}

################
## Reports an indented message to STDOUT
function reportIndMsg
{
    for thisLine in "$@"
    do
        echo "${indent}${thisLine}"
    done
}

################
## Reports an Error message
function reportError
{
    for thisLine in "$@"
    do
        reportMsg "  Error: ${thisLine}"
    done
    STS+=1
}

################
## Checks error status, reports the error and exits script
function exitIfError
{
    local exitCode=$1
    shift
    if [ 0 != $exitCode ]
    then
        reportError "$@"
        exit $STS
    fi
}

################
## Checks the value of the first argument setting global STS if not zero
## Reporta an error if other arguments exist.
function checkStatus
{
    local exitCode=$1
    shift

    if [ 0 != $exitCode ]
    then
        STS=${exitCode}
        if [ "" != "$1" ]
        then
            reportError "$@"
        fi
    fi
    return ${exitCode}
}

################
## Ensures that a directory exists, creating it if not and exiting upon failure
function assureHaveDir
{
    if [ ! -d "${destDir}" ]
    then
        mkdir -p "${destDir}"
        exitIfError $? "Creating directory."
    fi
}

################
## Logs a message
function logMsg
{
    for thisLine in "$@"
    do
        echo "${indent}${thisLine}"
    done
}

################
## Logs a directory name
function logDir
{
    logMsg "dir='$1'"
    #reportIndMsg "dir='$1'"
}

################
## Logs a file name being processed
function logFile
{
    logMsg "file='$1'"
}

################
## Logs an Error message without setting status
function logError
{
    for thisLine in "$@"
    do
        logMsg "Error: '$thisLine'"
    done
}

################
## Processes a file
function processFile
{
    local thisFile="$1"
    local sfx=".bu"
    local buFile="${thisFile}${sfx}"
    local info=""
    local exitCode=0

    #echo "sed -i.bu -e 's/actions\/${action}@v${oldVer}/actions\/${action}@v${newVer}/' '${thisFile}'"
    sed -i.bu -e "s/actions\/${action}@v${oldVer}/actions\/${action}@v${newVer}/" "${thisFile}"
    exitCode=$?
    checkStatus $exitCode "sed file '$thisFile'"
    if [ -e "${buFile}" ]
    then
        #info=$(diff --brief "${thisFile}" "${buFile}")
        #if [ "" == "${info}" ]
        #then
        #    echo "File '${thisFile}' NOT changed"
        #else
        #    echo "File '${thisFile}' changed"
        #fi
        rm "${buFile}"
        checkStatus $exitCode "rm file '$thisFile'"
    fi
    return ${exitCode}
}

################
## Processes all subdirectories found
function processSubDirs
{
    for thisItem in *
    do
        if [ "*" != "$thisItem" ] && [ -d "${thisItem}" ]
        then
            processDir "${thisItem}"
        fi
    done
}

################
## Processes a given directory
function processDir
{
    local thisSrcDir="$1"
    #local thisDir=""
    local -a subDirs
    local entryIndent="${indent}"

    logDir "${thisSrcDir}"
    if [ "." != "$thisSrcDir" ]
    then
        pushd "$thisSrcDir" >>/dev/null
        indent="==${indent}"
    fi
    for thisItem in *
    do
        if [ "*" != "$thisItem" ]
        then
            if [ -d "${thisItem}" ]
            then
                subDirs+=("${thisItem}")
            else
                processFile "${thisItem}"
                if [ 0 != $STS ]
                then
                    break
                fi
            fi
        fi
    done
    if [ 0 == $STS ] && [ ${#subDirs[@]} -gt 0 ] && [ "$TRUE" == "$procSubdirs" ]
    then
        for thisDir in "${subDirs[@]}"
        do
            processDir "${thisDir}"
            if [ 0 != $STS ]
            then
                break
            fi
        done
    fi
    if [ "." != "$thisSrcDir" ]
    then
        indent="${entryIndent}"
        popd >>/dev/null
    fi
}

################################################################
## main script
case $action in
    -[h?] | -help | -[H?])
        showUsage
        exit 1
        ;;
    -*)
        echo "Error: Unknown option '${action}'"
        showUsage
        exit 9
        ;;
esac

if [ "" == "${newVer}" ]
then
    echo "Error: Not enough arguments provided."
    showUsage
    exit 8
fi

if [ "" == "${dir}" ]
then
    dir="."
fi

processDir "${dir}"

if [ 0 == $STS ]
then
    echo " $0: Success"
else
    echo " $0: -- FAILED --"
fi
exit $STS
