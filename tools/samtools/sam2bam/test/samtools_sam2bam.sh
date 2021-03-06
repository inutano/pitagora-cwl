#!/bin/bash
# samtools_sam2bam.sh <path to data dir> <path to samtools_sam2bam.cwl> <path to samtools_sam2bam.yml.sample>
#
set -e

get_abs_path(){
  echo "$(cd $(dirname "${1}") && pwd -P)/$(basename "${1}")"
}

BASE_DIR="$(pwd -P)"
DATA_DIR_PATH="$(get_abs_path ${1})"
CWL_PATH="$(get_abs_path ${2})"
YAML_TMP_PATH="$(get_abs_path ${3})"

find "${DATA_DIR_PATH}" -name '*.sam' | while read fpath; do
  id="$(basename "${fpath}" | sed -e 's:.bam$::g')"
  result_dir="${BASE_DIR}/result/${id:0:6}/${id}"
  mkdir -p "${result_dir}" && cd "${result_dir}"

  yaml_path="${result_dir}/${id}.yml"
  cp "${YAML_TMP_PATH}" "${yaml_path}"

  sed -i.buk \
    -e "s:_INPUT_SAM_:${fpath}:" \
    "${yaml_path}"

  cwltool \
    --debug \
    --leave-container \
    --timestamps \
    --compute-checksum \
    --record-container-id \
    --cidfile-dir ${result_dir} \
    --outdir ${result_dir} \
    "${CWL_PATH}" \
    "${yaml_path}" \
    2> "${result_dir}/cwltool.log"

  cd "${BASE_DIR}"
done
