#include <TFile.h>
#include <TTree.h>
#include <TH1.h>

#include "SimulationDataFormat/MCTrack.h"

#include <vector>
#include <iostream>


void readKine(const char* fInName = "MCKine.root") {
    TH1F *hPt = new TH1F("hPt", ";#it{p}_{T} (GeV/#it{c});Counts", 100, 0, 20);
    TH1F *hRap = new TH1F("hRap", ";#it{y};Counts", 100, -5, 5);
    TH1F *hMass = new TH1F("hMass", ";#it{m} (GeV^{2}/#it{c});Counts", 100, 0, 5);
    TFile* fIn = TFile::Open(fInName, "READ");
    if (!fIn || fIn->IsZombie()) {
        std::cerr << "Error opening fIn!" << std::endl;
        return;
    }

    TTree* tree = (TTree*)fIn->Get("o2sim");
    std::vector<o2::MCTrack>* tracks = nullptr;
    tree->SetBranchAddress("MCTrack", &tracks);

    for (Long64_t ev = 0; ev < tree->GetEntries(); ++ev) {
        tree->GetEntry(ev);
        std::cout << "Event " << ev << " has " << tracks->size() << " tracks." << std::endl;
        
        for (const auto& track : *tracks) {
            if (track.GetPdgCode() == 443) {
                std::cout << "J/psi pT = " << track.GetPt() << std::endl;
                std::cout << "J/psi y = " << track.GetRapidity() << std::endl;
                std::cout << "J/psi mass = " << track.GetMass() << std::endl;

                hPt->Fill(track.GetPt());
                hRap->Fill(track.GetRapidity());
                hMass->Fill(track.GetMass());
            }
        }
    }

    TFile *fOut = new TFile("sim_output.root", "RECREATE");
    hPt->Write();
    hRap->Write();
    hMass->Write();
    fOut->Close();

    fIn->Close();
}
