source .env
SOURCE_FOLDER=~/Downloads
DESTINATION_FOLDER=~/IdeaProjects/$PROJECT-web/locales

declare -A MAP_LANG
MAP_LANG[Czech]="cs"
MAP_LANG[English]="en"
MAP_LANG[German]="de"
MAP_LANG[Hungarian]="hu"
MAP_LANG[Italian]="it"
MAP_LANG[Polish]="pl"
MAP_LANG[Serbian]="sr"
MAP_LANG[Russian]="ru"
MAP_LANG[French]="fr"

LOG_FILES=()

## shellcheck disable=SC2231
for file in $SOURCE_FOLDER/$PROJECT_*_*.json; do
    filename=$file:t:r
    # example - unica_ambassadorProgram_Czech.json
    ns=${filename%_*}
    ns=${ns##*_}

    cp_me=$file
    cp_to=$DESTINATION_FOLDER/${MAP_LANG[${filename##*_}]}/$ns.json

    LOG_FILES+=("[$(date +%Y-%m-%d-%H:%M:%S)] $cp_me -> $cp_to")
    cp -f "$cp_me" "$cp_to"
done

for LOG_FILE in "${LOG_FILES[@]}"; do
    echo "$LOG_FILE" >> debug.log
done
