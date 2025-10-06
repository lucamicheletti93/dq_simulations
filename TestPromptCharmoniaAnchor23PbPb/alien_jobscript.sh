#!/bin/bash

export ALIEN_JDL_LPMANCHORPASSNAME="apass4"
export ALIEN_JDL_MCANCHOR="apass4"
export ALIEN_JDL_CPULIMIT=8
export ALIEN_JDL_LPMPASSNAME="apass4"
#export ALIEN_JDL_LPMRUNNUMBER="559348"
export ALIEN_JDL_LPMPRODUCTIONTYPE=MC
export ALIEN_JDL_LPMINTERACTIONTYPE="PbPb"
export ALIEN_JDL_COLLISIONSYSTEM="PbPb"
export ALIEN_JDL_LPMPRODUCTIONTAG="test_prompt_charmonia_anchor_23PbPb5TeV"
#export ALIEN_JDL_LPMANCHORRUN="559348"
export ALIEN_JDL_LPMANCHORPRODUCTION="LHC25b4b4"
export ALIEN_JDL_LPMANCHORYEAR="2023"

export NTIMEFRAMES=4
export NSIGEVENTS=100
export SPLITID=100
export PRODSPLIT=3351
export CYCLE=0

export ALIEN_JDL_O2DPG_ASYNC_RECO_TAG="VO_ALICE@O2PDPSuite::async-async-v1-01-15-slc9-alidist-async-v1-01-02-1"
export INIPATH="${O2DPG_ROOT}/MC/config/PWGDQ/ini/Generator_InjectedPromptCharmoniaFwdy_TriggerGap_PbPb5TeV.ini"
export ALIEN_JDL_ANCHOR_SIM_OPTIONS="-gen external -genBkg pythia8 -procBkg \"heavy_ion\" -nb 5 -colBkg PbPb -ini $INIPATH --embedding --embeddPattern @0:e2"

# disable QC
export DISABLE_QC=1

${O2DPG_ROOT}/MC/run/ANCHOR/anchorMC.sh
