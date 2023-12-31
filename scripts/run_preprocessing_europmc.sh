cd /scratch/kjablonk

aws s3 cp s3://llched-raw/training_v0/ft_results_train_clean.jsonl .
aws s3 cp s3://llched-raw/training_v0/ft_results_test_clean.jsonl .
aws s3 cp s3://llched-raw/training_v0/ft_results_valid_clean.jsonl .

python open_lm/datapreprocess/make_2048.py --input-files /scratch/kjablonk/ft_results_train_clean.jsonl --output-dir /scratch/kjablonk/preproc_data_europmc_ft_train --num-workers 30 --num-consumers 8 --upload-to-s3 --s3-base-dir s3://llched-raw/open_lm_run_processed_data/europmc_ft_results_train/
python open_lm/datapreprocess/make_2048.py --input-files /scratch/kjablonk/ft_results_test_clean.jsonl --output-dir /scratch/kjablonk/preproc_data_europmc_ft_test --num-workers 30 --num-consumers 8 --upload-to-s3 --s3-base-dir s3://llched-raw/open_lm_run_processed_data/europmc_ft_results_test/
python open_lm/datapreprocess/make_2048.py --input-files /scratch/kjablonk/ft_results_valid_clean.jsonl --output-dir /scratch/kjablonk/preproc_data_europmc_ft_valid --num-workers 30 --num-consumers 8 --upload-to-s3 --s3-base-dir s3://llched-raw/open_lm_run_processed_data/europmc_ft_results_valid/
