# VCF ➜ MAF Batch Pipeline (vcf2maf + VEP 113, SLURM)

使用 [MSKCC vcf2maf](https://github.com/mskcc/vcf2maf) 與 [VEP](https://github.com/Ensembl/ensembl-vep)（cache v113）將單樣本 VCF 批次轉為 MAF

---

## ✅ 需求
- SLURM 環境（可使用 `sbatch`）
- Conda 虛擬環境（已安裝 `vep_113`）
- MSKCC `vcf2maf.pl` 腳本
- VEP cache v113
- GRCh38 參考基因組（FASTA + index）

---

## 📂 專案結構
vcf2maf-pipeline/
├── README.md
├── config.env # 所有路徑與參數設定
└── run_vcf2maf.sh

---

## ⚙️ 設定檔 `config.env`
將所有可調整的路徑與參數集中在 `scripts/config.env`：

| 變數名稱 | 說明 | 範例 |
|----------|------|------|
| `VCF_PATH` | 單樣本 VCF 目錄（支援 `.vcf` / `.vcf.gz`） | `/staging/biology/user/single_vcf` |
| `OUTPUT_DIR` | MAF 輸出目錄 | `../output_maf` |
| `LOG_DIR` | 日誌輸出目錄 | `../logs` |
| `REFERENCE_FASTA` | GRCh38 FASTA 路徑 | `/path/to/Homo_sapiens_assembly38.fasta` |
| `VEP_DATA` | VEP cache 資料夾 | `/path/to/vep/` |
| `VEP_PATH` | VEP 執行檔路徑 | `/path/to/envs/vep_113/bin` |
| `VCF2MAF_PL` | `vcf2maf.pl` 路徑 | `/path/to/mskcc-vcf2maf/vcf2maf.pl` |
| `NCBI_BUILD` | 基因組版本 | `GRCh38` |
| `CACHE_VERSION` | VEP cache 版本 | `113` |
| `NORMAL_SUFFIX` | Normal 樣本 ID 後綴 | `N` |
| `TUMOR_SUFFIX` | Tumor 樣本 ID 後綴 | `T` |
| `FILE_GLOB` | 檔案搜尋 pattern | `*.{vcf,vcf.gz}` |

> **命名假設**：檔名格式為 `<SampleID>_xxxx.vcf`，腳本會自動擷取 `<SampleID>` 並加上 `NORMAL_SUFFIX` / `TUMOR_SUFFIX`。

---

## 🚀 使用方法
```bash
# 進入專案資料夾
cd vcf2maf-pipeline/scripts

# 編輯 config.env 設定路徑與參數
nano config.env

# 提交 SLURM 作業
sbatch run_vcf2maf.sh

