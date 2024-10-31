#include <cmath>
#include <cstdlib>
#include <ctime>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

#include "TFile.h"
#include "TH1.h"
#include "TH2.h"
#include "TLatex.h"
#include "TLegend.h"
#include "TLorentzVector.h"
#include "TRandom3.h"
#include "TRandomGen.h"
#include "TString.h"
#include "TTree.h"

const double mMu = 0.1056583745; 

const double rapMin = -4.1;
const double rapMax = -2.4;

struct HepMCEventInfo {
  int id;
  int nv;
  int npart;
};

struct HepMCParticle {
  int id;
  int motherID;
  int pdg;
  double px;
  double py;
  double pz;
  double e;
  TLorentzVector p;
  double m;
  int status;
};

class WriterHepMC
{
 public:
  WriterHepMC(const std::string& fname) { openFile(fname); }

  ~WriterHepMC() { closeFile(); }

  std::ofstream outfile;

  // open output file and print preamble
  void openFile(const std::string& fname)
  {
    outfile.open(fname);
    outfile << "HepMC::Version 3.02.04"
            << "\n"
            << "HepMC::Asciiv3-START_EVENT_LISTING"
            << "\n";
  }

  // write end-of-listing message and close output file
  void closeFile()
  {
    outfile << "HepMC::Asciiv3-END_EVENT_LISTING"
            << "\n";
    outfile.close();
  }

  void writeEventInfo(HepMCEventInfo& info)
  {
    outfile << "E " << info.id << " " << info.nv << " " << info.npart << "\n"
            << "U GEV MM"
            << "\n";
  }

  // writing basic event info with default HepMC units
  void writeEventInfo(int eventID, int nParticles, int nVertices = 0)
  {
    outfile << "E " << eventID << " " << nVertices << " " << nParticles << "\n"
            << "U GEV MM"
            << "\n";
  }

  void writeParticleInfo(HepMCParticle& part)
  {
    outfile << std::setprecision(9) << "P " << part.id << " " << part.motherID
            << " " << part.pdg << " " << part.p.Px() << " " << part.p.Py()
            << " " << part.p.Pz() << " " << part.p.E() << " " << part.m << " "
            << part.status << "\n";
  }

  void writeParticleInfo(int id, int motherID, int pdg, double px, double py,
                         double pz, double e, double m, int status)
  {
    outfile << std::setprecision(9) << "P " << id << " " << motherID << " "
            << pdg << " " << px << " " << py << " " << pz << " " << e << " "
            << m << " " << status << "\n";
  }
};

void split_events(int nEvPerTF = 100, int nTFs = 5, int splitId = 1)
{
  std::vector<HepMCParticle> parts;

  HepMCParticle hepMCPart;
  HepMCEventInfo eventInfo{};

  int itf = 1;
  int nTotal = nEvPerTF * nTFs;
  int startForJob = (splitId - 1) * nTotal;
  int startForTF = startForJob + (itf - 1) * nEvPerTF;
  int newEvID = 0;

  gSystem->Exec(Form("mkdir tf%d", itf));
  std::string local_hepmc = std::getenv("HEPMC_LOCAL_FILE");
  std::string fname = Form("tf%d/%s", itf, local_hepmc.c_str());
  WriterHepMC writer(fname);

  std::fstream infile("events.hepmc", std::ios::in);
  std::string line;

  int currentEvent = -1;
  while (std::getline(infile, line)) {
    std::istringstream iss(line);
    std::string type{};
    iss >> type >> hepMCPart.id >> hepMCPart.motherID >> hepMCPart.pdg >>
        hepMCPart.px >> hepMCPart.py >> hepMCPart.pz >> hepMCPart.e >>
        hepMCPart.m >> hepMCPart.status;
    if (type.find("P") == std::string::npos) continue;
    parts.emplace_back(hepMCPart); 
    // simply write events into other files
    if (parts.size() == 2) {
      currentEvent++;
      if (currentEvent < startForJob) {
        parts.clear();
        continue;
      }

      TLorentzVector p[2];
      p[0].SetXYZM(parts[0].px, parts[0].py, parts[0].pz, mMu);
      p[1].SetXYZM(parts[1].px, parts[1].py, parts[1].pz, mMu);

      // write event
      eventInfo.id = newEvID;
      eventInfo.nv = 0;
      eventInfo.npart = 2;
      newEvID++;
      writer.writeEventInfo(eventInfo);
      for (int ip = 0; ip < 2; ip++) {
        HepMCParticle hepmcPart{};
        hepmcPart.id = ip + 1;
        hepmcPart.pdg = parts[ip].pdg;
        hepmcPart.motherID = 0;
        hepmcPart.p = p[ip];
        hepmcPart.status = 1;
        hepmcPart.m = mMu;
        writer.writeParticleInfo(hepmcPart);
      }

      if (newEvID == nEvPerTF) {
        newEvID = 0;
        itf++;
        writer.closeFile();
        if (itf > nTFs) {
          parts.clear();
          break;
        }
        gSystem->Exec(Form("mkdir tf%d", itf));
        fname = Form("tf%d/events.hepmc", itf);
        writer.openFile(fname);
      }

      parts.clear();
    }
  }
}
