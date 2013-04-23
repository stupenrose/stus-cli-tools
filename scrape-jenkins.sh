#!/bin/bash
read -p "Jenkins URL:" BASE_URL
read -p "Username:" USERNAME
read -s -p "Password:" PASSWORD

TIMESTAMP=`date`
HISTORY_DIR=~/var/jenkins-history
GLOBAL_CONFIG="$HISTORY_DIR/config.json"

wget --auth-no-challenge --user=$USERNAME --password=$PASSWORD $BASE_URL/api/json -O $GLOBAL_CONFIG

if [ $? = 0 ]
then
  JOB_URLS=` grep -o '"jobs".*],' $GLOBAL_CONFIG| sed 's|{"name"|\n{"name"|g' | sed 's|,|\n,|g'| grep -o '"http://.*"' | sed 's|"||g'`

for JOB in $JOB_URLS
do
    NAME=`echo $JOB | sed "s|$BASE_URL/job||g" |sed 's|/||g'`
    echo "$NAME is $JOB"
    wget --auth-no-challenge --user=$USERNAME --password=$PASSWORD $JOB/config.xml -O $HISTORY_DIR/$NAME.config.xml
done

else
   echo "ERROR"
fi

cd $HISTORY_DIR && git add --all && git commit -m "Configuration fetched at $TIMESTAMP"

