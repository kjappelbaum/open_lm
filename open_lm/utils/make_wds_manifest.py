import argparse
import re
import simdjson
import sys
import subprocess
import multiprocessing as mp
from pathlib import Path
from cloudpathlib import CloudPath, S3Path
from tqdm import tqdm
from glob import glob
from pathlib import Path 
import tempfile
import os 

def path_or_cloudpath(s):
    if re.match(r"^\w+://", s):
        return CloudPath(s)
    return Path(s)


def parse_args(args):
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--data-dir",
        type=path_or_cloudpath,
        required=True,
        help="Directory containing a dataset in webdataset format.",
    )
    parser.add_argument(
        "--manifest-filename",
        type=str,
        default="manifest.jsonl",
        help="Filename for the manifest that will be stored in the webdataset directory.",
    )
    parser.add_argument("--num-workers", type=int, default=2, help="Number of workers.")
    args = parser.parse_args(args)
    return args


def count_file(file):
    try:
        count = int(subprocess.check_output(f"tar tf {file} | wc -l", shell=True))
    except subprocess.CalledProcessError:
        count = 0
    return count

        
def count_samples(shard_path):
    if isinstance(shard_path, CloudPath):
        print('Downloading ', shard_path)
        with tempfile.TemporaryDirectory(dir=os.getcwd()) as tempdir:
            tmpfile = Path(tempdir) / 'archive.tar'
            shard_path.download_to(tmpfile)
            return count_file(tmpfile)
    else:
        return count_file(shard_path)

def worker_fn(input_data):
    shard_path, data_dir = input_data
    return {
            "manifest_path": str(shard_path),
            "shard": shard_path.parts[-2],
            "num_sequences": count_samples(shard_path),
        }
    


def main(args):
    args = parse_args(args)
    
    if isinstance(args.data_dir, S3Path):
        bucket_path = args.data_dir
        shards = list(bucket_path.glob('**/*.tar'))
    else:
        shards = sorted([Path(x) for x in glob(str(args.data_dir / "**" / "*.tar")) if Path(x).name.endswith(".tar")])
    input_data = [(shard, args.data_dir) for shard in shards]

    print(f"Shards to process: {len(shards)}")
    print("Creating pool.")
    with mp.Pool(args.num_workers) as pool:
        data = []
        for worker_data in tqdm(pool.imap_unordered(worker_fn, input_data)):
            data.append(worker_data)

    total_sequences = sum([item["num_sequences"] for item in data])
    print(f"Total sequences: {total_sequences}")
    manifest_path =  args.manifest_filename
    with open(manifest_path, "w") as fp:
        for item in data:
            simdjson.dump(item, fp)
            fp.write("\n")


if __name__ == "__main__":
    main(sys.argv[1:])
