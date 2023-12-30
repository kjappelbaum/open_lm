from glob import glob 
import subprocess 
from pathlib import Path 

# new s3 base dir for every jsonl file 
S3_BASE_BASE_DIR = "s3://llched-raw/open_lm_run_processed_data/export/"


def run_preprocessing_export(file):
    folder = Path(file).parent
    stem = Path(file).stem
    s3_base_dir = f"{S3_BASE_BASE_DIR}/{folder}-{stem}/"
    subprocess.run(f"python open_lm/datapreprocess/make_2048.py --input-files {file} --output-dir /scratch/kjablonk/preproc_data --num-workers 30 --num-consumers 8 --s3-base-dir {s3_base_dir} --upload-to-s3", shell=True)



def run_preprocessing_export_all():
    files = glob("/scratch/kjablonk/export/**/*.jsonl", recursive=True)
    print(f"Found {len(files)} files")
    for file in files:
        print(file)
        run_preprocessing_export(file)

if __name__ == "__main__":
    run_preprocessing_export_all()