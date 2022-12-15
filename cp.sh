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

curl -X POST https://api.poeditor.com/v2/projects/list \
  -d api_token="$POEDITOR_TOKEN" \
  >projects.log.json

sample=$(cat projects.log.json | jq '.result.projects')
for row in $(echo "${sample}" | jq -r '.[] | @base64'); do
  _jq() {
    echo ${row} | base64 --decode | jq -r ${1}
  }
  project_name=$(_jq '.name')
  project_id=$(_jq '.id')
  project_languages=$(curl -X POST https://api.poeditor.com/v2/languages/list -d api_token=$POEDITOR_TOKEN -d id=$project_id | jq -r '.result.languages')

  for lang in $(echo "${project_languages}" | jq -r '.[] | @base64'); do
    _jq() {
      echo ${lang} | base64 --decode | jq -r ${1}
    }
    language_code=$(_jq '.code')

    echo "Downloading $project_name for $lang"
    curl -X POST https://api.poeditor.com/v2/projects/export \
      -d api_token="$POEDITOR_TOKEN" \
      -d id="$project_id" \
      -d language="$language_code" \
      -d type="key_value_json" \
      | jq -r '.result.url' \
      > data/$project_name-$language_code.json

  done

done

#for file in data/*.json; do
#  echo file
#done

#
#curl -X POST https://api.poeditor.com/v2/languages/list \
#          -d api_token="$POEDITOR_TOKEN" \
#          -d id="$PROJECT_ID" \
#          > languages.log.json
#
## shellcheck disable=SC2231
#for file in $SOURCE_FOLDER/$PROJECT_*_*.json; do
#    filename=$file:t:r
#
#    ns=${filename%_*}
#    ns=${ns##*_}
#
#    cp_me=$file
#    cp_to=$DESTINATION_FOLDER/${MAP_LANG[${filename##*_}]}/$ns.json
#
#    LOG_FILES+=("[$(date +%Y-%m-%d-%H:%M:%S)] $cp_me -> $cp_to")
#    cp -f "$cp_me" "$cp_to"
#done
#
#for LOG_FILE in "${LOG_FILES[@]}"; do
#    echo "$LOG_FILE" >> debug.log
#done
