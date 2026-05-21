# dq_simulations

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

o2-analysis-dq-table-maker-mc-with-assoc -b --configuration json://configuration.json | o2-analysis-fwdtrackextension -b --configuration json://configuration.json | o2-analysis-mccollisionextra -b --configuration json://configuration.json | o2-analysis-tracks-extra-v002-converter -b --configuration json://configuration.json | o2-analysis-fwdtrack-to-collision-associator -b --configuration json://configuration.json | o2-analysis-multcenttable -b --configuration json://configuration.json | o2-analysis-event-selection-service -b --configuration json://configuration.json --aod-file @input_data.txt

o2-analysis-dq-table-maker-mc-with-assoc -b --configuration json://configuration.json | o2-analysis-fwdtrackextension -b --configuration json://configuration.json | o2-analysis-mccollisionextra -b --configuration json://configuration.json | o2-analysis-tracks-extra-v002-converter -b --configuration json://configuration.json | o2-analysis-fwdtrack-to-collision-associator -b --configuration json://configuration.json | o2-analysis-multcenttable -b --configuration json://configuration.json | o2-analysis-event-selection-service -b --configuration json://configuration.json | o2-analysis-dq-efficiency-with-assoc -b --configuration json://configuration.json --aod-file @input_data.txt


o2-analysis-dq-table-maker-mc-with-assoc -b --configuration json://configuration.json | o2-analysis-fwdtrackextension -b --configuration json://configuration.json | o2-analysis-mccollisionextra -b --configuration json://configuration.json | o2-analysis-fwdtrack-to-collision-associator -b --configuration json://configuration.json | o2-analysis-multcenttable -b --configuration json://configuration.json | o2-analysis-event-selection-service -b --configuration json://configuration.json --aod-file @input_data.txt

o2-analysis-dq-table-maker-mc-with-assoc -b --configuration json://configuration.json | o2-analysis-fwdtrackextension -b --configuration json://configuration.json | o2-analysis-mccollisionextra -b --configuration json://configuration.json | o2-analysis-fwdtrack-to-collision-associator -b --configuration json://configuration.json | o2-analysis-multcenttable -b --configuration json://configuration.json | o2-analysis-event-selection-service -b --configuration json://configuration.json | o2-analysis-dq-efficiency-with-assoc -b --configuration json://configuration.json --aod-file @input_data.txt

o2-analysis-dq-table-maker-mc-with-assoc -b --configuration json://configuration.json | o2-analysis-fwdtrackextension -b --configuration json://configuration.json | o2-analysis-fwdtrack-to-collision-associator -b --configuration json://configuration.json | o2-analysis-mccollisionextra -b --configuration json://configuration.json | o2-analysis-multcenttable -b --configuration json://configuration.json | o2-analysis-event-selection-service -b --configuration json://configuration.json --aod-file @input_data.txt