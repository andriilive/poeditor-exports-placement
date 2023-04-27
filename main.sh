source .env

# Downloads all the files from POEditor, named with a next structure: $project_name:$namespace
# Places all the downloaded files into next-translate ready structure data/downloaded/$project/$language_code/$namespace.json

curl -X POST https://api.poeditor.com/v2/projects/list \
  -d api_token="$POEDITOR_TOKEN" \
  >projects.log.json

[[ -d data/downloaded ]] || mkdir data/downloaded

sample=$(cat projects.log.json | jq '.result.projects')

for row in $(echo "${sample}" | jq -r '.[] | @base64'); do
  _jq() {
    echo ${row} | base64 --decode | jq -r ${1}
  }

  project_full_name=$(_jq '.name')

  # project_full_name example: "unica:ambassadorProgram"
  project_name=${project_full_name%:*}
  project_namespace=${project_full_name##*:}

  project_id=$(_jq '.id')

  download_path_project=data/downloaded/$project_name

  [[ -d $download_path_project ]] || mkdir $download_path_project

  project_languages=$(curl -X POST https://api.poeditor.com/v2/languages/list -d api_token=$POEDITOR_TOKEN -d id=$project_id | jq -r '.result.languages')

  for lang in $(echo "${project_languages}" | jq -r '.[] | @base64'); do
    _jq() {
      echo ${lang} | base64 --decode | jq -r ${1}
    }
    language_code=$(_jq '.code')

    download_path_lang=$download_path_project/$language_code

    [[ -d $download_path_lang ]] || mkdir $download_path_lang

    url=$(curl -X POST https://api.poeditor.com/v2/projects/export -d api_token=$POEDITOR_TOKEN -d id=$project_id -d language=$language_code -d type="key_value_json" -s | jq -r '.result.url')
    curl $url -o $download_path_lang/$project_namespace.json -s
  done

done