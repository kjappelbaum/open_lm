# on spark node
export S3_BASE="s3://llched-raw/open_lm_run"
python open_lm/datapreprocess/make_2048.py --input-files path_to_raw_data/*.jsonl --output-dir preproc_data --num-workers 32 --num-consumers 8 --upload_to_s3
