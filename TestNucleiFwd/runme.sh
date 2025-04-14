export O2DPG_MC_CONFIG_ROOT=/cvmfs/alice.cern.ch/el9-x86_64/Packages/O2DPG/daily-20250228-0000-1
export O2DPG_ASYNC_RECO_TAG="O2PDPSuite::async-async-v1-01-11f-slc9-alidist-async-v1-01-02tris-1"
export ALIEN_JDL_ANCHOR_SIM_OPTIONS="-gen external -ini ${O2DPG_MC_CONFIG_ROOT}/MC/config/PWGLF/ini/GeneratorLFNucleiFwdppGap.ini"

${O2DPG_ROOT}/MC/run/ANCHOR/anchorMC.sh