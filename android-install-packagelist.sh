#!/bin/bash

# Exit on any error
#set -e

# Function to print usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -v, --verbose   Enable verbose output"
    echo "  -f, --file FILE Specify input file"
    echo "  -p, --profile <priv|work> Specify profile"
    exit 1
}

# Default values
VERBOSE=false
INPUT_FILE=""

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--file)
            if [[ -n "$2" ]]; then
                INPUT_FILE="$2"
                shift 2
            else
                echo "Error: --file requires an argument." >&2
                usage
            fi
            ;;
        -p|--profile)
            if [[ -n "$2" ]]; then
                PROFILE="$2"
                shift 2
            else
                echo "Error: --file requires an argument." >&2
                usage
            fi
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            usage
            ;;
        *)
            echo "Error: Unknown argument $1" >&2
            usage
            ;;
    esac
done

curlOptions="--connect-timeout 25"

adb </dev/null shell dumpsys user | grep -i "userinfo{"
privUser="$(adb </dev/null shell dumpsys user | grep -i userinfo{ | grep "isPrimary=true" | sed "s/:.*//g;s/.*{//g")"
workUser="$(adb </dev/null shell dumpsys user | grep -i userinfo{ | grep "Arbeitsprofil\|Work profile" | sed "s/:.*//g;s/.*{//g")"
test $PROFILE = "priv" && myUser=$privUser
test $PROFILE = "work" && myUser=$workUser

# Validate required parameters
if [[ -z "$myUser" ]]; then
    echo "Error: profile $PROFILE does not exist." >&2
    usage
fi

# Check if file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: File '$INPUT_FILE' does not exist." >&2
    exit 1
fi

# Main script logic
if [[ "$VERBOSE" == true ]]; then
    echo "Processing file: $INPUT_FILE"
fi

function testAppInstalled() {
	appID="$1"
	#test "$(adb </dev/null shell pm path --user $myUser "$appID" | grep -w "$appID" | tr -d [:cntrl:] | head -n1)" && {
	test "$(adb </dev/null shell pm list packages --user $myUser | grep -w "$appID" | tr -d [:cntrl:] | head -n1)" && {
		echo "$appID already installed."
		return 0
	}
	return 1
}

function installApp() {
	appID="$1"
	echo "Testing for $appID in F-Droid store..."
	foundGooglePlayStore=False
	foundFdroidStore=True
	appName="$(curl $curlOptions -s "https://f-droid.org/packages/$appID/" | grep "<title>" | tr -d [:cntrl:] | sed "s/ |.*//g;s/.*>//g")"
	test "$appName" = "404 Page Not Found" -o "$appName" = "" && {
		echo "$appID does not exist in F-Droid store."
		foundFdroidStore=False
		foundGooglePlayStore=True
		echo "Testing for $appID in Google Play store..."
		appName="$(curl $curlOptions -s "https://play.google.com/store/apps/details?id=$appID" | grep "main-title" | sed "s/.*<title id=\"main-title\">//g;s/<.*//g")"
		test -n "$appName" || {
			echo "$appID does not exist in Google Play store."
			foundGooglePlayStore=False
		}
	echo "$appName - F-Droid: $foundFdroidStore Google: $foundGooglePlayStore" >&1
       	}
	test $foundGooglePlayStore = "True" -o $foundFdroidStore = "True" && {
		#	test -n "$(adb </dev/null shell pm path "$appID")" || {
		echo -n "Installing $appName for user $myUser: "
		echo "<adb </dev/null shell am start -a android.intent.action.VIEW -d \"market://details?id=$appID\">"
       		adb </dev/null shell am start --user $myUser -a android.intent.action.VIEW -d "market://details?id=$appID"
		echo
		test $foundFdroidStore = "True" && echo -e "---> PLEASE select F-DROID store to install: \"$appName\"! <---\n"
		test $foundGooglePlayStore = "True" && echo -e "---> PLEASE select GOOGLE PLAY store to install: \"$appName\"! <---\n"
	       	#while [ -z $(adb </dev/null shell pm path "$appID" | grep -w "$appID" | tr -d [:cntrl:] | head -n1) ]; do sleep 3; done
		return 0
	}
	test $foundGooglePlayStore = "False" -a $foundFdroidStore = "False" && return 1
}

myAppID="org.fdroid.fdroid"
testAppInstalled $myAppID
test $? -eq 1 && {
	echo "Installing F-Droid store"
	curl -L https://f-droid.org/F-Droid.apk -o FDroid.apk
	adb install --user $myUser FDroid.apk
	adb shell monkey -p org.fdroid.fdroid 1
	echo -n "Please press any key to continue"; read ANSW; echo "Proceeding..."
}

#grep " $selectedProfile" $myFile | sed "s/ === /\t/g" $myFile | while IFS=$'\t' read myAppID appName storeFound userProfile
appListCount=0
while read lineOfFile
do
	#echo "Testing $lineOfFile"
	#myAppID="$(echo "$lineOfFile" | grep "= $selectedProfile" | sed "s/ .*//g")"
	myAppID="$lineOfFile"
	test -n "$myAppID" || continue
	appList+="$myAppID "
	((++appListCount))
#done
done < "$INPUT_FILE"

echo -e "AppList:\n$appList"
echo "Total number of apps: $appListCount"

appCount=0
for myAppID in $appList; do
	((++appCount))
	echo
	echo "$myAppID"
	echo "----------------------------------------------------"
	testAppInstalled $myAppID
	test $? -eq 1 && {
		echo "Installing app $appCount of $appListCount"
		installApp $myAppID </dev/null
		test $? -eq 0 && {
			echo -n "Please press any key to continue"; read ANSW; echo "Proceeding..."
		}
	}
	echo "----------------------------------------------------"
	echo
done

# Success message
echo "Script completed successfully."
