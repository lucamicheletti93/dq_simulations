#!/bin/bash

export ALIEN_JDL_LPMANCHORPASSNAME="apass2"
export ALIEN_JDL_MCANCHOR="apass2"
export ALIEN_JDL_CPULIMIT=8
export ALIEN_JDL_LPMPASSNAME="apass2"
export ALIEN_JDL_LPMPRODUCTIONTYPE=MC
export ALIEN_JDL_LPMINTERACTIONTYPE="OO"
export ALIEN_JDL_COLLISIONSYSTEM="OO"
export ALIEN_JDL_LPMPRODUCTIONTAG="test_prompt_charmonia_anchor_25ae_pass2"
export ALIEN_JDL_LPMANCHORPRODUCTION="LHC25ae"
export ALIEN_JDL_LPMANCHORYEAR="2025"

export NTIMEFRAMES=16
export NSIGEVENTS=10000
export SPLITID=100
export PRODSPLIT=3351
export CYCLE=0

export ALIEN_JDL_O2DPG_ASYNC_RECO_TAG="O2PDPSuite::async-async-2025-OO-apass2-v1-slc9-alidist-async-2025-OO-apass2-v1-1"
export INIPATH="${O2DPG_ROOT}/MC/config/PWGDQ/ini/Generator_InjectedPromptCharmoniaFwdy_TriggerGap_OO5TeV.ini"
export ALIEN_JDL_ANCHOR_SIM_OPTIONS="-gen external -ini $INIPATH"

# disable QC
export DISABLE_QC=1

${O2DPG_ROOT}/MC/run/ANCHOR/anchorMC.sh
