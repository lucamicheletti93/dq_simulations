#!/bin/bash

# add distortion maps
# https://alice.its.cern.ch/jira/browse/O2-3346?focusedCommentId=300982&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-300982
#
# export O2DPG_ENABLE_TPC_DISTORTIONS=OFF
# SCFile=$PWD/distortions_5kG_lowIR.root # file needs to be downloaded
# export O2DPG_TPC_DIGIT_EXTRA=" --distortionType 2 --readSpaceCharge ${SCFile} "

#
# procedure setting up and executing an anchored MC 
#

WD=$PWD

# make sure O2DPG + O2 is loaded
[ ! "${O2DPG_ROOT}" ] && echo "Error: This needs O2DPG loaded" && exit 1
[ ! "${O2_ROOT}" ] && echo "Error: This needs O2 loaded" && exit 1

chmod +x *.py
chmod +x *.sh

# ------ CREATE AN MC CONFIG STARTING FROM RECO SCRIPT --------
# - this part should not be done on the GRID, where we should rather
#   point to an existing config (O2DPG repo or local disc or whatever)
export ALIEN_JDL_LPMANCHORYEAR=${ALIEN_JDL_LPMANCHORYEAR:-2023}

# PROD="jpsi_coh"
# RUNNUMBER_IN=544991
# RUNNUMBER_MC=544991
# PRODSPLIT=10
# SPLITID=2
# SPLITOFFSET=0
# CYCLE=0

PROD=$1
RUNNUMBER_IN=$2
RUNNUMBER_MC=$3
PRODSPLIT=$4
SPLITID=$5
SPLITOFFSET=$6
CYCLE=$7

SPLITOFFSET=${SPLITOFFSET:-0}
RUNNUMBER=${RUNNUMBER_IN:-544451}
RUNNUMBER_MC=${RUNNUMBER_MC:-544451}

# the only four where there is a real default for
export CPULIMIT=8
export NWORKERS=8

export ALIEN_JDL_CPULIMIT=${ALIEN_JDL_CPULIMIT:-${CPULIMIT:-8}}
export ALIEN_JDL_SIMENGINE=${ALIEN_JDL_SIMENGINE:-${SIMENGINE:-TGeant4}}
export ALIEN_JDL_WORKFLOWDETECTORS=${ALIEN_JDL_WORKFLOWDETECTORS:-ITS,TPC,TOF,FV0,FT0,FDD,MID,MFT,MCH,TRD,EMC,PHS,CPV,HMP,CTP}
export ALIEN_JDL_ANCHOR_SIM_OPTIONS=${ALIEN_JDL_ANCHOR_SIM_OPTIONS:--gen hepmc}
# all others MUST be set by the user/on the outside

export ALIEN_JDL_LPMRUNNUMBER=${RUNNUMBER_IN:-526641}
export ALIEN_JDL_LPMANCHORRUN=${RUNNUMBER_IN:-526641}
export ALIEN_JDL_LPMINTERACTIONTYPE=pp
export ALIEN_JDL_LPMPRODUCTIONTAG="LHC22o"
export ALIEN_JDL_LPMANCHORPRODUCTION="LHC22o"
export ALIEN_JDL_MCANCHOR="apass7"
export ALIEN_JDL_LPMPASSNAME="apass7"
export ALIEN_JDL_LPMANCHORPASSNAME="apass7"
export ALIEN_JDL_LPMPRODUCTIONTYPE="MC"
export ALIEN_JDL_LPMANCHORYEAR=2022

### async_pass.sh
DPGRECO=$O2DPG_ROOT/DATA/production/configurations/asyncReco/async_pass.sh
DPGSETENV=$O2DPG_ROOT/DATA/production/configurations/asyncReco/setenv_extra.sh

if [[ -f async_pass.sh ]]; then
    # the default is executable, however, this may not be, so make it so
    chmod +x async_pass.sh
    DPGRECO=./async_pass.sh
