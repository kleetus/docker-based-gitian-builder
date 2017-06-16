#!/bin/bash


function get_input_from_user () {
  get_user_name
  get_path_to_gitian_sigs
}

user=
function get_user_name () {
  default=$(whoami)
  while [ 1 ]; do
    echo -n "Enter desired signing name (default: $default):"
    read user
    if [ -z "${user}" ]; then
      user=$default
    fi
    break
  done
}

path_to_gitian_sigs=

get_path_to_gitian_sigs () {
  if [ -z "${path_to_gitian_sigs}" ]; then
    while [ 1 ]; do
      echo -n "Path to gitian.sigs directory (default: ./gitian.sigs): "
      read path_to_gitian_sigs
      if [ -z "${path_to_gitian_sigs}" ]; then
        path_to_gitian_sigs=./gitian.sigs
      fi
      if [ ! -d "${path_to_gitian_sigs}" ]; then
        echo "path: ${path_to_gitian_sigs} does not exist."
      else
        break
      fi
    done
  fi
}

get_build_name () {
  echo ${1/-res.yml/}
}

for manifest in result/*.yml; do
  echo $manifest

  get_input_from_user

  basename=`basename $manifest`
  dir=$(get_build_name "${basename}")

  manifest_dir="${path_to_gitian_sigs}/${dir}/${user}"
  mkdir -p "${manifest_dir}"
  cp "${manifest}" "${manifest_dir}"
  manifest_file="${manifest_dir}/${basename}"
  echo "Attempting to sign manifest: ${manifest_file}"
  gpg -b "${manifest_file}"

done

echo "Done! Please create a merge request back to gitian.sigs upstream."
