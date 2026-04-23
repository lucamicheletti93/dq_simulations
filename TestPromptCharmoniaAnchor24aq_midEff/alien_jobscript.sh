#!/bin/bash

export ALIEN_JDL_CPULIMIT=8
export ALIEN_JDL_LPMANCHORPASSNAME="apass1"
export ALIEN_JDL_MCANCHOR="apass1"
export ALIEN_JDL_COLLISIONSYSTEM="pp"
export ALIEN_JDL_LPMPASSNAME="apass1"
#export ALIEN_JDL_LPMRUNNUMBER="544013"
export ALIEN_JDL_LPMPRODUCTIONTYPE="MC"
export ALIEN_JDL_LPMINTERACTIONTYPE="pp"
export ALIEN_JDL_LPMPRODUCTIONTAG="TestPromptCharmoniaAnchor24aq_midEff"
#export ALIEN_JDL_LPMANCHORRUN="559348"
export ALIEN_JDL_LPMANCHORPRODUCTION="LHC24aq"
export ALIEN_JDL_LPMANCHORYEAR="2024"
export ALIEN_JDL_REMAPPINGS="http://alice-ccdb.cern.ch/Users/l/lmichele/MID/Calib/ChamberEfficiency/TestLHC24aq"
#export ALIEN_JDL_REMAPPINGS="http://alice-ccdb.cern.ch/Users/l/lmichele/MID/Calib/ChamberEfficiency"
#REMAPPINGS="http://alice-ccdb.cern.ch/Users/l/lmichele/MID/Calib/ChamberEfficiency/LHC24aq";

export NTIMEFRAMES=4
export NSIGEVENTS=100
export SPLITID=100
export PRODSPLIT=3351
export CYCLE=0

# disable QC
export DISABLE_QC=1

export ALIEN_JDL_O2DPG_ASYNC_RECO_TAG="VO_ALICE@O2PDPSuite::async-async-v1-02-02-slc8-alidist-async-v1-02-01-1" # async tag
export O2DPG_MC_CONFIG_ROOT="/cvmfs/alice.cern.ch/el9-x86_64/Packages/O2DPG/daily-20251008-0000-1"
export INIPATH="${O2DPG_ROOT}/MC/config/PWGDQ/ini/Generator_InjectedPromptCharmoniaFwdy_TriggerGap_pp5TeV.ini"
export ALIEN_JDL_ANCHOR_SIM_OPTIONS="-gen external -ini $INIPATH"

${O2DPG_ROOT}/MC/run/ANCHOR/anchorMC.sh