else
    cp -v $DPGRECO .
fi

if [[ ! -f setenv_extra.sh ]] ; then
    cp ${DPGSETENV} .
    echo "[INFO alien_setenv_extra.sh] Use default setenv_extra.sh from ${DPGSETENV}."
else
    echo "[INFO alien_setenv_extra.sh] setenv_extra.sh was found in the current working directory, use it."
fi

#settings that are MC-specific
sed -i 's/GPU_global.dEdxUseFullGainMap=1;GPU_global.dEdxDisableResidualGainMap=1/GPU_global.dEdxSplineTopologyCorrFile=splines_for_dedx_V1_MC_iter0_PP.root;GPU_global.dEdxDisableTopologyPol=1;GPU_global.dEdxDisableGainMap=1;GPU_global.dEdxDisableResidualGainMap=1;GPU_global.dEdxDisableResidualGain=1/' setenv_extra.sh
### ???

chmod u+x async_pass.sh
chmod u+x setenv_extra.sh

# take out line running the workflow (if we don't have data input)
[ ${CTF_TEST_FILE} ] || sed -i '/WORKFLOWMODE=run/d' async_pass.sh

# create workflow ---> creates the file that can be parsed
export IGNORE_EXISTING_SHMFILES=1
touch list.list

./async_pass.sh ${CTF_TEST_FILE:-""} 2&> async_pass_log.log
RECO_RC=$?

echo "RECO finished with ${RECO_RC}"
if [ "${NO_MC}" ]; then
  return ${RECO_RC} 2>/dev/null || exit ${RECO_RC} # optionally quit here and don't do MC (useful for testing)
fi

ALIEN_JDL_LPMPRODUCTIONTAG=$ALIEN_JDL_LPMPRODUCTIONTAG_KEEP
echo "Setting back ALIEN_JDL_LPMPRODUCTIONTAG to $ALIEN_JDL_LPMPRODUCTIONTAG"

# now create the local MC config file --> config-config.json
${O2DPG_ROOT}/UTILS/parse-async-WorkflowConfig.py

# check if config reasonably created
if [[ `grep "o2-ctf-reader-workflow-options" config-json.json 2> /dev/null | wc -l` == "0" ]]; then
  echo "Problem in anchor config creation. Stopping."
  exit 1
fi

# -- CREATE THE MC JOB DESCRIPTION ANCHORED TO RUN --
NWORKERS=${NWORKERS:-8}
MODULES="--skipModules ZDC"
SIMENGINE=${SIMENGINE:-TGeant4}
SIMENGINE=${ALIEN_JDL_SIMENGINE:-${SIMENGINE}}
NTIMEFRAMES=${NTIMEFRAMES:-10}

# SEED=1
SPLITID=${SPLITID:-2}
SPLITID=$((SPLITID+1))
SPLITID=$((SPLITID+SPLITOFFSET))
PRODSPLIT=${PRODSPLIT:-1}
PRODSPLIT=$((PRODSPLIT+2))
CYCLE=${CYCLE:-0}
let SEED=$SPLITID+$CYCLE*$PRODSPLIT

NSIGPTF=${NSIGPTF:-100}
NBKGPTF=${NBKGPTF:-5}

# input mc events
PROD=${PROD:-"jpsi_coh"}
export HEPMC_LOCAL_FILE=${HEPMC_LOCAL_FILE:-"events.hepmc"}
HEPMC_EVENTS_DIR="/alice/cern.ch/user/n/nburmaso/pbpb2024mc/prod/hepmc/apass4-jira/$PROD/$RUNNUMBER"

echo "alien.py cp alien:$HEPMC_EVENTS_DIR/events.hepmc file:$HEPMC_LOCAL_FILE"
alien.py cp alien:$HEPMC_EVENTS_DIR/events.hepmc file:$HEPMC_LOCAL_FILE
SPLIT=$((SPLITID-1))
root -l -b -q split_events.cpp\($NSIGPTF,$NTIMEFRAMES,$SPLIT\)

