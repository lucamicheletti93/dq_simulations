#!/bin/bash

export O2DPG_MC_CONFIG_ROOT=/cvmfs/alice.cern.ch/el9-x86_64/Packages/O2DPG/daily-20241114-0000-1  # version with the fix
export ALIEN_JDL_O2DPG_MC_CONFIG_ROOT=/cvmfs/alice.cern.ch/el9-x86_64/Packages/O2DPG/daily-20241114-0000-1  # version with the fix
export ALIEN_JDL_ANCHOR_SIM_OPTIONS="-gen external -ini $O2DPG_MC_CONFIG_ROOT/MC/config/PWGDQ/ini/GeneratorHF_bbbar_PsiAndJpsi_midy_triggerGap.ini"
${O2DPG_ROOT}/MC/run/ANCHOR/anchorMC.sh

