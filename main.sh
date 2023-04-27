source .env

# Downloads all the files from POEditor, named with a next structure: $project_name:$namespace
# Places all the downloaded files into next-translate ready structure data/downloaded/$project/$language_code/$namespace.json

_jq() {
    echo ${2} | base64 --decode | jq -r ${1}
}

download_folder_path=data/downloaded
[[ ! -d $download_folder_path ]] || rm -rf $download_folder_path && mkdir $download_folder_path

curl --silent -X POST https://api.poeditor.com/v2/projects/list \
  -d api_token="$POEDITOR_TOKEN" \
  >projects.log.json

projects=$(cat projects.log.json | jq '.result.projects')

[[ -d data/downloaded ]] || mkdir data/downloaded

for row in $(echo "${projects}" | jq -r '.[] | @base64'); do

  project_full_name=$(_jq '.name' $row)

  # project_full_name example: "unica:ambassadorProgram"
  project_name=${project_full_name%:*}
  project_namespace=${project_full_name##*:}

  project_id=$(_jq '.id' $row)

  echo "PROJECT #$project_id ($project_full_name)"

  download_path_project=$download_folder_path/$project_name

  [[ -d $download_path_project ]] || mkdir $download_path_project

  project_languages=$(curl --silent -X POST https://api.poeditor.com/v2/languages/list -d api_token=$POEDITOR_TOKEN -d id=$project_id | jq -r '.result.languages')

  for lang in $(echo "${project_languages}" | jq -r '.[] | @base64'); do

    language_code=$(_jq '.code' $lang)

    download_path_lang=$download_path_project/$language_code
    file=$download_path_lang/$project_namespace.json

    [[ -d $download_path_lang ]] || mkdir $download_path_lang

    url=$(curl --silent -X POST https://api.poeditor.com/v2/projects/export -d api_token=$POEDITOR_TOKEN -d id=$project_id -d language=$language_code -d type="key_value_json" -s | jq -r '.result.url')
    curl $url -o $file -s

    echo "downloaded: $file"

  done

  echo '-------------------------------------------'

done