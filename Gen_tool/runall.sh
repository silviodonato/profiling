#!/bin/bash
CMSSW_v=$1


VDT=""

echo "Your SCRAM_ARCH "

if [ "X$ARCHITECTURE" != "X" ]; then
  export SCRAM_ARCH=$ARCHITECTURE
else
  export SCRAM_ARCH=slc7_amd64_gcc900
fi

if [ "X$PROFILING_WORKFLOW" == "X" ];then
  export PROFILING_WORKFLOW="23434.21"
fi 

if [ "X$WORKSPACE" != "X" ]; then
  cd $WORKSPACE/$CMSSW_v/$PROFILING_WORKFLOW
else
  export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
  echo "$VO_CMS_SW_DIR $SCRAM_ARCH"
  source $VO_CMS_SW_DIR/cmsset_default.sh
  cd $CMSSW_v/TimeMemory
  unset PYTHONPATH
  export LC_ALL=C
  eval `scramv1 runtime -sh`
fi

echo "My loc"
echo $PWD

if [ "X$WORKSPACE" != "X" ]; then
  export WRAPPER=$WORKSPACE/profiling/circles-wrapper.py
fi

export DARSHAN_LOGPATH=$DW_JOB_STRIPED/darshan-logs
y=$(date +%Y)
m=$(date +%m)
d=$(date +%d)
mkdir -p ${DARSHAN_LOGPATH}/$y/${m/0/}/${d/0/}
export DARSHAN_ENABLE_NONMPI=1
export DARSHAN_EXCLUDE_DIRS=/cvmfs
export LC_ALL=C

echo step1
LD_PRELOAD=/global/homes/g/gartung/darshan/3.2.1/lib/libdarshan.so cmsRun$VDT $WRAPPER $(ls *_GEN_SIM.py)  >& step1$VDT.log


echo step2
LD_PRELOAD=/global/homes/g/gartung/darshan/3.2.1/lib/libdarshan.so cmsRun$VDT $WRAPPER $(ls step2*.py) >& step2$VDT.log


echo step3
LD_PRELOAD=/global/homes/g/gartung/darshan/3.2.1/lib/libdarshan.so cmsRun$VDT $WRAPPER $(ls step3*.py)  >& step3$VDT.log


echo step4
LD_PRELOAD=/global/homes/g/gartung/darshan/3.2.1/lib/libdarshan.so cmsRun$VDT $WRAPPER $(ls step4*.py)  >& step4$VDT.log

rsync -av ${DW_JOB_STRIPED}/darshan-logs/ ${SCRATCH}/darshan-logs/
