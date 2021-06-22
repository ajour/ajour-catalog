#!/usr/bin/env bash

if [ $# -eq 0 ]
  then
    echo "Usage: curse output_file"
    exit 1
fi

index=0
page_size=50
number_of_addons=$page_size
endpoint="https://addons-ecs.forgesvc.net/api/v2/addon/search?gameId=1&pageSize=${page_size}"
tmp=$(mktemp -d -t ci-XXXXXXXXXX)
new=$tmp/new.json
running=$tmp/running.json
all=$tmp/addons.json
touch $running
while [ $number_of_addons == $page_size ]
do
  curse_endpoint="$endpoint&index=${index}"
  data=$(curl -s $curse_endpoint)
  number_of_addons=$(echo $data | jq '. | length')
  echo $data | jq \
    'map(
      [((if (.latestFiles | length) > 0 then .latestFiles else .gameVersionLatestFiles end) | .[] | select(.gameVersionFlavor == "wow_classic" or .gameVersionFlavor == "wow_retail" or .gameVersionFlavor == "wow_burning_crusade"))] as $files |
      {
      id: .id,
      websiteUrl: .websiteUrl,
      dateReleased: (if (.dateReleased == null) then "" else .dateReleased end),
      name: .name,
      summary: .summary,
      numberOfDownloads: .downloadCount,
      categories: [.categories[] | .name],
      gameVersions: $files |
        group_by(.gameVersionFlavor) |
        map(
          group_by(.fileType) |
          map(sort_by(.projectFileId) | reverse) | flatten
        ) |
          map({
            flavor: .[0].gameVersionFlavor,
            gameVersion: (if (.[0].gameVersion|type == "string") then .[0].gameVersion else (if (.[0].gameVersion|length > 0) then .[0].gameVersion[0] else "-" end) end)
          }),
      "source": "curse" })' > $new
  jq -s -c add $running $new > $all
  cat $all > $running
  index=$(( $index + $page_size ))
done

if [ $(jq 'length' $all) -eq "0" ]; then
  echo "Error: Found 0 curse addons"
  exit 1;
fi

cat $all > $1
rm -rf $tmp
