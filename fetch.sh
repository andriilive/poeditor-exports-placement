source .env
curl -X POST https://api.poeditor.com/v2/projects/list \
  -d api_token="$POEDITOR_TOKEN" \
  >projects.log.json

[[ -d data/downloaded ]] || mkdir data/downloaded

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
    [[ -d data/downloaded/$language_code ]] || mkdir data/downloaded/$language_code

    url=$(curl -X POST https://api.poeditor.com/v2/projects/export -d api_token=$POEDITOR_TOKEN -d id=$project_id -d language=$language_code -d type="key_value_json" -s | jq -r '.result.url')
    curl $url -o data/downloaded/$language_code/${project_name##*:}.json -s
  done

done