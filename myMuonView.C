void myMuonView(string fInName = "sim_rej_list_high_stat/mch_pad_maps_filtered.root", string fOutName = "sim_rej_list_high_stat/muon_view_filtered.pdf") {
    TFile *fIn = TFile::Open(fInName.c_str());
    fIn->ls();
    TH2Poly *hMCHADC_DE1[4], *hMCHADC_DE2[4], *hMCHADC_DE3[4], *hMCHADC_DE4[4];
    TH2Poly *hMCHADC_DE5[18], *hMCHADC_DE6[18];
    TH2Poly *hMCHADC_DE7[26], *hMCHADC_DE8[26], *hMCHADC_DE9[26], *hMCHADC_DE10[26];

    for (int i = 0;i < 4;i++) {
        hMCHADC_DE1[i] = (TH2Poly*) fIn->Get(Form("hMCHADC_DE10%d", i));
        hMCHADC_DE2[i] = (TH2Poly*) fIn->Get(Form("hMCHADC_DE20%d", i));
        hMCHADC_DE3[i] = (TH2Poly*) fIn->Get(Form("hMCHADC_DE30%d", i));
        hMCHADC_DE4[i] = (TH2Poly*) fIn->Get(Form("hMCHADC_DE40%d", i));
    }

    for (int i = 0;i < 18;i++) {
        hMCHADC_DE5[i] = (TH2Poly*) fIn->Get(Form(i < 10 ? "hMCHADC_DE50%d" : "hMCHADC_DE5%d", i));
        hMCHADC_DE6[i] = (TH2Poly*) fIn->Get(Form(i < 10 ? "hMCHADC_DE60%d" : "hMCHADC_DE6%d", i));
    }

    for (int i = 0;i < 26;i++) {
        hMCHADC_DE7[i] = (TH2Poly*) fIn->Get(Form(i < 10 ? "hMCHADC_DE70%d" : "hMCHADC_DE7%d", i));
        hMCHADC_DE8[i] = (TH2Poly*) fIn->Get(Form(i < 10 ? "hMCHADC_DE80%d" : "hMCHADC_DE8%d", i));
        hMCHADC_DE9[i] = (TH2Poly*) fIn->Get(Form(i < 10 ? "hMCHADC_DE90%d" : "hMCHADC_DE9%d", i));
        hMCHADC_DE10[i] = (TH2Poly*) fIn->Get(Form(i < 10 ? "hMCHADC_DE100%d" : "hMCHADC_DE10%d", i));
    }
    

    TH2D *hGrid = new TH2D("hGrid", "", 100, -300, 300, 100, -300, 300);

    TLatex *latexTitle = new TLatex();
    latexTitle -> SetTextSize(0.07);
    latexTitle -> SetNDC();
    latexTitle -> SetTextFont(42);

    TCanvas *canvasMuonView = new TCanvas("canvasMuonView", "", 1800, 1200);
    gStyle->SetOptStat(false);
    canvasMuonView->Divide(5, 2);

    canvasMuonView->cd(1);
    gPad->SetLogz(true);
    hGrid->Draw();
    for (int i = 0;i < 4;i++) {hMCHADC_DE1[i]->Draw(i == 0 ? "COLZ SAME" : "SAME");}
    latexTitle->DrawLatex(0.45, 0.85, "DE1");

    canvasMuonView->cd(2);
    gPad->SetLogz(true);
    hGrid->Draw();
    for (int i = 0;i < 4;i++) {hMCHADC_DE2[i]->Draw(i == 0 ? "COLZ SAME" : "SAME");}
    latexTitle->DrawLatex(0.45, 0.85, "DE2");


    canvasMuonView->cd(3);
    gPad->SetLogz(true);
    hGrid->Draw();
    for (int i = 0;i < 4;i++) {hMCHADC_DE3[i]->Draw(i == 0 ? "COLZ SAME" : "SAME");}
    latexTitle->DrawLatex(0.45, 0.85, "DE3");

    canvasMuonView->cd(4);
    gPad->SetLogz(true);
    hGrid->Draw();
    for (int i = 0;i < 4;i++) {hMCHADC_DE4[i]->Draw(i == 0 ? "COLZ SAME" : "SAME");}
    latexTitle->DrawLatex(0.45, 0.85, "DE4");

    canvasMuonView->cd(5);
    gPad->SetLogz(true);
    hGrid->Draw();
    for (int i = 0;i < 18;i++) {hMCHADC_DE5[i]->Draw(i == 0 ? "COLZ SAME" : "SAME");}
    latexTitle->DrawLatex(0.45, 0.85, "DE5");

    canvasMuonView->cd(6);
    gPad->SetLogz(true);
    hGrid->Draw();
    for (int i = 0;i < 18;i++) {hMCHADC_DE6[i]->Draw(i == 0 ? "COLZ SAME" : "SAME");}
    latexTitle->DrawLatex(0.45, 0.85, "DE6");

    canvasMuonView->cd(7);
    gPad->SetLogz(true);
    hGrid->Draw();
    for (int i = 0;i < 26;i++) {hMCHADC_DE7[i]->Draw(i == 0 ? "COLZ SAME" : "SAME");}
    latexTitle->DrawLatex(0.45, 0.85, "DE7");

    canvasMuonView->cd(8);
    gPad->SetLogz(true);
    hGrid->Draw();
    for (int i = 0;i < 26;i++) {hMCHADC_DE8[i]->Draw(i == 0 ? "COLZ SAME" : "SAME");}
    latexTitle->DrawLatex(0.45, 0.85, "DE8");

    canvasMuonView->cd(9);
    gPad->SetLogz(true);
    hGrid->Draw();
    for (int i = 0;i < 26;i++) {hMCHADC_DE9[i]->Draw(i == 0 ? "COLZ SAME" : "SAME");}
    latexTitle->DrawLatex(0.45, 0.85, "DE9");

    canvasMuonView->cd(10);
    gPad->SetLogz(true);
    hGrid->Draw();
    for (int i = 0;i < 26;i++) {hMCHADC_DE10[i]->Draw(i == 0 ? "COLZ SAME" : "SAME");}
    latexTitle->DrawLatex(0.43, 0.85, "DE10");


    canvasMuonView->SaveAs(fOutName.c_str());

}