# msdial

## Build and Run

your installation may require to use `sudo` adapt the below command accordingly

```
docker build -t msdial_console:470 .
docker run --rm -it -v YOUR_LOCAL_PATH:/data msdial_console:470 /bin/bash

cd /data
```

Then execute the commands in the Test section below.

### Build the singularity container

In order to build the Singularity image a docker registry is needed.

```
docker run -d -p 5000:5000 --name registry registry:2
```

and the built image must be tagged and pushed to the local registry

```
docker image tag msdial_console:470 localhost:5000/msdial_console:470
docker push localhost:5000/msdial_console:470
```

finally converting the container from Docker to Singularity

```
 singularity build --nohttps ../msdial:4.70.sif  docker://localhost:5000/msdial_console:470
```

## Tests

Execute the commands from withing a container Docker or
Singularity. Remember that in docker you are usually the root user
while with Singularity you are a regular user

```
curl -k -s -S -LJO "http://prime.psc.riken.jp/compms/msdial/download/demo/MsdialConsoleApp%20demo%20files.zip"

unzip MsdialConsoleApp%20demo%20files.zip
mkdir -p LCMS_DDA
mkdir -p GCMS
mkdir -p LCMS_DIA

MsdialConsoleApp lcmsdda -i MsdialConsoleApp\ demo\ files/LCMS_DDA/ -o LCMS_DDA -m MsdialConsoleApp\ demo\ files/LCMS_DDA/Msdial-lcms-dda-Param.txt -p

MsdialConsoleApp gcms -i MsdialConsoleApp\ demo\ files/GCMS/ -o GCMS/ -m MsdialConsoleApp\ demo\ files/GCMS/Msdial-GCMS-Param.txt

MsdialConsoleApp lcmsdda -i MsdialConsoleApp\ demo\ files/LCMS_DDA/ -o LCMS_DDA/ -m MsdialConsoleApp\ demo\ files/LCMS_DDA/Msdial-lcms-dda-Param.txt
# The default configuration file must be fixed because they are using DOS PATH 
#MsdialConsoleApp lcmsdia -i MsdialConsoleApp\ demo\ files/LCMS_DIA/ -o LCMS_DIA -m MsdialConsoleApp\ demo\ files/LCMS_DIA/Msdial-lcms-dia-Param.txt
```
