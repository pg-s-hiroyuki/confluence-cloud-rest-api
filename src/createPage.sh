#!/bin/bash
pwd
cd $(dirname $0)
. ../lib/config.sh
set -e
exit 0

SHELL_NAME=$(basename ${0})


function usage {
  cat <<- __EOF__
		${SHELL_NAME} is for creating new page to attlasian cloud.

		parameter:
		  [必須] -s space_key 作成するページスペースキーを指定します
		  [必須] -p parent_id 作成するページ親のページIDを指定します
		  [必須] -t title 作成するページのタイトルを指定します
		  [任意] -b body 作成するページの内容を指定します
		  [任意] -v postするjsonファイルを削除しないで残します

		usage:
		  ${SHELL_NAME} -s ENJOY -t "new title" -p 62783547 -b "content"
__EOF__
  exit 1
}

opt_s=
opt_p=
opt_t=
opt_b=""
opt_v=0

while getopts s:p:t:b:v OPT
do
  case ${OPT} in
    "s") opt_s=${OPTARG} ;;
    "p") opt_p=${OPTARG} ;;
    "t") opt_t=${OPTARG} ;;
    "b") opt_b=${OPTARG} ;;
		"v") opt_v=1 ;;
     * ) usage; exit 1 ;; 
  esac
done

[ -z "${opt_s}" ] && usage;
[ -z "${opt_p}" ] && usage;
[ -z "${opt_t}" ] && usage;

shift `expr $OPTIND - 1`

function creatPage {
  local _json_file=$1
  curl --request POST \
  --user ${USER}:${PASS} \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data "@${_json_file}" \
  --url "https://${HOST}/wiki/rest/api/content"
}

function createJson {
  local _json_file=$1
  cat templete/newPage.json | \
	  sed -e "s/#space_key#/${opt_s}/g" | \
		sed -e "s/#parent_id#/${opt_p}/g" | \
		sed -e "s/#title#/${opt_t}/g" | \
		sed -e "s/#content#/${opt_b}/g" > $1 
}

log "=== Start ==="
log "=== create json file ==="
TMP_JSON_FILE="`date +'%Y%m%d_%H%M%S'`.json"
createJson ${TMP_JSON_FILE}
log "=== call post ==="
creatPage ${TMP_JSON_FILE}

# delete tmp json file
if [ "${opt_v}" == 0 ]; then
  rm -f ${TMP_JSON_FILE}
fi
log "=== End ==="