#!/usr/bin/env bash
if [ $# -eq 0 ]
  then
    echo "Usage: townlong_yak output_file"
    exit 1
fi

endpoint="https://hub.wowup.io/addons/author/foxlit"
addons=$(curl -s $endpoint | jq -c \
  '.addons | map(
  (if (.releases | length) > 0 then .releases | group_by(.game_type) else null end) as $releases |
    {
    id: .id,
    websiteUrl: .repository,
    dateReleased: (if (.releases | length) > 0 then .releases[0].published_at else null end),
    name: .repository_name,
    summary: .description | sub("<[^>]*>"; ""; "g"),
    numberOfDownloads: .total_download_count,
    categories: [],
    gameVersions: $releases | map({ flavor: ("wow_" + .[0].game_versions[0].game_type), gameVersion: .[0].game_versions[0].interface }),
    source: "townlong-yak"
  })')
if [ $(echo $addons | jq 'length') -eq "0" ]; then
  echo "Error: Found 0 townlong-yak addons"
  exit 1;
fi

echo $addons > $1
