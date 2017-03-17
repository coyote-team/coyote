#!/bin/bash
# usage: 
# bin/conf_creator.sh .env.production

exec 3<> /dev/stdin
IFS="="
TIMESTAMP=$(date)

function populate {
    FILE=$1
    SOURCE="$FILE.example"
    echo "#Created ${TIMESTAMP}" > $FILE
    while read -r NAME VALUE
    do
        read -u 3 -p "$NAME? (default: $VALUE): " ANSWER
        if [ ${#ANSWER} -eq 0 ]
        then
            RESULT="$VALUE"
        else
            RESULT="$ANSWER"
        fi
        echo "$NAME=$RESULT" >> $FILE
    done < $SOURCE
}

populate .env
