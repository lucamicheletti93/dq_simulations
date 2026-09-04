// ============================================================
// drawMCHDigits.C
//
// Legge i digit MCH da mchdigits.root e crea una mappa ADC
// per ogni Detection Element (DE), usando:
//
//   1) MCH Mapping O2 per pad position/size
//   2) o2sim_geometry.root per la trasformazione geometrica
//
// OUTPUT:
//   mch_pad_maps.root
//
// Nel file di output vengono salvati SOLO i TH2Poly.
//
// Nessun canvas viene creato.
// Nessun Draw() viene eseguito.
//
// ESECUZIONE:
//
//   root
//   .x drawMCHDigits.C
//
// oppure:
//
//   .x drawMCHDigits.C("mchdigits.root","mch_pad_maps.root")
//
// IMPORTANTE:
//   NON usare .L drawMCHDigits.C++
//   perché nel tuo ambiente ACLiC non linka automaticamente
//   le librerie O2 MCH Mapping.
//
// ============================================================

#include <iostream>
#include <map>
#include <string>
#include <algorithm>
#include <cmath>

// ROOT
#include "TFile.h"
#include "TTree.h"
#include "TTreeReader.h"
#include "TTreeReaderArray.h"
#include "TH2Poly.h"
#include "TSystem.h"
#include "TString.h"
#include "TGeoManager.h"

// O2
#include "MCHMappingInterface/Segmentation.h"
#include "MCHGeometryTransformer/Transformations.h"
//#include "DetectorsBase/GeometryManager.h"
#include "MathUtils/Cartesian.h"


// ============================================================
// O2 installation
// ============================================================

// for mac
const char* O2MCHLIB =
    "/Users/lucamicheletti/alice/sw/osx_arm64/"
    "O2/daily-20260224-0000-local1/lib/";

// for ubuntu
/*const char* O2MCHLIB =
    "/home/lmichele/alice/sw/ubuntu2404_x86-64"
    "O2/daily-20260903-0000-local1/lib/";*/


// ============================================================
// Helper: transform local point -> global point
// ============================================================

o2::math_utils::Point3D<double>
transformPoint(
    const o2::mch::geo::TransformationCreator& transformation,
    int deid,
    double x,
    double y)
{
    o2::math_utils::Point3D<double> local;

    local.SetX(x);
    local.SetY(y);
    local.SetZ(0.0);

    auto transform = transformation(deid);

    return transform(local);
}


// ============================================================
// Main function
// ============================================================

