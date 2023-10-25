source ".env"

_jq() {
    echo ${2} | base64 --decode | jq -r ${1}
}

# Usage:
# poeditor_request ENDPOINT [-d 'key1=value1' -d 'key2=value2' ...]
po_api_get() {
    local endpoint="$1"
    shift

    # Ensure POEDITOR_TOKEN is set
    if [ -z "$POEDITOR_TOKEN" ]; then
        echo "Error: POEDITOR_TOKEN is not set!"
        return 1
    fi

    curl --silent -X POST "https://api.poeditor.com/v2/${endpoint}" -d "api_token=$POEDITOR_TOKEN" "$@"
}
# Example usage:
# poeditor_request "/projects/list" -d 'key1=value1' -d 'key2=value2'

po_api_get "projects/list" > "projects.log.json" || exit 1
