# on spark node
export S3_BASE="s3://llched-raw/open_lm_run2_data/export"
python open_lm/datapreprocess/make_2048.py --input-files /scratch/kjablonk/export/**/*.jsonl  --output-dir /scratch/kjablonk/preproc_data --num-workers 30 --num-consumers 8 --upload-to-s3