# signal hepmc + pbpb
# baseargs="-ns ${NSIGPTF} -nb ${NBKGPTF} -do-embedding True -tf ${NTIMEFRAMES} --split-id ${SPLITID} --prod-split ${PRODSPLIT} --cycle ${CYCLE} --run-number ${RUNNUMBER}"
# remainingargs="-eCM 5360 \
#                -col PbPb -gen "hepmc" -proc heavy_ion \
#                -colBkg PbPb -genBkg "pythia8" -procBkg heavy_ion \
#                --mft-reco-full \
#                -seed ${SEED} \
#                -confKey \"HepMC.fileName=${HEPMC_LOCAL_FILE};HepMC.version=3;\""

# signal hepmc only
baseargs="-ns ${NSIGPTF} -tf ${NTIMEFRAMES} --split-id ${SPLITID} --prod-split ${PRODSPLIT} --cycle ${CYCLE} --run-number ${RUNNUMBER}"
remainingargs="-eCM 5360 \
               -col PbPb -gen "hepmc" -proc heavy_ion \
               --mft-reco-full \
               -seed ${SEED} \
               --event-gen-mode integrated \
               --combine-tpc-clusterization \
               -confKey \"HepMC.fileName=${HEPMC_LOCAL_FILE};HepMC.version=3;\""

# align-geom.mDetectors=none

# # box
# baseargs="-ns ${NSIGPTF} -tf ${NTIMEFRAMES} --split-id ${SPLITID} --prod-split ${PRODSPLIT} --cycle ${CYCLE} --run-number ${RUNNUMBER}"
# remainingargs="-eCM 5360 \
#                -col PbPb -gen "extgen" -proc heavy_ion \
#                --mft-reco-full \
#                -seed ${SEED} \
#                -confKey \"GeneratorExternal.fileName=$O2DPG_ROOT/MC/config/PWGDQ/external/generator/GeneratorBoxFwd.C;GeneratorExternal.funcName=fwdMuBoxGen(50,13,-4.00,-2.50,1.5,2.5)\""

remainingargs="${remainingargs} -e ${SIMENGINE} -j ${NWORKERS}"
remainingargs="${remainingargs} -productionTag ${ALIEN_JDL_LPMPRODUCTIONTAG:-alibi_anchorTest_tmp}"
remainingargs="${remainingargs} --anchor-config config-json.json"
remainingargs="${remainingargs} --include-local-qc"

echo "baseargs: ${baseargs}"
echo "remainingargs: ${remainingargs}"

export SIMDIR=$PWD
export ALICEO2_CCDB_LOCALCACHE=$PWD/.ccdb

# query CCDB has changed, w/o "_"
chmod +x o2dpg_sim_workflow_anchored.py
./o2dpg_sim_workflow_anchored.py ${baseargs} -- ${remainingargs} &> timestampsampling_${RUNNUMBER}.log
[ "$?" != "0" ] && echo "Problem during anchor timestamp sampling " && exit 1

TIMESTAMP=`grep "Determined timestamp to be" timestampsampling_${RUNNUMBER}.log | awk '//{print $6}'`
echo "TIMESTAMP IS ${TIMESTAMP}"

# -- PREFETCH CCDB OBJECTS TO DISC      --
# (make sure the right objects at the right timestamp are fetched
#  until https://alice.its.cern.ch/jira/browse/O2-2852 is fixed)
export ALICEO2_CCDB_LOCALCACHE=$PWD/.ccdb
[ ! -d .ccdb ] && mkdir .ccdb

TIMESTAMP=`grep "Determined timestamp to be" timestampsampling_${ALIEN_JDL_LPMRUNNUMBER}.log | awk '//{print $6}'`
echo "TIMESTAMP IS ${TIMESTAMP}"

