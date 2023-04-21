#!/bin/bash

CONFIG='/root/.cdnvideo'
JSON_EXPORTER_CONF='/home/docker/cdnvideo/volumes/json-exporter/config.yml'
POST_CMD='/usr/bin/docker compose -f /home/docker/cdnvideo/docker-compose.yml restart json-exporter'

LOGIN=`yq .login $CONFIG`
PASSWORD=`yq .password $CONFIG`

OUT=`curl -s "https://api.cdnvideo.ru/app/oauth/v1/token/" --data-urlencode "username=$LOGIN" --data-urlencode "password=$PASSWORD"`
# Output example
#OUT='{"status": 200, "person_id": 1678, "token": "cdn1_NM098OI31MKS72EPZW724TLZRTTXBT", "lifetime": 21599000}'

if [ $(echo $OUT | yq .status) == 200 ]; then
    TOKEN=$(echo $OUT | yq .token)

    yq -i ".modules.[].headers.CDN-AUTH-TOKEN=\"$TOKEN\"" $JSON_EXPORTER_CONF
    $POST_CMD
else
    echo "Failed with $OUT"
fi
