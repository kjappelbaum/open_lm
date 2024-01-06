import json
import boto3
import fire 
from pathlib import Path 

def upload_to_s3(manifest_file):
    with open(manifest_file, 'r') as file:
        for line in file:
            data = json.loads(line)
            if data['num_sequences'] > 0:
                # Upload the path to S3
                s3 = boto3.client('s3')
                parts = Path(data['manifest_path']).parts
                worker = parts[-2]
                shard = parts[-1]
                s3.upload_file(data['manifest_path'], 'llched-raw', 'open_lm_run_processed_data/nougat_process/' +  worker + '/' + shard) 

if __name__ == '__main__':
    fire.Fire(upload_to_s3)