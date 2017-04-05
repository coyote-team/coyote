#!/bin/bash
# usage: 
# bin/conf_creator.sh .env.production

IFS="="
TIMESTAMP=$(date)

function populate {
    FILE=$1
    SOURCE="$FILE.example"
    echo "#Created ${TIMESTAMP}" > $FILE
    while read -r NAME VALUE
    do
        if [ $NAME = "SECRET_KEY_BASE" ]
        then
            SECRET="$(bin/rake secret)"
            echo "$NAME=$SECRET" >> $FILE
        else
            read -u 3 -p "$NAME? (default: $VALUE): " ANSWER
            if [ ${#ANSWER} -eq 0 ]
            then
                RESULT="$VALUE"
            else
                RESULT="$ANSWER"
            fi
            echo "$NAME=\"$RESULT\"" >> $FILE
        fi
    done < $SOURCE
} 3<&0

populate $1
