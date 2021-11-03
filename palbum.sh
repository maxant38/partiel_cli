#!/bin/bash
#
# palbum.sh: - create a photo album from a set of photos taken by a digital camera or a smartphone.
#
# Maxence Caille <maxence.caille@emse.fr>
# 2021-11-03

function missingArgument() {
	prog=$"palbum"

	echo "You have to write two arguments."
	echo "$prog: Create a photo album from a set of photos." 
	echo "$prog <INPUT-DIRECTORY> <OUTPUT-DIRECTORY>"
}

function error() {
	echo "(Error)\"$2\": $1" >&2
	exit 1
}

function checkInput(){

	pictures=$(find "$inputDir" -type f -name "*.jpg")
	if [ -z "$pictures" ];
	then
      		echo "Warning : There isn't any picture in $inputDir."
		exit 1
	else
      		echo "There are pictures in $inputDir."
	fi
}

function checkOutput() {
	if [[ -d "$outputDir" ]];
	then
		echo "$outputDir already exists."
		while true; do
			read -p "Do you want to complete the current album? (y/n)" yn
    			case $yn in
       				[Yy]* ) break;;
        			[Nn]* ) exit 1;;
        			* ) echo "Please answer yes or no.";;
    			esac
		done

	else
		echo "creating directory"
		mkdir "$outputDir"
	fi
}
function organizePictures(){
	find $inputDir -type f -name "*.jpg">listPictures
	while read line
	do
		date=$(identify -verbose $line |grep date:modify|cut -b 18-27)
		year=${date:0:4}
		echo "date : $date  year: $year"
		if [ ! -d "$outputDir/%year" ]
		then
			mkdir "$outputDir/$year"
			mkdir "$outputDir/$year/$date"
		fi

		if [ ! -d "$outputDir/$year/$date" ]
		then
			mkdir "$outputDir/$year/$date"
		fi
		cp line "$outputDir/$year/$date"
	done<listPictures
	rm listPictures
}


if [ $# -lt 2 ];
then
	missingArgument
	exit 1
fi


if [ ! -d "$1" ];
then
	error "is not a directory" $1
	exit 1
fi

inputDir=$1
outputDir=$2

checkInput
checkOutput

organizePictures




echo "end"



