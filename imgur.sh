#!/bin/bash

#=======================================#
# https://github.com/manabutameni/Imgur #
#=======================================#

gallery_url=$1
tempname=`basename $0`
tempfile=`mktemp -t ${tempname}.XXXXX` || exit 1

if [ -n "$gallery_url" ]  #  If command-line argument present,
then

  if [[ "$gallery_url" =~ "imgur.com" ]]
  then

    i=0
    curl -s $gallery_url > $tempfile

    album_title=`awk -F\" '/data-title/ { print $6 }' $tempfile | head -1`

    #Sanitize $album_title
    CLEAN=${album_title//_/}
    CLEAN=${CLEAN// /_}
    #The following was kept for possible future applications
    #CLEAN=${CLEAN//[^a-zA-Z0-9_]/}
    #CLEAN=`echo -n $CLEAN | tr A-Z a-z`
    if [[ "${album_title:(-1)}" == " " ]]
    then
      album_title=${CLEAN%?}
    else
      album_title=$CLEAN
    fi

    if [ ${#album_title} -eq 0 ]
    then
      album_title=${gallery_url:(-5)}
      if [[ "$album_title" =~ "#" ]]
      then
        album_title=${gallery_url:(-7)}
        album_title=${album_title:0:5}
      fi
    elif [[ "$album_title" =~ '/' ]]
    then
      album_title=`echo $album_title | sed 's/\//-/'`
    fi

    mkdir -p "$album_title"
    for image in $(awk -F\" '/data-src/ { print $10 } ' $tempfile | sed '/^$/d' | sed 's/s.jpg/.jpg/')
    do
      let i=$i+1;
      curl $image > "$album_title"/$i.jpg
    done

  else
    echo -e "\nImgur albums only\n"
    exit 1
  fi

  rm $tempfile

else
  echo -e "\nYou need to enter a parameter. Such as \
    \nhttps://www.imgur.com/a/qwerty\n"
  exit 1
fi
