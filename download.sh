for file in data/*.json; do
  #example - unica:domain-language.json
  download_file_name=$file:t:r

  language=${download_file_name##*-}
  language=${language%.json}
  ns=${download_file_name%-*}
  ns=${ns##*:}

  target_dir=data/downloaded/$language

  [[ -d $target_dir ]] || mkdir $target_dir

  curl $(cat "$file") > "$target_dir/$ns.json"
done