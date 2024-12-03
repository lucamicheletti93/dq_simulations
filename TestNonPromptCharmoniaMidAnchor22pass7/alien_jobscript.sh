

#!/bin/bash

export ALIEN_JDL_LPMANCHORPASSNAME=${ALIEN_JDL_LPMANCHORPASSNAME:-"apass7"}
export ALIEN_JDL_MCANCHOR=${ALIEN_JDL_MCANCHOR:-"apass7"}
export ALIEN_JDL_LPMPASSNAME=${ALIEN_JDL_LPMPASSNAME:-"apass7"}
export ALIEN_JDL_LPMRUNNUMBER=${ALIEN_JDL_LPMRUNNUMBER:-"526641"}
export ALIEN_JDL_LPMPRODUCTIONTYPE=${ALIEN_JDL_LPMPRODUCTIONTYPE:-"MC"}
export ALIEN_JDL_LPMINTERACTIONTYPE=${ALIEN_JDL_LPMINTERACTIONTYPE:-"pp"}
export ALIEN_JDL_LPMANCHORRUN=${ALIEN_JDL_LPMANCHORRUN:-"526641"}
export ALIEN_JDL_LPMANCHORPRODUCTION=${ALIEN_JDL_LPMANCHORPRODUCTION:-"LHC22o"}
export ALIEN_JDL_LPMANCHORYEAR=${ALIEN_JDL_LPMANCHORYEAR:-"2022"}

# added export
export NTIMEFRAMES=8
export NSIGEVENTS=1000
export SPLITID=1
export CYCLE=0
export PRODSPLIT=8

#export ALIEN_JDL_ANCHOR_SIM_OPTIONS="-gen external -ini $O2DPG_ROOT/MC/config/PWGDQ/ini/GeneratorHF_bbbar_PsiAndJpsi_midy_triggerGap.ini"


# modify ini file, to have external generator and/or config from a specific tag different from the one used for anchoring
ORIGINALINI=${O2DPG_ROOT}/MC/config/PWGDQ/ini/GeneratorHF_bbbar_PsiAndJpsi_midy_triggerGap.ini # original .ini file to be modified
MODIFIEDINI=GeneratorHF_bbbar_PsiAndJpsi_midy_triggerGap_fromCVMFS.ini # output name for the modified .ini file

CFGTOREPLACE="\${O2DPG_MC_CONFIG_ROOT}/MC/config/common/pythia8/generator/pythia8_hf.cfg" # original config file name to be modified
CFGFROMCVMFS="/cvmfs/alice.cern.ch/el9-x86_64/Packages/O2DPG/daily-20241202-0000/MC/config/common/pythia8/generator/pythia8_hf.cfg" # new config file name to use

GENTOREPLACE="\${O2DPG_ROOT}/MC/config/PWGDQ/external/generator/generator_pythia8_NonPromptSignals_gaptriggered_dq.C" # original external generator file name to be modified
GENFROMCVMFS="/cvmfs/alice.cern.ch/el9-x86_64/Packages/O2DPG/daily-20241202-0000/MC/config/PWGDQ/external/generator/generator_pythia8_NonPromptSignals_gaptriggered_dq.C" # new external generator file name to use

if [ ! -f $MODIFIEDINI ]; then
    sed -e "s|$CFGTOREPLACE|$CFGFROMCVMFS|g" -e "s|$GENTOREPLACE|$GENFROMCVMFS|g" $ORIGINALINI > $MODIFIEDINI
fi

cat $MODIFIEDINI

MODIFIEDINI_PATH=$(readlink -f $MODIFIEDINI)

echo "Absolute path for MODIFIEDINI: $MODIFIEDINI_PATH"

#echo "Checking permissions for MODIFIEDINI:"
#ls -l $MODIFIEDINI
#chmod a+r $MODIFIEDINI
#ls -l $MODIFIEDINI

export ALIEN_JDL_ANCHOR_SIM_OPTIONS="-gen external -ini $MODIFIEDINI_PATH"

${O2DPG_ROOT}/MC/run/ANCHOR/anchorMC.sh