# standard ccdb objects
declare -a CCDBOBJECTS=( "/CTP/Calib/OrbitReset" "/GLO/Config/GRPMagField/" "/GLO/Config/GRPLHCIF" "/ITS/Calib/DeadMap" "/ITS/Calib/NoiseMap" "/ITS/Calib/ClusterDictionary" "/TPC/Calib/PadGainFull" "/TPC/Calib/TopologyGain" "/TPC/Calib/TimeGain" "/TPC/Calib/PadGainResidual" "/TPC/Config/FEEPad" "/TOF/Calib/Diagnostic" "/TOF/Calib/LHCphase" "/TOF/Calib/FEELIGHT" "/TOF/Calib/ChannelCalib" "/MFT/Calib/DeadMap" "/MFT/Calib/NoiseMap" "/MFT/Calib/ClusterDictionary" "/FT0/Calib/ChannelTimeOffset" "/FV0/Calib/ChannelTimeOffset" )

for obj in "${CCDBOBJECTS[@]}"; do
  ${O2_ROOT}/bin/o2-ccdb-downloadccdbfile --host http://alice-ccdb.cern.ch/ -p ${obj} -d .ccdb --timestamp ${TIMESTAMP}
  if [ ! "$?" == "0" ]; then
    echo "Problem during CCDB prefetching of ${CCDBOBJECTS}. Exiting."
    exit 1
  fi
done

# -- Create aligned geometry using ITS ideal alignment to avoid overlaps in geant
CCDBOBJECTS_IDEAL_MC="ITS/Calib/Align"
TIMESTAMP_IDEAL_MC=1
${O2_ROOT}/bin/o2-ccdb-downloadccdbfile --host http://alice-ccdb.cern.ch/ -p ${CCDBOBJECTS_IDEAL_MC} -d ${ALICEO2_CCDB_LOCALCACHE} --timestamp ${TIMESTAMP_IDEAL_MC}
if [ ! "$?" == "0" ]; then
  echo "Problem during CCDB prefetching of ${CCDBOBJECTS_IDEAL_MC}. Exiting."
  exit 1
fi

echo "run with echo in pipe" | ${O2_ROOT}/bin/o2-create-aligned-geometry-workflow --configKeyValues "HBFUtils.startTime=${TIMESTAMP}" --condition-remap=file://${ALICEO2_CCDB_LOCALCACHE}=ITS/Calib/Align -b
mkdir -p $ALICEO2_CCDB_LOCALCACHE/GLO/Config/GeometryAligned
ln -s -f $PWD/o2sim_geometry-aligned.root $ALICEO2_CCDB_LOCALCACHE/GLO/Config/GeometryAligned/snapshot.root

# ccdb objects for mch
declare -a CCDBOBJECTS=( "/Users/n/nburmaso/test/MCH/Calib/RejectList" "/MCH/Calib/HV")

for obj in "${CCDBOBJECTS[@]}"; do
  ${O2_ROOT}/bin/o2-ccdb-downloadccdbfile --host http://alice-ccdb.cern.ch/ -p ${obj} -d .ccdb --timestamp ${TIMESTAMP}
  if [ ! "$?" == "0" ]; then
    echo "Problem during CCDB prefetching of ${CCDBOBJECTS}. Exiting."
    exit 1
  fi
done

