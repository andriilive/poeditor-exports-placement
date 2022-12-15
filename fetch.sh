source .env
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