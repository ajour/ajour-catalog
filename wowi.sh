#!/usr/bin/env bash
if [ $# -eq 0 ]
then
  echo "Usage: wowi output_file"
  exit 1
fi

endpoint="https://api.mmoui.com/v4/game/WOW/filelist.json"
curl -s $endpoint | jq -c \
  'map(
  [
  {id: 160, name: "Classic"},
    {id: 19, name: "Action Bar Mods"},
    {id: 94, name: "Auction House & Vendors"},
    {id: 20, name: "Bags, Bank, Inventory"},
    {id: 22, name: "Buff, Debuff, Spell"},
    {id: 112, name: "Casting Bars, Cooldowns"},
    {id: 18, name: "Character Advancement"},
    {id: 55, name: "Chat Mods"},
    {id: 39, name: "Class & Role Specific"},
    {id: 151, name: "Death Knight"},
    {id: 157, name: "Demon Hunter"},
    {id: 56, name: "Druid"},
    {id: 57, name: "Hunter"},
    {id: 58, name: "Mage"},
    {id: 152, name: "Monk"},
    {id: 59, name: "Paladin"},
    {id: 60, name: "Priest"},
    {id: 61, name: "Rogue"},
    {id: 62, name: "Shaman"},
    {id: 63, name: "Warlock"},
    {id: 64, name: "Warrior"},
    {id: 149, name: "DPS"},
    {id: 150, name: "Healers"},
    {id: 151, name: "Tanks"},
    {id: 25, name: "Combat Mods"},
    {id: 26, name: "Data Mods"},
    {id: 155, name: "Garrisons"},
    {id: 17, name: "Graphic UI Mods"},
    {id: 95, name: "Group, Guild & Friends"},
    {id: 109, name: "Info, Plug-in Bars"},
    {id: 108, name: "Data Broker"},
    {id: 85, name: "FuBar"},
    {id: 99, name: "Titan Panel"},
    {id: 111, name: "Other"},
    {id: 24, name: "Map, Coords, Compasses"},
    {id: 97, name: "Mail"},
    {id: 100, name: "Mini Games, ROFL"},
    {id: 146, name: "Mounts & Pets"},
    {id: 96, name: "PvP, Arena, BattleGrounds"},
    {id: 45, name: "Raid Mods"},
    {id: 114, name: "RolePlay, Music Mods"},
    {id: 113, name: "Suites"},
    {id: 40, name: "TradeSkill Mods"},
    {id: 98, name: "ToolTip"},
    {id: 147, name: "UI Media"},
    {id: 21, name: "Unit Mods"},
    {id: 27, name: "Miscellaneous"},
    {id: 154, name: "Utility Mods"},
    {id: 53 , name: "Libraries"},
    {id: 35, name: "Developer Utilities"},
    {id: 88, name: "WoW Tools & Utilities"}
    ] as $categories |
      .categoryId as $categoryId |
      (if (.categoryId == 160) then "wow_classic" else "wow_retail" end) as $flavor |
      (if (.gameVersions | length) > 0 then .gameVersions[0] else "0" end) as $gameVersion |
      {
        id: .id,
        websiteUrl: .fileInfoUri,
        dateReleased: .lastUpdate | tostring,
        name: .title,
        summary: "",
        numberOfDownloads: .downloads,
        categories: [($categories[] | select(.id == $categoryId)).name],
        gameVersions: [{ flavor: $flavor, gameVersion: $gameVersion }],
        source: "wowi"
      }
    )' > $1
