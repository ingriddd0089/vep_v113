#!/usr/bin/env bash

set -euo pipefail

# ==== Conda 環境 ====
source ~/miniconda3/etc/profile.d/conda.sh
conda activate vep_113

# ==== 載入 config.env ====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.env"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "[ERROR] config.env not found at ${CONFIG_FILE}" >&2
  exit 1
fi
# shellcheck disable=SC1090
source "${CONFIG_FILE}"

# ==== 基礎變數檢查 ====
require_file() { [[ -f "$1" ]] || { echo "[ERROR] File not found: $1" >&2; exit 1; }; }
require_dir()  { [[ -d "$1" ]] || { echo "[ERROR] Dir not found:  $1" >&2; exit 1; }; }

require_dir "${VCF_PATH}"
require_file "${REFERENCE_FASTA}"
require_dir "${VEP_DATA}"
require_dir "${VEP_PATH}"
require_file "${VCF2MAF_PL}"

# ==== 準備輸出目錄 ====
mkdir -p "${OUTPUT_DIR}" "${LOG_DIR}"

echo "==> Start VCF -> MAF (vcf2maf + VEP ${CACHE_VERSION})"
echo "VCF dir : ${VCF_PATH}"
echo "MAF out : ${OUTPUT_DIR}"
echo "Logs    : ${LOG_DIR}"
echo "Build   : ${NCBI_BUILD}, VEP cache: ${CACHE_VERSION}"

shopt -s nullglob
found_any=false

# 支援 .vcf 與 .vcf.gz
for vcf in "${VCF_PATH}"/${FILE_GLOB}; do
  found_any=true

  fname="$(basename "${vcf}")"
  # 取樣本 ID：以 '_' 為界，取第一段
  sample="$(echo "${fname}" | cut -d'_' -f1)"

  normal_id="${sample}${NORMAL_SUFFIX}"
  tumor_id="${sample}${TUMOR_SUFFIX}"

  echo "----"
  echo "Processing sample: ${sample}"
  echo "  normal-id: ${normal_id}"
  echo "  tumor-id : ${tumor_id}"

  # vcf2maf 可直接吃 .vcf.gz；若遇到不支援再改為 zcat 管線
  perl "${VCF2MAF_PL}" \
    --input-vcf "${vcf}" \
    --output-maf "${OUTPUT_DIR}/${sample}_2callers.maf" \
    --normal-id "${normal_id}" \
    --tumor-id  "${tumor_id}" \
    --ref-fasta "${REFERENCE_FASTA}" \
    --vep-data  "${VEP_DATA}" \
    --vep-path  "${VEP_PATH}" \
    --ncbi-build "${NCBI_BUILD}" \
    --cache-version "${CACHE_VERSION}" \
    --vep-overwrite \
    > "${LOG_DIR}/${sample}_vcf2maf.log" 2>&1

  echo "Finished: ${sample}"
done

if [[ "${found_any}" = false ]]; then
  echo "[WARN] No VCF files matched '${VCF_PATH}/${FILE_GLOB}'"
fi

echo "==> All done."