# custom ccdb objects for mch
mkdir -p $ALICEO2_CCDB_LOCALCACHE/MCH/Calib/RejectList/
mkdir -p $ALICEO2_CCDB_LOCALCACHE/MCH/Calib/BadChannel/
cp $ALICEO2_CCDB_LOCALCACHE/Users/n/nburmaso/test/MCH/Calib/RejectList/* $ALICEO2_CCDB_LOCALCACHE/MCH/Calib/RejectList/
cp $ALICEO2_CCDB_LOCALCACHE/Users/n/nburmaso/test/MCH/Calib/RejectList/* $ALICEO2_CCDB_LOCALCACHE/MCH/Calib/BadChannel/


# custom ccdb objects for mid
mkdir -p $ALICEO2_CCDB_LOCALCACHE/MID/Calib/ChamberEfficiency/

if [[ $RUNNUMBER < 544511 ]]; then
  declare -a CCDBOBJECTS=( "Users/l/lquaglia/MID/Calib/ChamberEfficiency/LHC23_PbPb_pass3_fullTPC_perRun" )
  for obj in "${CCDBOBJECTS[@]}"; do
    ${O2_ROOT}/bin/o2-ccdb-downloadccdbfile --host http://alice-ccdb.cern.ch/ -p ${obj} -d .ccdb --timestamp ${TIMESTAMP}
    if [ ! "$?" == "0" ]; then
      echo "Problem during CCDB prefetching of ${CCDBOBJECTS}. Exiting."
      exit 1
    fi
  done
  cp $ALICEO2_CCDB_LOCALCACHE/Users/l/lquaglia/MID/Calib/ChamberEfficiency/LHC23_PbPb_pass3_fullTPC_perRun/* $ALICEO2_CCDB_LOCALCACHE/MID/Calib/ChamberEfficiency/
else
  declare -a CCDBOBJECTS=( "Users/l/lquaglia/MID/Calib/ChamberEfficiency/LHC23_PbPb_pass3_I-A11_perRun" )
  for obj in "${CCDBOBJECTS[@]}"; do
    ${O2_ROOT}/bin/o2-ccdb-downloadccdbfile --host http://alice-ccdb.cern.ch/ -p ${obj} -d .ccdb --timestamp ${TIMESTAMP}
    if [ ! "$?" == "0" ]; then
      echo "Problem during CCDB prefetching of ${CCDBOBJECTS}. Exiting."
      exit 1
    fi
  done
  cp $ALICEO2_CCDB_LOCALCACHE/Users/l/lquaglia/MID/Calib/ChamberEfficiency/LHC23_PbPb_pass3_I-A11_perRun/* $ALICEO2_CCDB_LOCALCACHE/MID/Calib/ChamberEfficiency/
fi


# -- RUN THE MC WORKLOAD TO PRODUCE AOD --

export FAIRMQ_IPC_PREFIX=./

echo "Ready to start main workflow"

# reduce memory/cpu usage
sed -i "s|tpc-lanes ${NWORKERS}|tpc-lanes 2|g" workflow.json

echo "********* RUNNING ARGUMENTS ***********"
echo "MC RUN ${RUNNUMBER_MC}"
echo "SEED   ${SEED}"
echo "********* DONE ************************"

${O2DPG_ROOT}/MC/bin/o2_dpg_workflow_runner.py \
  -f workflow.json \
  --stdout-on-failure --keep-going \
  --optimistic-resources \
  -tt ${ALIEN_JDL_O2DPGWORKFLOWTARGET:-aod} \
  --cpu-limit ${ALIEN_JDL_CPULIMIT:-8}


# ${O2DPG_ROOT}/MC/bin/o2_dpg_workflow_runner.py \
#   -f workflow.json \
#   --cpu-limit ${ALIEN_JDL_CPULIMIT:-8} \
#   --keep-going \
#   --target-labels QC

if [ ! -f $WD/AO2D.root ]; then
  echo "AO2D.root file not found! Trying to merge what we have..."
  find $WD/tf* -name "AO2D.root" | sort -V > $WD/mergelist.txt
  echo
  if [ ! -s $WD/mergelist.txt ]; then
    echo "No AO2Ds to be merged!"
  else
    echo "Found AO2Ds to be merged:"
    echo "Found `cat $WD/mergelist.txt | wc -l` AO2Ds!"
    cat $WD/mergelist.txt
  fi
  echo
  o2-aod-merger --input $WD/mergelist.txt --output $WD/AO2D.root
fi