void drawMCHDigits(
    const char* inputFile =
        "sim_rej_list_high_stat/mchdigits_filtered.root",

    const char* outputFile =
        "sim_rej_list_high_stat/mch_pad_maps_filtered.root",

    const char* geometryFile =
        "sim_rej_list_high_stat/o2sim_geometry-aligned.root")
{
    std::cout << "\n";
    std::cout
        << "============================================================\n";
    std::cout
        << "                    MCH DIGIT MAP\n";
    std::cout
        << "============================================================\n";
    std::cout << "\n";


    // ========================================================
    // 1. Load MCH Mapping libraries
    // ========================================================

    std::string lib3 =
        std::string(O2MCHLIB) +
        "libO2MCHMappingImpl3.dylib";

    std::string lib4 =
        std::string(O2MCHLIB) +
        "libO2MCHMappingImpl4.dylib";

    std::cout
        << "Loading MCH Mapping libraries...\n";

    int ret3 =
        gSystem->Load(lib3.c_str());

    int ret4 =
        gSystem->Load(lib4.c_str());

    std::cout
        << "  Impl3: "
        << ret3
        << "\n";

    std::cout
        << "  Impl4: "
        << ret4
        << "\n";


    // ========================================================
    // 2. Load geometry
    //
    // This is the important part:
    //
    // GeometryManager loads o2sim_geometry.root and creates
    // gGeoManager.
    //
    // We then construct the official MCH transformation
    // from the TGeo geometry.
    // ========================================================

    std::cout << "\n";
    std::cout
        << "Loading MCH geometry...\n";

    try {

        o2::base::GeometryManager::loadGeometry(
            geometryFile);

    }
    catch (...) {

        std::cerr
            << "ERROR: could not load geometry file:\n"
            << geometryFile
            << "\n";

        return;
    }


    if (!gGeoManager) {

        std::cerr
            << "ERROR: gGeoManager is null after loading geometry.\n";

        return;
    }


    std::cout
        << "Geometry loaded successfully.\n";


    // ========================================================
    // 3. Create MCH geometry transformation
    //
    // transformation(deid) converts coordinates from the
    // local coordinate system of a DE to the global MCH
    // coordinate system.
    //
    // This is the same mechanism used by O2 itself.
    // ========================================================

    o2::mch::geo::TransformationCreator transformation;

    try {

        transformation =
            o2::mch::geo::transformationFromTGeoManager(
                *gGeoManager);

    }
    catch (...) {

        std::cerr
            << "ERROR: could not create MCH transformation "
            << "from TGeo geometry.\n";

        return;
    }


    std::cout
        << "MCH geometry transformation created.\n";


    // ========================================================
    // 4. Open input ROOT file
    // ========================================================

    TFile* fin =
        TFile::Open(inputFile, "READ");


    if (!fin || fin->IsZombie()) {

        std::cerr
            << "ERROR: cannot open input file: "
            << inputFile
            << "\n";

        return;
    }


    std::cout
        << "\nInput file: "
        << inputFile
        << "\n";


    // ========================================================
    // 5. Get TTree
    // ========================================================

    TTree* tree = nullptr;

    fin->GetObject(
        "o2sim",
        tree);


    if (!tree) {

        std::cerr
            << "ERROR: TTree 'o2sim' not found.\n";

        fin->Close();
        delete fin;

        return;
    }


    std::cout
        << "Tree found: "
        << tree->GetName()
        << "\n";

    std::cout
        << "Entries: "
        << tree->GetEntries()
        << "\n";


    if (tree->GetEntries() == 0) {

        std::cerr
            << "ERROR: tree contains no entries.\n";

        fin->Close();
        delete fin;

        return;
    }


    // ========================================================
    // 6. TTreeReader
    //
    // Branches:
    //
    // MCHDigit.mDetID
    // MCHDigit.mPadID
    // MCHDigit.mADC
    // ========================================================

    TTreeReader reader(tree);


    TTreeReaderArray<Int_t> detID(
        reader,
        "MCHDigit.mDetID");


    TTreeReaderArray<Int_t> padID(
        reader,
        "MCHDigit.mPadID");


    TTreeReaderArray<UInt_t> adc(
        reader,
        "MCHDigit.mADC");


    // ========================================================
    // 7. Accumulate ADC
    //
    // padADC[DE][padID] = total ADC
    // ========================================================

    std::map<int, std::map<int, double>> padADC;


    Long64_t nDigits = 0;


    std::cout
        << "\nReading digits...\n";


    while (reader.Next()) {

        const Long64_t n =
            detID.GetSize();


        if (padID.GetSize() != n ||
            adc.GetSize() != n) {

            std::cerr
                << "ERROR: inconsistent array sizes "
                << "in one tree entry.\n";

            fin->Close();
            delete fin;

            return;
        }


        for (Long64_t i = 0; i < n; ++i) {

            const int deid =
                detID[i];

            const int pid =
                padID[i];

            const double charge =
                static_cast<double>(adc[i]);


            padADC[deid][pid] += charge;

            ++nDigits;
        }
    }


    std::cout
        << "\nNumber of digits = "
        << nDigits
        << "\n";


    // ========================================================
    // 8. Print DE summary
    // ========================================================

    std::cout
        << "\nDetection Elements found: "
        << padADC.size()
        << "\n";


    for (const auto& deEntry : padADC) {

        const int deid =
            deEntry.first;

        const auto& pads =
            deEntry.second;

        std::cout
            << "  DE "
            << deid
            << " : "
            << pads.size()
            << " active pads\n";
    }


    // ========================================================
    // 9. Open output file
    // ========================================================

    TFile* fout =
        TFile::Open(
            outputFile,
            "RECREATE");


    if (!fout || fout->IsZombie()) {

        std::cerr
            << "ERROR: cannot create output file: "
            << outputFile
            << "\n";

        fin->Close();
        delete fin;

        return;
    }


    // ========================================================
    // 10. Create one TH2Poly per DE
    // ========================================================

    int nDE = 0;

    int nInvalidPads = 0;

    int nAddedPads = 0;


    for (const auto& deEntry : padADC) {

        const int deid =
            deEntry.first;

        const auto& pads =
            deEntry.second;


        std::cout << "\n";

        std::cout
            << "------------------------------------------------------------\n";

        std::cout
            << "DE "
            << deid
            << "\n";

        std::cout
            << "------------------------------------------------------------\n";


        // ====================================================
        // Get O2 segmentation
        // ====================================================

        const o2::mch::mapping::Segmentation& seg =
            o2::mch::mapping::segmentation(deid);


        std::cout
            << "Total pads in segmentation: "
            << seg.nofPads()
            << "\n";


        // ====================================================
        // Determine GLOBAL geometrical limits
        //
        // We transform the four corners of every pad first.
        //
        // This is crucial because DEs can be rotated.
        // ====================================================

        double xmin =  1.e30;
        double xmax = -1.e30;

        double ymin =  1.e30;
        double ymax = -1.e30;


        int nValidPads = 0;


        for (const auto& padEntry : pads) {

            const int pid =
                padEntry.first;


            if (!seg.isValid(pid)) {

                ++nInvalidPads;

                continue;
            }


            // ------------------------------------------------
            // Pad center in LOCAL DE coordinates
            // ------------------------------------------------

            const double x =
                seg.padPositionX(pid);

            const double y =
                seg.padPositionY(pid);


            // ------------------------------------------------
            // Pad half-size in LOCAL DE coordinates
            // ------------------------------------------------

            const double dx =
                seg.padSizeX(pid) / 2.0;

            const double dy =
                seg.padSizeY(pid) / 2.0;


            // ------------------------------------------------
            // Four LOCAL corners
            // ------------------------------------------------

            const auto p1 =
                transformPoint(
                    transformation,
                    deid,
                    x - dx,
                    y - dy);


            const auto p2 =
                transformPoint(
                    transformation,
                    deid,
                    x + dx,
                    y - dy);


            const auto p3 =
                transformPoint(
                    transformation,
                    deid,
                    x + dx,
                    y + dy);


            const auto p4 =
                transformPoint(
                    transformation,
                    deid,
                    x - dx,
                    y + dy);


            // ------------------------------------------------
            // Determine GLOBAL limits
            // ------------------------------------------------

            xmin =
                std::min(
                    xmin,
                    std::min(
                        std::min(p1.x(), p2.x()),
                        std::min(p3.x(), p4.x())));


            xmax =
                std::max(
                    xmax,
                    std::max(
                        std::max(p1.x(), p2.x()),
                        std::max(p3.x(), p4.x())));


            ymin =
                std::min(
                    ymin,
                    std::min(
                        std::min(p1.y(), p2.y()),
                        std::min(p3.y(), p4.y())));


            ymax =
                std::max(
                    ymax,
                    std::max(
                        std::max(p1.y(), p2.y()),
                        std::max(p3.y(), p4.y())));


            ++nValidPads;
        }


        if (nValidPads == 0) {

            std::cerr
                << "WARNING: DE "
                << deid
                << " contains no valid pads.\n";

            continue;
        }


        // ====================================================
        // Add margin
        // ====================================================

        double marginX =
            0.02 * (xmax - xmin);

        double marginY =
            0.02 * (ymax - ymin);


        // Protect against zero-size ranges
        if (marginX <= 0.)
            marginX = 0.1;

        if (marginY <= 0.)
            marginY = 0.1;


        xmin -= marginX;
        xmax += marginX;

        ymin -= marginY;
        ymax += marginY;


        // ====================================================
        // Create TH2Poly
        // ====================================================

        TString hname;

        hname.Form(
            "hMCHADC_DE%d",
            deid);


        TString htitle;

        htitle.Form(
            "MCH DE %d;Global X [cm];Global Y [cm]",
            deid);


        TH2Poly* h =
            new TH2Poly(
                hname,
                htitle,
                xmin,
                xmax,
                ymin,
                ymax);


        // ====================================================
        // Add one POLYGON per pad
        //
        // IMPORTANT:
        //
        // The four corners are defined in LOCAL coordinates
        // and transformed individually into GLOBAL coordinates.
        //
        // Therefore a rotated DE produces rotated pads.
        // ====================================================

        int nAdded = 0;


        for (const auto& padEntry : pads) {

            const int pid =
                padEntry.first;

            const double charge =
                padEntry.second;


            if (!seg.isValid(pid)) {
                continue;
            }


            // ------------------------------------------------
            // Local pad center
            // ------------------------------------------------

            const double x =
                seg.padPositionX(pid);

            const double y =
                seg.padPositionY(pid);


            // ------------------------------------------------
            // Local pad half-size
            // ------------------------------------------------

            const double dx =
                seg.padSizeX(pid) / 2.0;

            const double dy =
                seg.padSizeY(pid) / 2.0;


            // ------------------------------------------------
            // Transform ALL FOUR corners
            // ------------------------------------------------

            const auto p1 =
                transformPoint(
                    transformation,
                    deid,
                    x - dx,
                    y - dy);


            const auto p2 =
                transformPoint(
                    transformation,
                    deid,
                    x + dx,
                    y - dy);


            const auto p3 =
                transformPoint(
                    transformation,
                    deid,
                    x + dx,
                    y + dy);


            const auto p4 =
                transformPoint(
                    transformation,
                    deid,
                    x - dx,
                    y + dy);


            // ------------------------------------------------
            // TH2Poly polygon
            // ------------------------------------------------

            double xPoly[4] = {
                p1.x(),
                p2.x(),
                p3.x(),
                p4.x()
            };


            double yPoly[4] = {
                p1.y(),
                p2.y(),
                p3.y(),
                p4.y()
            };


            const int bin =
                h->AddBin(
                    4,
                    xPoly,
                    yPoly);


            if (bin <= 0) {

                std::cerr
                    << "WARNING: could not add pad "
                    << pid
                    << " to DE "
                    << deid
                    << "\n";

                continue;
            }


            // ------------------------------------------------
            // ADC
            // ------------------------------------------------

            h->SetBinContent(
                bin,
                charge);


            ++nAdded;
            ++nAddedPads;
        }


        // ====================================================
        // Save ONLY histogram
        // ====================================================

        fout->cd();

        h->Write();


        std::cout
            << "Valid active pads: "
            << nValidPads
            << "\n";

        std::cout
            << "TH2Poly bins added: "
            << nAdded
            << "\n";


        ++nDE;
    }


    // ========================================================
    // 11. Final write
    // ========================================================

    fout->Write();


    // ========================================================
    // 12. Close files
    // ========================================================

    fout->Close();

    fin->Close();


    delete fout;
    delete fin;


    // ========================================================
    // 13. Final summary
    // ========================================================

    std::cout << "\n";

    std::cout
        << "============================================================\n";

    std::cout
        << "DONE\n";

    std::cout
        << "============================================================\n";

    std::cout
        << "Input file       : "
        << inputFile
        << "\n";

    std::cout
        << "Geometry file    : "
        << geometryFile
        << "\n";

    std::cout
        << "Output file      : "
        << outputFile
        << "\n";

    std::cout
        << "Digits           : "
        << nDigits
        << "\n";

    std::cout
        << "DEs              : "
        << nDE
        << "\n";

    std::cout
        << "Pads added       : "
        << nAddedPads
        << "\n";

    std::cout
        << "Invalid pads     : "
        << nInvalidPads
        << "\n";

    std::cout << "\n";

    std::cout
        << "Output contains ONLY TH2Poly objects.\n";

    std::cout
        << "No canvas was created.\n";

    std::cout
        << "No Draw() was executed.\n";

    std::cout << "\n";
}