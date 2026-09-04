# dq_simulations

## Basic commands
- Copy AO2Ds locally for checking:
  ```ruby
  alien.py cp -dst file:. <list of files>
  ```
- Run the code to check the MC:
  ```ruby
  o2-analysis-dq-efficiency-with-assoc -b --configuration json://configuration.json | o2-analysis-dq-table-maker-mc-with-assoc -b --configuration json://configuration.json | o2-analysis-fwdtrackextension -b --configuration json://configuration.json | o2-analysis-fwdtrack-to-collision-associator -b --configuration json://configuration.json | o2-analysis-multcenttable -b --configuration json://configuration.json | o2-analysis-event-selection-service -b --configuration json://configuration.json --aod-file @input_data.txt --aod-writer-json OutputDirector.json
  ```

  ```ruby
  o2-analysis-dq-efficiency-with-assoc -b --configuration json://configuration.json | o2-analysis-mccollision-converter -b --configuration json://configuration.json |o2-analysis-tracks-extra-v002-converter -b --configuration json://configuration.json | o2-analysis-dq-table-maker-mc-with-assoc -b --configuration json://configuration.json | o2-analysis-fwdtrackextension -b --configuration json://configuration.json | o2-analysis-fwdtrack-to-collision-associator -b --configuration json://configuration.json | o2-analysis-multcenttable -b --configuration json://configuration.json | o2-analysis-event-selection-service -b --configuration json://configuration.json --aod-file @input_data.txt --aod-writer-json OutputDirector.json
  ```

## Local simulations
- Run a simulation to test new ini files:
  ```ruby
  o2-sim -j 4 -n 100 -g external -o sgn --configFile ${O2DPG_ROOT}/MC/config/PWGDQ/ini/Generator_InjectedPromptCharmoniaFwdy_TriggerGap_OO5TeV.ini
  ```
  
If you want to produce an AO2D.root you need to run a full simulation. You can copy the workflow from monalisa (e.g. /alice/sim/2025/LHC25i4/0/564356/001/workflow.json). You need to modify the path of the software release to run it. After having modified the workflow.json you can run the following command

```ruby
${O2DPG_ROOT}/MC/bin/o2dpg_workflow_runner.py -f workflow.json -tt aod
```

## MCH standalone simulations: reject list validation
For this part you need o2-sim. You can build it with the following command:
```ruby
aliBuild build O2sim --defaults o2 -j 20
```
and then you can load it with the command:
```ruby
alienv enter O2sim/latest-o2
```
After that o2-sim is available you can use the following procedure:
- Run a single detector simulation:
  ```ruby
  o2-sim -g fwmugen -m MCH -n 100000 -j 20 --run 545210
  ```
- Run the digitization workflow:
  ```ruby
  o2-sim-digitizer-workflow
  ```
- Run filtering of DE with reject list:
  ```ruby
  o2-mch-digits-reader-workflow \
  --mch-digit-infile mchdigits.root \
  --disable-mc \
  | o2-mch-statusmap-creator-workflow \
      --configKeyValues 'MCHStatusMap.useBadChannels=false;MCHStatusMap.useRejectList=true;MCHStatusMap.useHV=false' \
      --condition-backend http://alice-ccdb.cern.ch \
      --condition-remap \
      'http://alice-ccdb.cern.ch/Users/s/sgaretti/rejectList/dummy_noDE202_3rdVersion/=MCH/Calib/RejectList' \
  | o2-mch-digits-filtering-workflow \
      --disable-mc \
      --configKeyValues 'MCHDigitFilter.statusMask=2' \
  | o2-mch-digits-writer-workflow \
      --input-digits-data-description F-DIGITS \
      --input-digitrofs-data-description F-DIGITROFS \
      --outfile mchdigits_filtered.root \
      --nevents -1 \
      --terminate workflow \
      --run
  ```
- Run the code to produce the MCH pad mapping after enabling the ROOT environment:
  ```ruby
  .L drawMCHDigits.C
  ```
  ```ruby
  drawMCHDigits("sim_run_545210/mchdigits.root", "sim_run_545210/mch_pad_maps.root", "sim_run_545210/o2sim_geometry-aligned.root")
  ```
- Run the plotting of the reject list:
  ```ruby
  .L myMuonView.C
  ```
  ```ruby
  myMuonView("sim_run_545210/mch_pad_maps_filtered.root", "sim_run_545210/muon_view_filtered.pdf")
  ```
- It is also possible to plot the MCH segmentation:
  ```ruby
  o2-mch-mapping-svg-segmentation3 --hidepadchannels --hidepads --de 100 --prefix chamber1
  ```
