#!/bin/bash

function convert_version_to_major_minor_x() {
    local version="$1"
    if [[ "$version" =~ ^v([0-9]+)\.([0-9]+)\. ]]; then
        echo "v${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.x"
    else
        echo "Invalid version format: $version"
    fi
}

function get_branch() {
  local version_file="version"
  if [[ ! -f $version_file ]]; then
    echo "Error: Version file '$version_file' not found."
    exit 1
  fi

  local version=$(cat "$version_file")
  local branch=$(convert_version_to_major_minor_x "$version")

  # Fetch versions.json from the appropriate branch; fall back to the master branch if the request fails.
  curl --fail -s -o /dev/null https://raw.githubusercontent.com/longhorn/dep-versions/${branch}/versions.json
  if [ $? -eq 0 ]; then
    echo "${branch}"
  else
    echo "master"
  fi
}
