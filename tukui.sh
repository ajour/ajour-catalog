#!/usr/bin/env bash
if [ $# -eq 0 ]
  then
    echo "Usage: tukui output_file"
    exit 1
fi

endpoint="https://www.tukui.org/api.php"
retail_endpoint="$endpoint?addons=all"
classic_endpoint="$endpoint?classic-addons=all"
elvui_endpoint="$endpoint?ui=elvui"
tukui_enspoint="$endpoint?ui=tukui"
tmp=$(mktemp -d -t ci-XXXXXXXXXX)
retail=$tmp/retail.json
classic=$tmp/classic.json
elvui=$tmp/elvui.json
tukui=$tmp/tukui.json
all=$tmp/all.json
curl -s $retail_endpoint | jq '[.[] | . + { "flavors": ["wow_retail"], "gameVersions": [{"flavor": "wow_retail", "gameVersion": (if (.patch == null) then "" else .patch end) }] }]' > $retail
curl -s $classic_endpoint | jq '[.[] | . + { "flavors": ["wow_classic"], "gameVersions": [{"flavor": "wow_classic", "gameVersion": (if (.patch == null) then "" else .patch end) }] }]' > $classic
curl -s $elvui_endpoint | jq '[. | . + { "flavors": ["wow_retail"], "gameVersions": [{"flavor": "wow_retail", "gameVersion": (if (.patch == null) then "" else .patch end) }] }]' > $elvui
curl -s $tukui_enspoint | jq '[. | . + { "flavors": ["wow_retail"], "gameVersions": [{"flavor": "wow_retail", "gameVersion": (if (.patch == null) then "" else .patch end) }] }]' > $tukui
jq -s add $retail $classic $elvui $tukui > $all
if [ $(jq 'length' $all) -eq "0" ]; then
  echo "Error: Found 0 tukui addons"
  exit 1;
fi
jq -c \
  'map(
  {
    "id": .id|tonumber,
    "websiteUrl": .web_url,
    "dateReleased": (if (.lastupdate == null) then "" else .lastupdate end),
    "name": .name,
    "summary": .small_desc|gsub("[\\r\\n\\t]"; ""),
    "numberOfDownloads": .downloads|tonumber,
    "categories": (if (.category == null) then [] else [.category] end),
    "gameVersions": .gameVersions,
    "source": "tukui"
  })' $all > $1
rm -rf tmp
