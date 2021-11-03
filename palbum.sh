#!/bin/bash
#
# palbum.sh: - create a photo album from a set of photos taken by a digital camera or a smartphone.
#
# Maxence Caille <maxence.caille@emse.fr>
# 2021-11-03
#set -x

function missingArgument() { #on indique ici la synthaxe à l'utilisateur pour utiliser notre programme
	prog=$"palbum"

	echo "You have to write two arguments."
	echo "$prog: Create a photo album from a set of photos." 
	echo "$prog <INPUT-DIRECTORY> <OUTPUT-DIRECTORY>"
}

function error() {			#fonction pour notifier l'utilisateur d une erreur
	echo "(Error)\"$2\": $1" >&2
	exit 1
}

function checkInput(){			#fonction qui permet de vérifier que l input directory contienne bien des images

	pictures=$(find "$inputDir" -type f -name "*.jpg")
	if [ -z "$pictures" ];
	then
      		echo "Warning : There isn't any picture in $inputDir."
		exit 1
	else
      		echo "There are pictures in $inputDir."
	fi
}

function checkOutput() {		#fonction qui permet de gérer le cas où l output directory existe déjà
	if [[ -d "$outputDir" ]];
	then
		echo "$outputDir already exists."
		while true; do
			read -p "Do you want to complete the current album? (y/n)" yn      #on demande à l utilisateur ce qu il souhaite faire 
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

function organizePictures(){					#cette fonction permet de réaliser l'aborescence des fichiers ainsi que de copier l ensemble des photos dans le nouveau dossier 
	find $inputDir -type f -name "*.jpg">listPictures	#les fichiers jpg (les photos) sont stockés dans le fichier listPictures qui sera supprimé à la fin du programme
	while read line;
		do

		identify -regard-warnings -verbose $line > /dev/null 2>&1  #on teste ici si l image n est pas corrompue 
		resultTest=$?
		if [ $resultTest -lt 1 ]				   # si l image n est pas corrompue le resultTest renvoie 0 (ce qui est inférieur à 1) et donc on peut le placer dans le nouveau dossier
 		then
			date=$(identify -verbose $line |grep date:modify|cut -b 18-27)      #on formate ici la date de la photo pour pouvoir la placer/ou créer un dossier pour la ranger dedans
			year=${date:0:4}
			if [ ! -d "$outputDir/$year" ]						#si le dossier n existe pas, on l'ajoute
			then
				mkdir "$outputDir/$year"
			fi

			if [ ! -d "$outputDir/$year/$date" ]
			then
				mkdir "$outputDir/$year/$date"
				mkdir "$outputDir/$year/$date/.thumbs"			# je cree les directory selon la nomenvlature exigee
			fi
			cp $line "$outputDir/$year/$date"				#on copie la photo dans le dosser adéquat
			createThumbnail $line $outputDir/$year/$date			#je cree mon thumbnail en appelant la fonction adequate
		fi
	done<listPictures
	rm -f listPictures
}

function createThumbnail(){
	picture=$1		#on récupère le nom de la picture
	pictureName=$(echo "$picture" | cut -f 1 -d '.')
	thumbnailName="${pictureName}-thumb.jpg"	#on ecrit le nom du thumbnail selon l exigence de l enonce
	convert -define jpeg:size=500x180 $picture -thumbnail '150x150>' $thumbnailName    #je cree mon thumbnail, j utilise l option define pour ne ne pas faire déborder la mémoire de l ordinateur avec une image énorme quand elle n est pas nécessaire. Et j ajoute aussi l argument 150x60> pour respecter l enonce ( les 150 pixels de haut en gardant les proportions) 
	mv $thumbnailName "$2/.thumbs"			#on deplace dans le bon repertoire (outputDir)
}


if [ $# -lt 2 ]; 		#on vérifie qu il y ait bien deux arguments qui sont rentrés par l utilisateur
then
	missingArgument
	exit 1
fi


if [ ! -d "$1" ];		#on vérifie que le directory rentré par l utilisateur en est bien un
then
	error "is not a directory" $1
	exit 1
fi

inputDir=$1
outputDir=$2

checkInput	#on vérifie les input
checkOutput

organizePictures    #on crée l'arborescence, copie  les photos dans le nouveau directory




echo "end"



