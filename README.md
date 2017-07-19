# WebTier Benchmark

The WebTier Benchmark repo

## Installing

sudo apt-get install -y python-pip

git clone this_repo dir

cd dir

pip install -r requirements.txt  (this can be done only once)

sudo ./deploy --setup=setup.json

## Running

cd dir

sudo ./run --benchmark=benchmark.json

## Cleaning up

cd dir

sudo ./undeploy

## Testing
cd dir 

pip install -r requirements-testing.txt

py.test --capture=sys -v
