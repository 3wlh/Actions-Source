#!/bin/bash
Download_URL="$1"
SDK_NAME="$2"

function get_state(){
	[[ $(curl -s -o /dev/null -w "%{http_code}" -X GET ${1}) -lt 400 ]] || exit
}

function get_text() {
	text="$(wget -qO- "${1}/sha256sums" | grep -- "${2}" | sed 's/*//g')"
	[[ -n "${text}" ]] && echo "${text}" || exit
}

function get_filename() {
	[[ -n "${2}" ]] && echo "${2}" || exit
}

function get_sha256sums() {
	[[ -n "${1}" ]] &&  echo "${1}" || exit
}

function get_download() {
	wget -qO "${2}" "${1}/${2}" # --show-progress
	actual_sha256="$(sha256sum "${2}" | awk '{print $1}')"
	[[ "${actual_sha256}" == "${3}" ]] || exit
}

function mian() {
	get_state "${Download_URL}"
	Text="$(get_text ${Download_URL} ${SDK_NAME})"
	[[ -z "${Text}" ]] && exit
	filename="$(get_filename ${Text})"
	[[ -z "${filename}" ]] && exit
	shasum="$(get_sha256sums ${Text})"
	[[ -z "${shasum}" ]] && exit
	get_download "${Download_URL}" "${filename}" "${shasum}"
	tar -I zstd -xf "${filename}" -C "." --strip=1
	rm -rf ${filename}
	echo "success"
}
mian

