#!/bin/sh
 

b=$(sed -ne "${1}{p;q;}" files.txt)

cat > HFV1EPPlotting_${1}.C << +EOF


#include<TH1F>
#include<TProfile>
#include<iostream>
#include<iomanip>
#include"TFile.h"
#include"TTree.h"
#include"TLeaf.h"
#include"TChain.h"
#include "TComplex.h"

void Initialize();
void FillPTStats();
void FillAngularCorrections();
void EPPlotting();

//Files and chains
TChain* chain;//= new TChain("CaloTowerTree");
TChain* chain2;
TChain* chain3;
TChain* chain4;



//When I parrallelize this, I need to make sure that I do not fill <pT> and <pT*pT>
//Also, this only works because I do not need have any overlapping centrality classes. When I calculate_trodd+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c])) this would be a problem if i had overlapping classes

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
////////////           GLOBAL VARIABLES            //////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
Float_t pi=TMath::Pi();
Int_t vterm=1;//Set which order harmonic that this code is meant to measure
const Int_t jMax=10;////Set out to which order correction we would like to apply
Int_t NumberOfEvents=0;
//NumberOfEvents=1;
//NumberOfEvents=2;
//NumberOfEvents=10;
//NumberOfEvents=10000;
Int_t Centrality=0;
Float_t Zposition=0.;
//  NumberOfEvents = chain->GetEntries();

///Looping Variables
Int_t NumberOfHits=0;//This will be for both tracks and Hits
Float_t pT=0.;
Float_t phi=0.;
Float_t eta=0.;
Float_t Energy=0.;


//Create the output ROOT file
TFile *myFile;

const Int_t nCent=5;//Number of Centrality classes

Float_t centlo[nCent];
Float_t centhi[nCent];
centlo[0]=0;  centhi[0]=10;
centlo[1]=10;  centhi[1]=20;
centlo[2]=20;  centhi[2]=30;
centlo[3]=30;  centhi[3]=40;
centlo[4]=40;  centhi[4]=50;


//Make Subdirectories for what will follow
TDirectory *myPlots;//the top level

TDirectory *epangles;//where i will store the ep angles
TDirectory *wholehfepangles;
TDirectory *poshfepangles;
TDirectory *neghfepangles;
TDirectory *midtrackerangles;
////////////////////////////////////////////////
/////////////////////////////////
//Resolutions
TDirectory *resolutions;
TDirectory *evenresolutions;
TDirectory *oddresolutions;
/////////////////////////////////
//V1
TDirectory *v1plots;//where i will store the v1 plots
TDirectory *v1etaoddplots;//v1(eta) [odd] plots
TDirectory *v1etaevenplots; //v1(eta)[even] plots
TDirectory *v1ptevenplots; //v1(pT)[even] plots
TDirectory *v1ptoddplots;//v1(pT)[odd] plots
////////////////////////////////

TComplex Veven;
TComplex Vodd;


//Looping Variables
//v1 even
Float_t X_hfeven=0.,Y_hfeven=0.;
TComplex Q_HFEven;

//v1 odd
Float_t X_hfodd=0.,Y_hfodd=0.;
TComplex Q_HFOdd;

///Looping Variables
//v1 even
Float_t EPhfeven=0.;
TComplex QEP_hfeven[jMax];
Float_t AngularCorrectionHFEven=0.,EPfinalhfeven=0.;

//v1 odd
Float_t EPhfodd=0.;
TComplex QEP_hfodd[jMax];
Float_t AngularCorrectionHFOdd=0.,EPfinalhfodd=0.;

//PosHFEven
Float_t EP_poseven=0.,EP_finalposeven=0.;
Float_t AngularCorrectionHFPEven=0.;
TComplex Q_PosHFEven;
TComplex QEP_hfpeven[jMax];

//PosHFOdd
Float_t EP_posodd=0.,EP_finalposodd=0.;
Float_t AngularCorrectionHFPOdd=0.;
TComplex Q_PosHFOdd;
TComplex QEP_hfpodd[jMax];

//NegHFEven
Float_t EP_negeven=0.,EP_finalnegeven=0.;
Float_t AngularCorrectionHFNEven=0.;
TComplex Q_NegHFEven;
TComplex QEP_hfneven[jMax];

//NegHFOdd
Float_t EP_negodd=0.,EP_finalnegodd=0.;
Float_t AngularCorrectionHFNOdd=0.;
TComplex Q_NegHFOdd;
TComplex QEP_hfnodd[jMax];

//MidTrackerOdd
Float_t EP_trodd=0.,EP_finaltrodd=0.;
Float_t AngularCorrectionTROdd=0.;
TComplex Q_TROdd;
TComplex QEP_trodd[jMax];

//MidTrackerEven                                                                                  
Float_t EP_treven=0.,EP_finaltreven=0.;
Float_t AngularCorrectionTREven=0.;
TComplex Q_TREven;
TComplex QEP_treven[jMax];

//<pT> and <pT^2> 
Float_t ptavmid[nCent],pt2avmid[nCent];

//<Cos> <Sin>
                  //v1 even
                  //Whole HF
                  Float_t Sinhfeven[nCent][jMax],Coshfeven[nCent][jMax];
                  //Pos HF
                  Float_t Sinhfpeven[nCent][jMax],Coshfpeven[nCent][jMax];
                  //Neg HF
                  Float_t Sinhfneven[nCent][jMax],Coshfneven[nCent][jMax];
                  //Tracker
                  Float_t Sintreven[nCent][jMax],Costreven[nCent][jMax];
                  
                  //v1 odd
                  //Whole HF
                  Float_t Sinhfodd[nCent][jMax],Coshfodd[nCent][jMax];
                  //Pos HF
                  Float_t Sinhfpodd[nCent][jMax],Coshfpodd[nCent][jMax];
                  //Neg HF
                  Float_t Sinhfnodd[nCent][jMax],Coshfnodd[nCent][jMax];
                  //Tracker
                  Float_t Sintrodd[nCent][jMax],Costrodd[nCent][jMax];

//////////////////////////////////////////////////////

////////////////////////////////////////////
//Final EP Plots
//Psi1Even
//Whole HF
TH1F *PsiEvenRaw[nCent];
TH1F *PsiEvenFinal[nCent];
//PosHF
TH1F *PsiPEvenRaw[nCent];
TH1F *PsiPEvenFinal[nCent];
//NegHF
TH1F *PsiNEvenRaw[nCent];
TH1F *PsiNEvenFinal[nCent];
//Mid Tracker
TH1F *PsiTREvenRaw[nCent];
TH1F *PsiTREvenFinal[nCent];
//////////////////////////////////////////////
//Psi1 Odd
//Whole HF
TH1F *PsiOddRaw[nCent];
TH1F *PsiOddFinal[nCent];
//PosHF
TH1F *PsiPOddRaw[nCent];
TH1F *PsiPOddFinal[nCent];
//NegHF
TH1F *PsiNOddRaw[nCent];
TH1F *PsiNOddFinal[nCent];
//Mid Tracker               
TH1F *PsiTROddRaw[nCent];
TH1F *PsiTROddFinal[nCent];
///////////////////////////////////////////////

//Average Corrections
TProfile *PsiOddCorrs[nCent];
TProfile *PsiEvenCorrs[nCent];


////////////////////////////////
//Resolution Plots
//Even
TProfile *HFPMinusHFMEven;
TProfile *HFPMinusTREven;
TProfile *HFMMinusTREven;
//Odd
TProfile *HFPMinusHFMOdd;
TProfile *HFPMinusTROdd;
TProfile *HFMMinusTROdd;
/////////////////////////////////

//V1 Plots
//V1 Plots
TProfile *V1EtaOdd[nCent];
TProfile *V1EtaEven[nCent];
TProfile *V1PtEven[nCent];
TProfile *V1PtOdd[nCent];
//Single Side HF v 1
TProfile *V1OddHFP[nCent];
TProfile *V1OddHFM[nCent];
TProfile *V1EvenHFP[nCent];
TProfile *V1EvenHFM[nCent];

//PT Bin Centers
TProfile *PTCenters[nCent];
//////////////////////////////////

Int_t HFV1EPPlotting_${1}(){
  Initialize();
  FillPTStats();
  FillAngularCorrections();
  EPPlotting();
  return 0;
}


void Initialize(){

  //  std::cout<<"Made it into initialize"<<std::endl;
  //Float_t eta_bin_small[13]={-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.0,0.1,0.2,0.3,0.4,0.5,0.6};
  Float_t eta_bin_small[7]={-1.5,-1.0,-0.5,0.0,0.5,1.0,1.5};
  Double_t pt_bin[17]={0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.4,2.8,3.2,3.6,4.5,6.5,9.5,12};


//Zero the complex numbers
Q_HFOdd=TComplex(0.);
Q_HFEven=TComplex(0.);
Q_PosHFEven=TComplex(0.);
Q_PosHFOdd=TComplex(0.);
Q_NegHFOdd=TComplex(0.);
Q_NegHFEven=TComplex(0.);
Q_TROdd=TComplex(0.);
Q_TREven=TComplex(0.);

  //Angular Correction Numbers
  for (int zeroer=0;zeroer<jMax;zeroer++)
    {
      QEP_hfodd[zeroer]=TComplex(0.);
      QEP_hfeven[zeroer]=TComplex(0.);
      QEP_hfpodd[zeroer]=TComplex(0.);
      QEP_hfpeven[zeroer]=TComplex(0.);
      QEP_hfnodd[zeroer]=TComplex(0.);
      QEP_hfneven[zeroer]=TComplex(0.);
      QEP_trodd[zeroer]=TComplex(0.);
      QEP_treven[zeroer]=TComplex(0.);
    }




  chain= new TChain("hiGeneralAndPixelTracksTree");
  chain2=new TChain("CaloTowerTree");
  chain3=new TChain("hiSelectedVertexTree");
  chain4=new TChain("HFtowersCentralityTree");

  //Tracks Tree
  chain->Add("/hadoop/store/user/jgomez2/DataSkims/2011/2011MinBiasReReco/FinalTrees/$b");
  //Calo Tree
  chain2->Add("/hadoop/store/user/jgomez2/DataSkims/2011/2011MinBiasReReco/FinalTrees/$b");
   //Vertex Tree
  chain3->Add("/hadoop/store/user/jgomez2/DataSkims/2011/2011MinBiasReReco/FinalTrees/$b");
  //Centrality Tree
  chain4->Add("/hadoop/store/user/jgomez2/DataSkims/2011/2011MinBiasReReco/FinalTrees/$b");

  NumberOfEvents = chain2->GetEntries();
  //Create the output ROOT file
  myFile = new TFile("HFEP_EPPlottingV1_${1}.root","recreate");

  //Make Subdirectories for what will follow
  myPlots = myFile->mkdir("Plots");
  myPlots->cd();
  //////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////
  //Directory for the EP angles
  epangles = myPlots->mkdir("EventPlanes");
  wholehfepangles = epangles->mkdir("CombinedHF");
  poshfepangles = epangles->mkdir("PositiveHF");
  neghfepangles= epangles->mkdir("NegativeHF");
  midtrackerangles = epangles->mkdir("TrackerEP");
  ///////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////
  //EP Resolutions
  resolutions = myPlots->mkdir("Resolutions");
  //Even
  evenresolutions = resolutions->mkdir("EvenResolutions");
  evenresolutions->cd();
  HFPMinusHFMEven = new TProfile("HFPMinusHFMEven","Resolution of HF^{+} and HF^{-}",nCent,0,nCent);
  HFPMinusHFMEven->GetYaxis()->SetTitle("<cos(#Psi_{1}^{HF^{+}} - #Psi_{1}^{HF^{-}})>");
  HFPMinusTREven = new TProfile("HFPMinusTREven","Resolution of HF^{+} and the Tracker",nCent,0,nCent);
  HFPMinusTREven->GetYaxis()->SetTitle("<cos(#Psi_{1}^{HF^{+}} - #Psi_{1}^{TR})>");
  HFMMinusTREven = new TProfile("HFMMinusTREven","Resolution of HF^{-} and the Tracker",nCent,0,nCent);
  HFMMinusTREven->GetYaxis()->SetTitle("<cos(#Psi_{1}^{HF^{-}} - #Psi_{1}^{TR})>");
  //Odd
  oddresolutions = resolutions->mkdir("OddResolutions");
  oddresolutions->cd();
  HFPMinusHFMOdd = new TProfile("HFPMinusHFMOdd","Resolution of HF^{+} and HF^{-}",nCent,0,nCent);
  HFPMinusHFMOdd->GetYaxis()->SetTitle("<cos(#Psi_{1}^{HF^{+}} - #Psi_{1}^{HF^{-}})>");
  HFPMinusTROdd = new TProfile("HFPMinusTROdd","Resolution of HF^{+} and the Tracker",nCent,0,nCent);
  HFPMinusTROdd->GetYaxis()->SetTitle("<cos(#Psi_{1}^{HF^{+}} - #Psi_{1}^{TR})>");
  HFMMinusTROdd = new TProfile("HFMMinusTROdd","Resolution of HF^{-} and the Tracker",nCent,0,nCent);
  HFMMinusTROdd->GetYaxis()->SetTitle("<cos(#Psi_{1}^{HF^{-}} - #Psi_{1}^{TR})>");
  ////////////////////////////////////////////////////////////////
  //Directory For Final v1 plots
  v1plots = myPlots->mkdir("V1Results");
  v1etaoddplots = v1plots->mkdir("V1EtaOdd");
  v1etaevenplots = v1plots->mkdir("V1EtaEven");
  v1ptevenplots = v1plots->mkdir("V1pTEven");
  v1ptoddplots = v1plots->mkdir("V1pTOdd");




  ////////////////////////////////////////////////////////////
  //Psi1 Raw, Psi1 Final
  //Psi1(even)
  //Whole HF
  char epevenrawname[128],epevenrawtitle[128];
  char epevenfinalname[128],epevenfinaltitle[128];
  //Pos HF
  char poshfevenrawname[128],poshfevenrawtitle[128];
  char poshfevenfinalname[128],poshfevenfinaltitle[128];
  //Neg HF
  char neghfevenrawname[128],neghfevenrawtitle[128];
  char neghfevenfinalname[128],neghfevenfinaltitle[128];
  //Tracker
  char trevenrawname[128],trevenrawtitle[128];
  char trevenfinalname[128],trevenfinaltitle[128];
  //////////////////////////////////////////////////////////////
  //Psi1(odd)
  //Whole HF
  char epoddrawname[128],epoddrawtitle[128];
  char epoddfinalname[128],epoddfinaltitle[128];
  //Pos HF
  char poshfoddrawname[128],poshfoddrawtitle[128];
  char poshfoddfinalname[128],poshfoddfinaltitle[128];
  //Neg HF
  char neghfoddrawname[128],neghfoddrawtitle[128];
  char neghfoddfinalname[128],neghfoddfinaltitle[128];
  //Tracker                                       
  char troddrawname[128],troddrawtitle[128];
  char troddfinalname[128],troddfinaltitle[128];
  //////////////////////////////////////////////////////////////

  //Visualization of Correction Factors
  //Psi1(even)
  char psi1evencorrsname[128],psi1evencorrstitle[128];
  //Psi1(odd)
  char psi1oddcorrsname[128],psi1oddcorrstitle[128];
  /////////////////////////////////////////////////////////////
  //
  //V1 Plots
  //v1(even)
  char v1etaevenname[128],v1etaeventitle[128];
  char v1ptevenname[128],v1pteventitle[128];
  //v1(odd)
  char v1etaoddname[128],v1etaoddtitle[128];
  char v1ptoddname[128],v1ptoddtitle[128];
  char v1hfmetaname[128],v1hfmetatitle[128]; 
 char v1hfpetaname[128],v1hfpetatitle[128];
  char v1hfmetaevenname[128],v1hfmetaeventitle[128]; 
 char v1hfpetaevenname[128],v1hfpetaeventitle[128];


  //PT Centers
  char ptcentername[128],ptcentertitle[128];

  for (Int_t i=0;i<nCent;i++)
    {
      ///////////////////////////////////////////////////////////////////////////////////////////
      //Event Plane Plots
      wholehfepangles->cd();
      //Psi1Even
      //Whole HF
      //Raw
      sprintf(epevenrawname,"Psi1EvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epevenrawtitle,"#Psi_{1}^{even} Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiEvenRaw[i] = new TH1F(epevenrawname,epevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiEvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(epevenfinalname,"Psi1EvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epevenfinaltitle,"#Psi_{1}^{even} Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiEvenFinal[i] = new TH1F(epevenfinalname,epevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiEvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

      //Pos HF
      poshfepangles->cd();
      //Raw
      sprintf(poshfevenrawname,"Psi1PEvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(poshfevenrawtitle,"#Psi_{1}^{even}(HF^{+}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPEvenRaw[i] = new TH1F(poshfevenrawname,poshfevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPEvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(poshfevenfinalname,"Psi1PEvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(poshfevenfinaltitle,"#Psi_{1}^{even}(HF^{+}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPEvenFinal[i] = new TH1F(poshfevenfinalname,poshfevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPEvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");


      //Neg HF
      neghfepangles->cd();
      //Raw
      sprintf(neghfevenrawname,"Psi1NEvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(neghfevenrawtitle,"#Psi_{1}^{even}(HF^{-}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNEvenRaw[i] = new TH1F(neghfevenrawname,neghfevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNEvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(neghfevenfinalname,"Psi1NEvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(neghfevenfinaltitle,"#Psi_{1}^{even}(HF^{-}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNEvenFinal[i] = new TH1F(neghfevenfinalname,neghfevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNEvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

      //Tracker                                                     
      midtrackerangles->cd();
      //Raw
      sprintf(trevenrawname,"Psi1TREvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(trevenrawtitle,"#Psi_{1}^{even}(TR) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiTREvenRaw[i] = new TH1F(trevenrawname,trevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiTREvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(trevenfinalname,"Psi1TREvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(trevenfinaltitle,"#Psi_{1}^{even}(TR) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiTREvenFinal[i] = new TH1F(trevenfinalname,trevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiTREvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      

      ///////////////////////////////////////////////////////////////////////////////////

      //Psi1Odd
      wholehfepangles->cd();
      //Whole HF
      //Raw
      sprintf(epoddrawname,"Psi1OddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epoddrawtitle,"#Psi_{1}^{odd} Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiOddRaw[i] = new TH1F(epoddrawname,epoddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiOddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(epoddfinalname,"Psi1OddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epoddfinaltitle,"#Psi_{1}^{odd} Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiOddFinal[i] = new TH1F(epoddfinalname,epoddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiOddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

      //Pos HF
      poshfepangles->cd();
      //Raw
      sprintf(poshfoddrawname,"Psi1POddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(poshfoddrawtitle,"#Psi_{1}^{odd}(HF^{+}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPOddRaw[i] = new TH1F(poshfoddrawname,poshfoddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPOddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(poshfoddfinalname,"Psi1POddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(poshfoddfinaltitle,"#Psi_{1}^{odd}(HF^{+}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPOddFinal[i] = new TH1F(poshfoddfinalname,poshfoddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPOddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");


      //Neg HF
      neghfepangles->cd();
      //Raw
      sprintf(neghfoddrawname,"Psi1NOddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(neghfoddrawtitle,"#Psi_{1}^{odd}(HF^{-}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNOddRaw[i] = new TH1F(neghfoddrawname,neghfoddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNOddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(neghfoddfinalname,"Psi1NOddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(neghfoddfinaltitle,"#Psi_{1}^{odd}(HF^{-}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNOddFinal[i] = new TH1F(neghfoddfinalname,neghfoddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNOddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

      //Tracker                                                     
      midtrackerangles->cd();
      //Raw 
      sprintf(troddrawname,"Psi1TROddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(troddrawtitle,"#Psi_{1}^{odd}(TR) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiTROddRaw[i] = new TH1F(troddrawname,troddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.39269);
      PsiTROddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final 
      sprintf(troddfinalname,"Psi1TROddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(troddfinaltitle,"#Psi_{1}^{odd}(TR) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiTROddFinal[i] = new TH1F(troddfinalname,troddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiTROddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");


      ////////////////////////////////////////////////////////////////////////////
      //Magnitude of Angular Correction Plots
      //Psi1 Even
      //angcorr1even->cd();
      myPlots->cd();
      sprintf(psi1evencorrsname,"PsiEvenCorrs_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi1evencorrstitle,"PsiEvenCorrs_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiEvenCorrs[i]= new TProfile(psi1evencorrsname,psi1evencorrstitle,jMax,0,jMax);

      //Psi1 Odd
      //angcorr1odd->cd();
      myPlots->cd();
      sprintf(psi1oddcorrsname,"PsiOddCorrs_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi1oddcorrstitle,"PsiOddCorrs_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiOddCorrs[i]= new TProfile(psi1oddcorrsname,psi1oddcorrstitle,jMax,0,jMax);

      /////////////////////////////////////////////////
      //////V1 Plots
      //V1 Eta

      //Even
      v1etaevenplots->cd();
      sprintf(v1etaevenname,"V1Eta_Even_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1etaeventitle,"v_{1}^{even}(#eta) %1.0lfto%1.0lf",centlo[i],centhi[i]);
      V1EtaEven[i]= new TProfile(v1etaevenname,v1etaeventitle,6,eta_bin_small);
      

    //HFP v1even
      sprintf(v1hfpetaevenname,"V1Eta_Even_HFP_%1.0lfto%1.0lf",centlo[i],centhi[i]);
     sprintf(v1hfpetaeventitle,"v_{1}^{even}(#eta)HFP %1.0lfto%1.0lf",centlo[i],centhi[i]);
     V1EvenHFP[i]= new TProfile(v1hfpetaevenname,v1hfpetaeventitle,6,eta_bin_small);

    //HFM v1even
      sprintf(v1hfmetaevenname,"V1Eta_Even_HFM_%1.0lfto%1.0lf",centlo[i],centhi[i]);
     sprintf(v1hfmetaeventitle,"v_{1}^{even}(#eta)HFM %1.0lfto%1.0lf",centlo[i],centhi[i]);
     V1EvenHFM[i]= new TProfile(v1hfmetaevenname,v1hfmetaeventitle,6,eta_bin_small);

      //Odd
      v1etaoddplots->cd();
      sprintf(v1etaoddname,"V1Eta_Odd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1etaoddtitle,"v_{1}^{odd}(#eta) %1.0lfto%1.0lf",centlo[i],centhi[i]);
      V1EtaOdd[i]= new TProfile(v1etaoddname,v1etaoddtitle,6,eta_bin_small);

    //HFP v1odd
      sprintf(v1hfpetaname,"V1Eta_Odd_HFP_%1.0lfto%1.0lf",centlo[i],centhi[i]);
     sprintf(v1hfpetatitle,"v_{1}^{odd}(#eta)HFP %1.0lfto%1.0lf",centlo[i],centhi[i]);
     V1OddHFP[i]= new TProfile(v1hfpetaname,v1hfpetatitle,6,eta_bin_small);

    //HFM v1odd
      sprintf(v1hfmetaname,"V1Eta_Odd_HFM_%1.0lfto%1.0lf",centlo[i],centhi[i]);
     sprintf(v1hfmetatitle,"v_{1}^{odd}(#eta)HFM %1.0lfto%1.0lf",centlo[i],centhi[i]);
     V1OddHFM[i]= new TProfile(v1hfmetaname,v1hfmetatitle,6,eta_bin_small);


      //V1 Pt

      //Even
      v1ptevenplots->cd();
      sprintf(v1ptevenname,"V1Pt_Even_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1pteventitle,"v_{1}^{even}(p_{T}) %1.0lfto%1.0lf",centlo[i],centhi[i]);
      V1PtEven[i]= new TProfile(v1ptevenname,v1pteventitle,16,pt_bin);
      //Odd
      v1ptoddplots->cd();
      sprintf(v1ptoddname,"V1Pt_Odd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1ptoddtitle,"v_{1}^{odd}(p_{T}) %1.0lfto%1.0lf",centlo[i],centhi[i]);
      V1PtOdd[i]= new TProfile(v1ptoddname,v1ptoddtitle,16,pt_bin);

      //pT Centers
      v1plots->cd();
      sprintf(ptcentername,"PTCenter_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(ptcentertitle,"PTCenter_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      PTCenters[i] = new TProfile(ptcentername,ptcentertitle,16,pt_bin);

      }//end of loop over centralities

}//end of initialize function


void FillPTStats(){
//Mid Tracker
ptavmid[0]=0.830949;
ptavmid[1]=0.836451;
ptavmid[2]=0.835466;
ptavmid[3]=0.828784;
ptavmid[4]=0.818137;
 
pt2avmid[0]=0.965405;
pt2avmid[1]=0.983187;
pt2avmid[2]=0.986779;
pt2avmid[3]=0.978199;
pt2avmid[4]=0.960408;
 

}//end of ptstats function



void EPPlotting(){
  for (Int_t i=0;i<NumberOfEvents;i++)
    {
      if ( !(i%10000) ) cout << " 3rd round, event # " << i << " / " << NumberOfEvents << endl;

      chain2->GetEntry(i);//grab the ith event
      chain->GetEntry(i);
      chain3->GetEntry(i);
      chain4->GetEntry(i);
 
      //Filter On Centrality
      CENTRAL= (TLeaf*) chain4->GetLeaf("Bin");
      Centrality= CENTRAL->GetValue();
      if (Centrality>100) continue;

      //Make Vertex Cuts if Necessary
      Vertex=(TLeaf*) chain3->GetLeaf("z");
      Zposition=Vertex->GetValue();
      //if(Zposition<=5) continue;

      //Grab the Track Leaves
      NumTracks= (TLeaf*) chain->GetLeaf("nTracks");
      TrackMom= (TLeaf*) chain->GetLeaf("pt");
      TrackPhi= (TLeaf*) chain->GetLeaf("phi");
      TrackEta= (TLeaf*) chain->GetLeaf("eta");


      //Calo Tower Tree
      CaloHits= (TLeaf*) chain2->GetLeaf("Calo_NumberOfHits");
      CaloEN= (TLeaf*) chain2->GetLeaf("Et");
      CaloPhi= (TLeaf*) chain2->GetLeaf("Phi");
      CaloEta= (TLeaf*) chain2->GetLeaf("Eta");



     Q_HFOdd=TComplex(0.);
Q_HFEven=TComplex(0.);
Q_PosHFEven=TComplex(0.);
Q_PosHFOdd=TComplex(0.);
Q_NegHFOdd=TComplex(0.);
Q_NegHFEven=TComplex(0.);
Q_TROdd=TComplex(0.);
Q_TREven=TComplex(0.);

      for (int zeroer=0;zeroer<jMax;zeroer++)
        {
          QEP_hfodd[zeroer]=TComplex(0.);
          QEP_hfeven[zeroer]=TComplex(0.);
          QEP_hfpodd[zeroer]=TComplex(0.);
          QEP_hfpeven[zeroer]=TComplex(0.);
          QEP_hfnodd[zeroer]=TComplex(0.);
          QEP_hfneven[zeroer]=TComplex(0.);
          QEP_trodd[zeroer]=TComplex(0.);
          QEP_treven[zeroer]=TComplex(0.);
        }


      NumberOfHits= NumTracks->GetValue();
      for (Int_t ii=0;ii<NumberOfHits;ii++)
        {
          pT=0.;
          phi=0.;
          eta=0.;
          pT=TrackMom->GetValue(ii);
          phi=TrackPhi->GetValue(ii);
          eta=TrackEta->GetValue(ii);
          if(pT<0 || fabs(eta)>0.8) continue; //prevent negative pt tracks and non central tracks
	  for (Int_t c=0;c<nCent;c++)
            {
              if ( (Centrality*0.5) > centhi[c] ) continue;
              if ( (Centrality*0.5) < centlo[c] ) continue;
	      
	      if(eta>0.0)
		{
		  //Odd
		  Q_TROdd+=(pT-(pt2avmid[c]/ptavmid[c]))*TComplex::Exp(TComplex::I()*phi);
		  //Even
		  Q_TREven+=(pT-(pt2avmid[c]/ptavmid[c]))*TComplex::Exp(TComplex::I()*phi);
		}//positive eta tracks
	      else
		{
		  //Odd                                                   
                  Q_TROdd+=((-1.0*(pT-(pt2avmid[c]/ptavmid[c]))))*TComplex::Exp(TComplex::I()*phi);
                  //Even
                  Q_TREven+=(pT-(pt2avmid[c]/ptavmid[c]))*TComplex::Exp(TComplex::I()*phi);
		}//negative eta tracks
	    }//end of loop over centralities 
	}//end of loop over Tracks
      
      NumberOfHits= CaloHits->GetValue();
      for (int ii=0;ii<NumberOfHits;ii++)
        {
          Energy=0.;
          phi=0.;
          eta=0.;
          Energy=CaloEN->GetValue(ii);
          phi=CaloPhi->GetValue(ii);
          eta=CaloEta->GetValue(ii);
          if(Energy<0)
            {
              continue;
            }
          //std::cout<<"Energy was "<<Energy<<" and phi was "<<phi<<std::endl;
          if (eta>0.0)
            {
              //Whole HF Odd
              Q_HFOdd+=(Energy)*TComplex::Exp(TComplex::I()*phi);
              //Pos HF Odd
              Q_PosHFOdd+=(Energy)*TComplex::Exp(TComplex::I()*phi);
              //Whole HF Even
              Q_HFEven+=(Energy)*TComplex::Exp(TComplex::I()*phi);
              //Pos HF Even
              Q_PosHFEven+=(Energy)*TComplex::Exp(TComplex::I()*phi);
            }
          else if (eta<0.0)
            {
              //Whole HF Odd
              Q_HFOdd+=(-1.0*Energy)*TComplex::Exp(TComplex::I()*phi);
              //Neg HF Odd
              Q_NegHFOdd+=(-1.0*Energy)*TComplex::Exp(TComplex::I()*phi);
              //Whole HF   Even
              Q_HFEven+=(Energy)*TComplex::Exp(TComplex::I()*phi);
              // Neg HF Even
              Q_NegHFEven+=(Energy)*TComplex::Exp(TComplex::I()*phi);
            }
        }//end of loop over Calo Hits

      for (Int_t c=0;c<nCent;c++)
        {
          if ( (Centrality*0.5) > centhi[c] ) continue;
          if ( (Centrality*0.5) < centlo[c] ) continue;


          //V1 Even
          //Whole HF
          EPhfeven=-999;
          EPhfeven=(1./1.)*atan2(Q_HFEven.Im(),Q_HFEven.Re());
          if (EPhfeven>(pi)) EPhfeven=(EPhfeven-(TMath::TwoPi()));
          if (EPhfeven<(-1.0*(pi))) EPhfeven=(EPhfeven+(TMath::TwoPi()));
          PsiEvenRaw[c]->Fill(EPhfeven);

          //Pos HF
          EP_poseven=-999;
          EP_poseven=(1./1.)*atan2(Q_PosHFEven.Im(),Q_PosHFEven.Re());
          if (EP_poseven>(pi)) EP_poseven=(EP_poseven-(TMath::TwoPi()));
          if (EP_poseven<(-1.0*(pi))) EP_poseven=(EP_poseven+(TMath::TwoPi()));
          PsiPEvenRaw[c]->Fill(EP_poseven);

          //Neg HF
          EP_negeven=-999;
          EP_negeven=(1./1.)*atan2(Q_NegHFEven.Im(),Q_NegHFEven.Re());
          if (EP_negeven>(pi)) EP_negeven=(EP_negeven-(TMath::TwoPi()));
          if (EP_negeven<(-1.0*(pi))) EP_negeven=(EP_negeven+(TMath::TwoPi()));
          PsiNEvenRaw[c]->Fill(EP_negeven);

	  //Tracker
	  EP_treven=-999;
          EP_treven=(1./1.)*atan2(Q_TREven.Im(),Q_TREven.Re());
          if (EP_treven>(pi)) EP_treven=(EP_treven-(TMath::TwoPi()));
          if (EP_treven<(-1.0*(pi))) EP_treven=(EP_treven+(TMath::TwoPi()));
	  PsiTREvenRaw[c]->Fill(EP_treven);
          //////////////////////////////////////////////
          //V1 odd
          //Whole HF
          EPhfodd=-999;
          EPhfodd=(1./1.)*atan2(Q_HFOdd.Im(),Q_HFOdd.Re());
          if (EPhfodd>(pi)) EPhfodd=(EPhfodd-(TMath::TwoPi()));
          if (EPhfodd<(-1.0*(pi))) EPhfodd=(EPhfodd+(TMath::TwoPi()));
          PsiOddRaw[c]->Fill(EPhfodd);

          //Pos HF
          EP_posodd=-999;
          EP_posodd=(1./1.)*atan2(Q_PosHFOdd.Im(),Q_PosHFOdd.Re());
          if (EP_posodd>(pi)) EP_posodd=(EP_posodd-(TMath::TwoPi()));
          if (EP_posodd<(-1.0*(pi))) EP_posodd=(EP_posodd+(TMath::TwoPi()));
          PsiPOddRaw[c]->Fill(EP_posodd);

          //Neg HF
          EP_negodd=-999;
          EP_negodd=(1./1.)*atan2(Q_NegHFOdd.Im(),Q_NegHFOdd.Re());
          if (EP_negodd>(pi)) EP_negodd=(EP_negodd-(TMath::TwoPi()));
          if (EP_negodd<(-1.0*(pi))) EP_negodd=(EP_negodd+(TMath::TwoPi()));
          PsiNOddRaw[c]->Fill(EP_negodd);

	  //Tracker
	  EP_trodd=-999;
          EP_trodd=(1./1.)*atan2(Q_TROdd.Im(),Q_TROdd.Re());
          if (EP_trodd>(pi)) EP_trodd=(EP_trodd-(TMath::TwoPi()));
          if (EP_trodd<(-1.0*(pi))) EP_trodd=(EP_trodd+(TMath::TwoPi()));
	  PsiTROddRaw[c]->Fill(EP_trodd);
          //Zero the angular correction variables

          //v1 even stuff
          //Whole HF
          AngularCorrectionHFEven=0.;EPfinalhfeven=-999.;
          //Pos HF
          AngularCorrectionHFPEven=0.; EP_finalposeven=-999.;
          //Neg HF
          AngularCorrectionHFNEven=0.; EP_finalnegeven=-999.;
          //Tracker
          AngularCorrectionTREven=0.; EP_finaltreven=-999.;

          //v1 odd stuff
          //Whole HF
          AngularCorrectionHFOdd=0.;EPfinalhfodd=-999.;
          //Pos HF
          AngularCorrectionHFPOdd=0.; EP_finalposodd=-999.;
          //Neg HF
          AngularCorrectionHFNOdd=0.; EP_finalnegodd=-999.;
          //Tracker
          AngularCorrectionTROdd=0.; EP_finaltrodd=-999.;


          if((EPhfeven>-500) && (EPhfodd>-500))
            {
              //Compute Angular Corrections
              for (Int_t k=1;k<(jMax+1);k++)
                {

		  QEP_hfodd[k-1]+=TComplex::Exp(TComplex::I()*k*EPhfodd);//
                  QEP_hfeven[k-1]+=TComplex::Exp(TComplex::I()*k*EPhfeven);
                  QEP_hfpodd[k-1]+=TComplex::Exp(TComplex::I()*k*EP_posodd);//
                  QEP_hfpeven[k-1]+=TComplex::Exp(TComplex::I()*k*EP_poseven);
                  QEP_hfnodd[k-1]+=TComplex::Exp(TComplex::I()*k*EP_negodd);//
                  QEP_hfneven[k-1]+=TComplex::Exp(TComplex::I()*k*EP_negeven);
                  QEP_trodd[k-1]+=TComplex::Exp(TComplex::I()*k*EP_trodd);//
                  QEP_treven[k-1]+=TComplex::Exp(TComplex::I()*k*EP_treven);//


                  //v1 even
                  //Whole HF
                  AngularCorrectionHFEven+=((2./k)*(((-Sinhfeven[c][k-1])*(QEP_hfeven[k-1].Re()))+((Coshfeven[c][k-1])*(QEP_hfeven[k-1].Im()))));
                  PsiEvenCorrs[c]->Fill(k-1,fabs(((2./k)*(((-Sinhfeven[c][k-1])*(QEP_hfeven[k-1].Re()))+((Coshfeven[c][k-1])*(QEP_hfeven[k-1].Im()))))));
                  //Pos HF
                  AngularCorrectionHFPEven+=((2./k)*(((-Sinhfpeven[c][k-1])*(QEP_hfpeven[k-1].Re()))+((Coshfpeven[c][k-1])*(QEP_hfpeven[k-1].Im()))));
                  //Neg HF
		  AngularCorrectionHFNEven+=((2./k)*(((-Sinhfneven[c][k-1])*(QEP_hfneven[k-1].Re()))+((Coshfneven[c][k-1])*(QEP_hfneven[k-1].Im()))));
		  //Tracker
		  AngularCorrectionTREven+=((2./k)*(((-Sintreven[c][k-1])*(QEP_treven[k-1].Re()))+((Costreven[c][k-1])*(QEP_treven[k-1].Im()))));
		  //////////////////////////////////////////////////////
                  //v1 odd
                  //Whole HF
		  AngularCorrectionHFOdd+=((2./k)*(((-Sinhfodd[c][k-1])*(QEP_hfodd[k-1].Re()))+((Coshfodd[c][k-1])*(QEP_hfodd[k-1].Im()))));
		  PsiOddCorrs[c]->Fill(k-1,fabs(((2./k)*(((-Sinhfodd[c][k-1])*(QEP_hfodd[k-1].Re()))+((Coshfodd[c][k-1])*(QEP_hfodd[k-1].Im()))))));
                  //Pos HF
		  AngularCorrectionHFPOdd+=((2./k)*(((-Sinhfpodd[c][k-1])*(QEP_hfpodd[k-1].Re()))+((Coshfpodd[c][k-1])*(QEP_hfpodd[k-1].Im()))));
		  //Neg HF
		  AngularCorrectionHFNOdd+=((2./k)*(((-Sinhfnodd[c][k-1])*(QEP_hfnodd[k-1].Re()))+((Coshfnodd[c][k-1])*(QEP_hfnodd[k-1].Im()))));
		  //Tracker
		  AngularCorrectionTROdd+=((2./k)*(((-Sintrodd[c][k-1])*(QEP_trodd[k-1].Re()))+((Costrodd[c][k-1])*(QEP_trodd[k-1].Im()))));
                }//end of angular correction calculation
            }//prevent bad corrections

          //Add the final Corrections to the Event Plane
          //and store it and do the flow measurement with it


          //v1 even
          //Whole HF
          EPfinalhfeven=EPhfeven+AngularCorrectionHFEven;
          if (EPfinalhfeven>(pi)) EPfinalhfeven=(EPfinalhfeven-(TMath::TwoPi()));
          if (EPfinalhfeven<(-1.0*(pi))) EPfinalhfeven=(EPfinalhfeven+(TMath::TwoPi()));
          if(EPfinalhfeven>-500)
            {
              PsiEvenFinal[c]->Fill(EPfinalhfeven);
            }
          //Pos HF
          EP_finalposeven=EP_poseven+AngularCorrectionHFPEven;
          if (EP_finalposeven>(pi)) EP_finalposeven=(EP_finalposeven-(TMath::TwoPi()));
          if (EP_finalposeven<(-1.0*(pi))) EP_finalposeven=(EP_finalposeven+(TMath::TwoPi()));
          if(EP_finalposeven>-500)
            {
              PsiPEvenFinal[c]->Fill(EP_finalposeven);
            }
          //Neg HF
          EP_finalnegeven=EP_negeven+AngularCorrectionHFNEven;
          if (EP_finalnegeven>(pi)) EP_finalnegeven=(EP_finalnegeven-(TMath::TwoPi()));
          if (EP_finalnegeven<(-1.0*(pi))) EP_finalnegeven=(EP_finalnegeven+(TMath::TwoPi()));
          if(EP_finalnegeven>-500)
            {
              PsiNEvenFinal[c]->Fill(EP_finalnegeven);
            }
          //Tracker
          EP_finaltreven=EP_treven+AngularCorrectionTREven;
          if (EP_finaltreven>(pi)) EP_finaltreven=(EP_finaltreven-(TMath::TwoPi()));
          if (EP_finaltreven<(-1.0*(pi))) EP_finaltreven=(EP_finaltreven+(TMath::TwoPi()));
          if(EP_finaltreven>-500)
            {
              PsiTREvenFinal[c]->Fill(EP_finaltreven);
            }
          //////////////////////////////////////////////////
          //v1 odd
          //Whole HF
          EPfinalhfodd=EPhfodd+AngularCorrectionHFOdd;
          if (EPfinalhfodd>(pi)) EPfinalhfodd=(EPfinalhfodd-(TMath::TwoPi()));
          if (EPfinalhfodd<(-1.0*(pi))) EPfinalhfodd=(EPfinalhfodd+(TMath::TwoPi()));
          if(EPfinalhfodd>-500){
            PsiOddFinal[c]->Fill(EPfinalhfodd);
          }
          //Pos HF
          EP_finalposodd=EP_posodd+AngularCorrectionHFPOdd;
          if (EP_finalposodd>(pi)) EP_finalposodd=(EP_finalposodd-(TMath::TwoPi()));
          if (EP_finalposodd<(-1.0*(pi))) EP_finalposodd=(EP_finalposodd+(TMath::TwoPi()));
          if(EP_finalposodd>-500)
            {
              PsiPOddFinal[c]->Fill(EP_finalposodd);
            }
          //Neg HF
          EP_finalnegodd=EP_negodd+AngularCorrectionHFNOdd;
          if (EP_finalnegodd>(pi)) EP_finalnegodd=(EP_finalnegodd-(TMath::TwoPi()));
          if (EP_finalnegodd<(-1.0*(pi))) EP_finalnegodd=(EP_finalnegodd+(TMath::TwoPi()));
          if(EP_finalnegodd>-500)
            {
              PsiNOddFinal[c]->Fill(EP_finalnegodd);
            }
          //Tracker
          EP_finaltrodd=EP_trodd+AngularCorrectionTROdd;
          if (EP_finaltrodd>(pi)) EP_finaltrodd=(EP_finaltrodd-(TMath::TwoPi()));
          if (EP_finaltrodd<(-1.0*(pi))) EP_finaltrodd=(EP_finaltrodd+(TMath::TwoPi()));
          if(EP_finaltrodd>-500)
            {
              PsiTROddFinal[c]->Fill(EP_finaltrodd);
            }
	  
	  ///////////////////Fill Resolution Plots///////////////////
	  //Even
	  HFPMinusHFMEven->Fill(c,TMath::Cos(EP_finalposeven-EP_finalnegeven));
	  HFPMinusTREven->Fill(c,TMath::Cos(EP_finalposeven-EP_finaltreven));
	  HFMMinusTREven->Fill(c,TMath::Cos(EP_finalnegeven-EP_finaltreven));
	  //Odd
	  HFPMinusHFMOdd->Fill(c,TMath::Cos(EP_finalposodd-EP_finalnegodd));
	  HFPMinusTROdd->Fill(c,TMath::Cos(EP_finalposodd-EP_finaltrodd));
	  HFMMinusTROdd->Fill(c,TMath::Cos(EP_finalnegodd-EP_finaltrodd));
	  
	  //Fill V1 Histograms
          NumberOfHits= NumTracks->GetValue();
          for (Int_t ii=0;ii<NumberOfHits;ii++)
	  {
              pT=0.;
              phi=0.;
              eta=0.;
              pT=TrackMom->GetValue(ii);
              phi=TrackPhi->GetValue(ii);
              eta=TrackEta->GetValue(ii);
              if(pT<0)
                {
                  continue;
                }
              if(fabs(eta)<=1.6 && pT>0.4)
                {
                 Veven=TComplex(0.);
                 Veven=TComplex::Exp(TComplex::I()*(phi-EPfinalhfeven));
                 Double_t v1even= Veven.Re();
                 Vodd=TComplex(0.);
                 Vodd=TComplex::Exp(TComplex::I()*(phi-EPfinalhfodd));
                 Double_t v1odd = Vodd.Re();
		 V1EvenHFP[c]->Fill(eta,TMath::Cos(phi-EP_finalposeven));
		 V1EvenHFM[c]->Fill(eta,TMath::Cos(phi-EP_finalnegeven));
		 V1OddHFM[c]->Fill(eta,TMath::Cos(phi-EP_finalnegodd));
		 V1OddHFP[c]->Fill(eta,TMath::Cos(phi-EP_finalposodd));
		 V1EtaOdd[c]->Fill(eta,v1odd);
		 V1EtaEven[c]->Fill(eta,v1even);
		 V1PtEven[c]->Fill(pT,v1even);
		 PTCenters[c]->Fill(pT,pT);
		 //V1PtOdd[c]->Fill(pT,TMath::Cos(phi-EPfinalhfodd));//can find offset later with removing the eta gate here
                 V1PtOdd[c]->Fill(pT,v1odd);
                }//only central tracks
            }//end of loop over tracks

        }//End of loop over Centralities
    }//End of loop over events
  myFile->Write();
  // delete myFile;
}//end of ep plotting


void FillAngularCorrections(){
//V1 Even
//Whole HF
Coshfeven[0][0]=0.0548686;
Coshfeven[1][0]=0.0405753;
Coshfeven[2][0]=0.0317068;
Coshfeven[3][0]=0.0239244;
Coshfeven[4][0]=0.0175385;
 
Sinhfeven[0][0]=0.15019;
Sinhfeven[1][0]=0.135159;
Sinhfeven[2][0]=0.119095;
Sinhfeven[3][0]=0.104295;
Sinhfeven[4][0]=0.091971;
 
Coshfeven[0][1]=-0.0105593;
Coshfeven[1][1]=-0.010768;
Coshfeven[2][1]=-0.00877292;
Coshfeven[3][1]=-0.0061756;
Coshfeven[4][1]=-0.00537791;
 
Sinhfeven[0][1]=0.00901841;
Sinhfeven[1][1]=0.00559143;
Sinhfeven[2][1]=0.00388854;
Sinhfeven[3][1]=0.00184982;
Sinhfeven[4][1]=0.000730828;
 
Coshfeven[0][2]=-0.000410356;
Coshfeven[1][2]=-9.95369e-05;
Coshfeven[2][2]=0.000821012;
Coshfeven[3][2]=-0.000498559;
Coshfeven[4][2]=-9.51809e-05;
 
Sinhfeven[0][2]=-0.00155132;
Sinhfeven[1][2]=-0.00271876;
Sinhfeven[2][2]=0.000763927;
Sinhfeven[3][2]=-0.000278258;
Sinhfeven[4][2]=-0.00132797;
 
Coshfeven[0][3]=-0.000560563;
Coshfeven[1][3]=0.000551806;
Coshfeven[2][3]=0.000813455;
Coshfeven[3][3]=0.000258592;
Coshfeven[4][3]=-0.000451757;
 
Sinhfeven[0][3]=-0.000198882;
Sinhfeven[1][3]=7.42586e-05;
Sinhfeven[2][3]=0.00116994;
Sinhfeven[3][3]=-0.000379497;
Sinhfeven[4][3]=-0.000345594;
 
Coshfeven[0][4]=0.000123728;
Coshfeven[1][4]=0.00026034;
Coshfeven[2][4]=-0.000947184;
Coshfeven[3][4]=0.000836602;
Coshfeven[4][4]=0.000664359;
 
Sinhfeven[0][4]=-0.000407307;
Sinhfeven[1][4]=-0.000975503;
Sinhfeven[2][4]=0.000108613;
Sinhfeven[3][4]=0.000871162;
Sinhfeven[4][4]=0.000380108;
 
Coshfeven[0][5]=0.000284839;
Coshfeven[1][5]=-0.000322499;
Coshfeven[2][5]=0.000458216;
Coshfeven[3][5]=0.000286004;
Coshfeven[4][5]=0.000699773;
 
Sinhfeven[0][5]=-0.000402149;
Sinhfeven[1][5]=-0.00132897;
Sinhfeven[2][5]=0.000524622;
Sinhfeven[3][5]=0.00108778;
Sinhfeven[4][5]=4.08778e-05;
 
Coshfeven[0][6]=-0.000978497;
Coshfeven[1][6]=0.00197573;
Coshfeven[2][6]=0.00141235;
Coshfeven[3][6]=0.000609991;
Coshfeven[4][6]=1.11063e-06;
 
Sinhfeven[0][6]=-0.000139221;
Sinhfeven[1][6]=8.25294e-05;
Sinhfeven[2][6]=-0.00054412;
Sinhfeven[3][6]=0.00133299;
Sinhfeven[4][6]=-0.000937338;
 
Coshfeven[0][7]=-0.000160337;
Coshfeven[1][7]=-0.00028034;
Coshfeven[2][7]=0.000373337;
Coshfeven[3][7]=0.00112113;
Coshfeven[4][7]=-0.000159531;
 
Sinhfeven[0][7]=0.00034723;
Sinhfeven[1][7]=0.00197682;
Sinhfeven[2][7]=-0.00015998;
Sinhfeven[3][7]=-0.00111375;
Sinhfeven[4][7]=-0.00182894;
 
Coshfeven[0][8]=0.00018943;
Coshfeven[1][8]=-0.000664604;
Coshfeven[2][8]=0.000579519;
Coshfeven[3][8]=0.00115721;
Coshfeven[4][8]=0.000868621;
 
Sinhfeven[0][8]=0.000714596;
Sinhfeven[1][8]=-0.000418421;
Sinhfeven[2][8]=-0.000225503;
Sinhfeven[3][8]=0.000422161;
Sinhfeven[4][8]=-0.000346516;
 
Coshfeven[0][9]=0.000153942;
Coshfeven[1][9]=0.00105151;
Coshfeven[2][9]=0.00100992;
Coshfeven[3][9]=0.000600953;
Coshfeven[4][9]=-0.000607087;
 
Sinhfeven[0][9]=-0.000245213;
Sinhfeven[1][9]=0.00101428;
Sinhfeven[2][9]=0.000848805;
Sinhfeven[3][9]=-0.000262619;
Sinhfeven[4][9]=0.000326715;
 
 
//Pos HF
Coshfpeven[0][0]=0.211314;
Coshfpeven[1][0]=0.174177;
Coshfpeven[2][0]=0.144249;
Coshfpeven[3][0]=0.115908;
Coshfpeven[4][0]=0.0930134;
 
Sinhfpeven[0][0]=0.187436;
Sinhfpeven[1][0]=0.163774;
Sinhfpeven[2][0]=0.140886;
Sinhfpeven[3][0]=0.119966;
Sinhfpeven[4][0]=0.102252;
 
Coshfpeven[0][1]=0.00827523;
Coshfpeven[1][1]=0.00346349;
Coshfpeven[2][1]=0.00199434;
Coshfpeven[3][1]=-0.0002839;
Coshfpeven[4][1]=-0.00150858;
 
Sinhfpeven[0][1]=0.0489457;
Sinhfpeven[1][1]=0.0367092;
Sinhfpeven[2][1]=0.0247474;
Sinhfpeven[3][1]=0.0158639;
Sinhfpeven[4][1]=0.00980521;
 
Coshfpeven[0][2]=-0.00307317;
Coshfpeven[1][2]=-0.00217467;
Coshfpeven[2][2]=-9.73683e-05;
Coshfpeven[3][2]=0.000926677;
Coshfpeven[4][2]=0.0006759;
 
Sinhfpeven[0][2]=0.00551217;
Sinhfpeven[1][2]=0.00394088;
Sinhfpeven[2][2]=0.00270071;
Sinhfpeven[3][2]=0.000356355;
Sinhfpeven[4][2]=0.000346394;
 
Coshfpeven[0][3]=-0.00112294;
Coshfpeven[1][3]=-0.000576354;
Coshfpeven[2][3]=8.05764e-05;
Coshfpeven[3][3]=-0.000258083;
Coshfpeven[4][3]=-0.000569882;
 
Sinhfpeven[0][3]=-2.20752e-05;
Sinhfpeven[1][3]=-0.000993295;
Sinhfpeven[2][3]=-1.01016e-05;
Sinhfpeven[3][3]=0.000436679;
Sinhfpeven[4][3]=0.000588912;
 
Coshfpeven[0][4]=-0.00185923;
Coshfpeven[1][4]=-0.000620384;
Coshfpeven[2][4]=-0.000308041;
Coshfpeven[3][4]=-0.000153693;
Coshfpeven[4][4]=-4.26736e-05;
 
Sinhfpeven[0][4]=0.000202882;
Sinhfpeven[1][4]=-1.56752e-05;
Sinhfpeven[2][4]=-0.000349277;
Sinhfpeven[3][4]=-0.000419399;
Sinhfpeven[4][4]=-0.000498944;
 
Coshfpeven[0][5]=-0.000588031;
Coshfpeven[1][5]=-0.000445819;
Coshfpeven[2][5]=-0.000694237;
Coshfpeven[3][5]=-0.000129472;
Coshfpeven[4][5]=0.000191705;
 
Sinhfpeven[0][5]=-0.000143425;
Sinhfpeven[1][5]=-0.00126898;
Sinhfpeven[2][5]=-0.00124232;
Sinhfpeven[3][5]=-0.00104103;
Sinhfpeven[4][5]=-0.000321715;
 
Coshfpeven[0][6]=-0.000747981;
Coshfpeven[1][6]=-0.000322662;
Coshfpeven[2][6]=-0.0003523;
Coshfpeven[3][6]=0.00120537;
Coshfpeven[4][6]=0.00116943;
 
Sinhfpeven[0][6]=-0.000146285;
Sinhfpeven[1][6]=-0.000526237;
Sinhfpeven[2][6]=-0.000710654;
Sinhfpeven[3][6]=-0.00056922;
Sinhfpeven[4][6]=0.000860305;
 
Coshfpeven[0][7]=1.30333e-05;
Coshfpeven[1][7]=-0.000574761;
Coshfpeven[2][7]=0.000866161;
Coshfpeven[3][7]=0.000647918;
Coshfpeven[4][7]=0.000755211;
 
Sinhfpeven[0][7]=-0.000788513;
Sinhfpeven[1][7]=-0.000649986;
Sinhfpeven[2][7]=0.000215666;
Sinhfpeven[3][7]=-0.000106754;
Sinhfpeven[4][7]=-0.000974752;
 
Coshfpeven[0][8]=0.00044673;
Coshfpeven[1][8]=0.000553999;
Coshfpeven[2][8]=-5.53844e-05;
Coshfpeven[3][8]=0.000768013;
Coshfpeven[4][8]=0.00128607;
 
Sinhfpeven[0][8]=-0.000641856;
Sinhfpeven[1][8]=0.000325097;
Sinhfpeven[2][8]=-3.85279e-05;
Sinhfpeven[3][8]=-0.000283828;
Sinhfpeven[4][8]=0.000497363;
 
Coshfpeven[0][9]=-0.000373811;
Coshfpeven[1][9]=-0.000414764;
Coshfpeven[2][9]=-0.00094499;
Coshfpeven[3][9]=0.000249229;
Coshfpeven[4][9]=-0.000115688;
 
Sinhfpeven[0][9]=-0.000118422;
Sinhfpeven[1][9]=0.000232653;
Sinhfpeven[2][9]=0.000302499;
Sinhfpeven[3][9]=-5.80764e-05;
Sinhfpeven[4][9]=-0.000310238;
 
 
//Neg HF
Coshfneven[0][0]=-0.143198;
Coshfneven[1][0]=-0.123435;
Coshfneven[2][0]=-0.104174;
Coshfneven[3][0]=-0.0868202;
Coshfneven[4][0]=-0.0713904;
 
Sinhfneven[0][0]=0.0134187;
Sinhfneven[1][0]=0.0176279;
Sinhfneven[2][0]=0.0209195;
Sinhfneven[3][0]=0.0219885;
Sinhfneven[4][0]=0.0230039;
 
Coshfneven[0][1]=0.0115229;
Coshfneven[1][1]=0.00766144;
Coshfneven[2][1]=0.00540734;
Coshfneven[3][1]=0.00426428;
Coshfneven[4][1]=0.00204709;
 
Sinhfneven[0][1]=-0.00467142;
Sinhfneven[1][1]=-0.00373388;
Sinhfneven[2][1]=-0.00333549;
Sinhfneven[3][1]=-0.00232355;
Sinhfneven[4][1]=-0.00285057;
 
Coshfneven[0][2]=-0.000100862;
Coshfneven[1][2]=0.000183643;
Coshfneven[2][2]=1.15433e-05;
Coshfneven[3][2]=-0.000912898;
Coshfneven[4][2]=-0.000196662;
 
Sinhfneven[0][2]=0.000364584;
Sinhfneven[1][2]=0.00130993;
Sinhfneven[2][2]=0.00161429;
Sinhfneven[3][2]=0.000208578;
Sinhfneven[4][2]=-0.00145948;
 
Coshfneven[0][3]=0.00031335;
Coshfneven[1][3]=0.00110755;
Coshfneven[2][3]=-0.000392825;
Coshfneven[3][3]=0.000213687;
Coshfneven[4][3]=0.000101033;
 
Sinhfneven[0][3]=-0.000344654;
Sinhfneven[1][3]=0.00057043;
Sinhfneven[2][3]=-0.000522327;
Sinhfneven[3][3]=0.000124599;
Sinhfneven[4][3]=0.000482713;
 
Coshfneven[0][4]=0.00151621;
Coshfneven[1][4]=-0.000449274;
Coshfneven[2][4]=-0.000638674;
Coshfneven[3][4]=-0.00042531;
Coshfneven[4][4]=-0.000651039;
 
Sinhfneven[0][4]=0.000679453;
Sinhfneven[1][4]=-0.00129754;
Sinhfneven[2][4]=-0.000541677;
Sinhfneven[3][4]=-0.000828517;
Sinhfneven[4][4]=3.21972e-05;
 
Coshfneven[0][5]=3.94025e-05;
Coshfneven[1][5]=2.4386e-05;
Coshfneven[2][5]=-0.000395581;
Coshfneven[3][5]=-1.73944e-05;
Coshfneven[4][5]=-0.000320274;
 
Sinhfneven[0][5]=-0.000343615;
Sinhfneven[1][5]=0.00204929;
Sinhfneven[2][5]=0.000830729;
Sinhfneven[3][5]=0.00021198;
Sinhfneven[4][5]=-0.000273911;
 
Coshfneven[0][6]=0.00102235;
Coshfneven[1][6]=0.000358564;
Coshfneven[2][6]=0.000934868;
Coshfneven[3][6]=-6.90358e-05;
Coshfneven[4][6]=-0.000212332;
 
Sinhfneven[0][6]=-0.000491109;
Sinhfneven[1][6]=0.000668177;
Sinhfneven[2][6]=0.000810249;
Sinhfneven[3][6]=-1.68002e-05;
Sinhfneven[4][6]=-0.00097954;
 
Coshfneven[0][7]=0.000461715;
Coshfneven[1][7]=-2.52381e-05;
Coshfneven[2][7]=0.000638766;
Coshfneven[3][7]=0.000132272;
Coshfneven[4][7]=0.000201984;
 
Sinhfneven[0][7]=-0.000614767;
Sinhfneven[1][7]=-0.000725353;
Sinhfneven[2][7]=-0.000363348;
Sinhfneven[3][7]=0.000229585;
Sinhfneven[4][7]=0.000680409;
 
Coshfneven[0][8]=0.000468758;
Coshfneven[1][8]=0.000261693;
Coshfneven[2][8]=0.00015467;
Coshfneven[3][8]=-0.000902;
Coshfneven[4][8]=0.000648467;
 
Sinhfneven[0][8]=0.000139925;
Sinhfneven[1][8]=-9.78906e-05;
Sinhfneven[2][8]=0.000237523;
Sinhfneven[3][8]=0.000911585;
Sinhfneven[4][8]=0.000165213;
 
Coshfneven[0][9]=-0.000688688;
Coshfneven[1][9]=-0.000788666;
Coshfneven[2][9]=0.000501067;
Coshfneven[3][9]=-0.000490159;
Coshfneven[4][9]=-0.000371844;
 
Sinhfneven[0][9]=-6.71156e-05;
Sinhfneven[1][9]=0.00112134;
Sinhfneven[2][9]=-0.000172883;
Sinhfneven[3][9]=0.000985206;
Sinhfneven[4][9]=0.000675578;
 
 
//Mid Tracker
Costreven[0][0]=-0.20825;
Costreven[1][0]=-0.176583;
Costreven[2][0]=-0.150388;
Costreven[3][0]=-0.126988;
Costreven[4][0]=-0.105439;
 
Sintreven[0][0]=-0.159337;
Sintreven[1][0]=-0.136312;
Sintreven[2][0]=-0.118431;
Sintreven[3][0]=-0.101143;
Sintreven[4][0]=-0.0859798;
 
Costreven[0][1]=-0.0141138;
Costreven[1][1]=-0.00899877;
Costreven[2][1]=-0.00351821;
Costreven[3][1]=0.0010162;
Costreven[4][1]=0.00379571;
 
Sintreven[0][1]=0.023318;
Sintreven[1][1]=0.0159589;
Sintreven[2][1]=0.0126419;
Sintreven[3][1]=0.00867991;
Sintreven[4][1]=0.0059459;
 
Costreven[0][2]=-2.29015e-05;
Costreven[1][2]=-3.77933e-05;
Costreven[2][2]=-0.000640559;
Costreven[3][2]=-0.000736818;
Costreven[4][2]=-0.00216424;
 
Sintreven[0][2]=0.00968447;
Sintreven[1][2]=0.0063096;
Sintreven[2][2]=0.00175667;
Sintreven[3][2]=0.000711568;
Sintreven[4][2]=-0.000847328;
 
Costreven[0][3]=0.00222991;
Costreven[1][3]=0.000387663;
Costreven[2][3]=0.00135841;
Costreven[3][3]=-0.00151504;
Costreven[4][3]=-0.000234532;
 
Sintreven[0][3]=-0.00108274;
Sintreven[1][3]=-0.00238658;
Sintreven[2][3]=-0.000376377;
Sintreven[3][3]=-6.48129e-05;
Sintreven[4][3]=0.00117754;
 
Costreven[0][4]=0.000344691;
Costreven[1][4]=-0.000544638;
Costreven[2][4]=0.000113045;
Costreven[3][4]=0.000695273;
Costreven[4][4]=0.000243084;
 
Sintreven[0][4]=0.000201141;
Sintreven[1][4]=0.000131866;
Sintreven[2][4]=0.000426809;
Sintreven[3][4]=0.000787477;
Sintreven[4][4]=-6.75829e-06;
 
Costreven[0][5]=-0.000601916;
Costreven[1][5]=-0.000109343;
Costreven[2][5]=0.000158757;
Costreven[3][5]=0.000285774;
Costreven[4][5]=-0.000261559;
 
Sintreven[0][5]=-0.000368149;
Sintreven[1][5]=-0.000101957;
Sintreven[2][5]=0.00096456;
Sintreven[3][5]=-0.000539145;
Sintreven[4][5]=-0.000113789;
 
Costreven[0][6]=0.00057626;
Costreven[1][6]=-3.58968e-05;
Costreven[2][6]=0.000694967;
Costreven[3][6]=0.000693444;
Costreven[4][6]=-0.000152072;
 
Sintreven[0][6]=-0.000106519;
Sintreven[1][6]=-0.000706488;
Sintreven[2][6]=0.000474184;
Sintreven[3][6]=0.000281586;
Sintreven[4][6]=0.00026653;
 
Costreven[0][7]=-0.0010435;
Costreven[1][7]=-0.000735556;
Costreven[2][7]=0.000283955;
Costreven[3][7]=-0.000256177;
Costreven[4][7]=-0.000838547;
 
Sintreven[0][7]=0.000931744;
Sintreven[1][7]=0.000183465;
Sintreven[2][7]=-0.000171618;
Sintreven[3][7]=-0.000102227;
Sintreven[4][7]=-0.000199835;
 
Costreven[0][8]=0.000545669;
Costreven[1][8]=-0.000434435;
Costreven[2][8]=-0.00149767;
Costreven[3][8]=0.000356768;
Costreven[4][8]=0.000940757;
 
Sintreven[0][8]=-0.000580602;
Sintreven[1][8]=0.000284366;
Sintreven[2][8]=0.000107948;
Sintreven[3][8]=-0.000584761;
Sintreven[4][8]=-0.000801342;
 
Costreven[0][9]=0.000396074;
Costreven[1][9]=-0.00036082;
Costreven[2][9]=0.000179061;
Costreven[3][9]=9.01411e-05;
Costreven[4][9]=-0.0022492;
 
Sintreven[0][9]=-0.000517139;
Sintreven[1][9]=-0.000700518;
Sintreven[2][9]=0.000318631;
Sintreven[3][9]=-8.68996e-06;
Sintreven[4][9]=-0.000521713;
 
//V1 Odd
//Whole HF
Coshfodd[0][0]=0.241866;
Coshfodd[1][0]=0.202747;
Coshfodd[2][0]=0.169055;
Coshfodd[3][0]=0.138408;
Coshfodd[4][0]=0.112647;
 
Sinhfodd[0][0]=0.119952;
Sinhfodd[1][0]=0.101232;
Sinhfodd[2][0]=0.082487;
Sinhfodd[3][0]=0.0676877;
Sinhfodd[4][0]=0.0550184;
 
Coshfodd[0][1]=0.0269233;
Coshfodd[1][1]=0.0188551;
Coshfodd[2][1]=0.0136162;
Coshfodd[3][1]=0.00934447;
Coshfodd[4][1]=0.00565798;
 
Sinhfodd[0][1]=0.0340819;
Sinhfodd[1][1]=0.0261058;
Sinhfodd[2][1]=0.0162709;
Sinhfodd[3][1]=0.0113046;
Sinhfodd[4][1]=0.00630529;
 
Coshfodd[0][2]=0.00229652;
Coshfodd[1][2]=0.00110772;
Coshfodd[2][2]=-0.000618083;
Coshfodd[3][2]=0.00145698;
Coshfodd[4][2]=-0.000390175;
 
Sinhfodd[0][2]=0.00510491;
Sinhfodd[1][2]=0.00452504;
Sinhfodd[2][2]=0.00184456;
Sinhfodd[3][2]=0.00186203;
Sinhfodd[4][2]=0.000874942;
 
Coshfodd[0][3]=0.000103322;
Coshfodd[1][3]=0.000551487;
Coshfodd[2][3]=-0.000652718;
Coshfodd[3][3]=-0.000210454;
Coshfodd[4][3]=-0.00119413;
 
Sinhfodd[0][3]=0.000957275;
Sinhfodd[1][3]=0.000467346;
Sinhfodd[2][3]=0.00120036;
Sinhfodd[3][3]=0.000746437;
Sinhfodd[4][3]=0.000864534;
 
Coshfodd[0][4]=0.00044445;
Coshfodd[1][4]=-0.000329128;
Coshfodd[2][4]=-0.000655323;
Coshfodd[3][4]=0.000134354;
Coshfodd[4][4]=1.38684e-05;
 
Sinhfodd[0][4]=0.00126439;
Sinhfodd[1][4]=0.000681026;
Sinhfodd[2][4]=0.000199234;
Sinhfodd[3][4]=-0.000317218;
Sinhfodd[4][4]=-0.000772599;
 
Coshfodd[0][5]=0.000464758;
Coshfodd[1][5]=-0.000500605;
Coshfodd[2][5]=-0.000760076;
Coshfodd[3][5]=0.000962935;
Coshfodd[4][5]=-0.000305787;
 
Sinhfodd[0][5]=0.000768802;
Sinhfodd[1][5]=-0.000389673;
Sinhfodd[2][5]=-0.000213781;
Sinhfodd[3][5]=-0.00153946;
Sinhfodd[4][5]=-0.00122155;
 
Coshfodd[0][6]=4.53566e-05;
Coshfodd[1][6]=-0.00116642;
Coshfodd[2][6]=-0.000674428;
Coshfodd[3][6]=-0.000437427;
Coshfodd[4][6]=0.000174066;
 
Sinhfodd[0][6]=0.000112053;
Sinhfodd[1][6]=-0.000183671;
Sinhfodd[2][6]=-0.000296214;
Sinhfodd[3][6]=5.31107e-05;
Sinhfodd[4][6]=0.000536787;
 
Coshfodd[0][7]=-0.000283515;
Coshfodd[1][7]=0.000173745;
Coshfodd[2][7]=-0.000171542;
Coshfodd[3][7]=-1.07999e-05;
Coshfodd[4][7]=-0.000781289;
 
Sinhfodd[0][7]=0.000180507;
Sinhfodd[1][7]=0.000408296;
Sinhfodd[2][7]=0.000265325;
Sinhfodd[3][7]=-0.000459579;
Sinhfodd[4][7]=0.00147021;
 
Coshfodd[0][8]=0.000673193;
Coshfodd[1][8]=0.000231487;
Coshfodd[2][8]=0.00023379;
Coshfodd[3][8]=0.00142865;
Coshfodd[4][8]=1.54883e-05;
 
Sinhfodd[0][8]=-0.000302404;
Sinhfodd[1][8]=0.000625726;
Sinhfodd[2][8]=0.000245395;
Sinhfodd[3][8]=0.000217673;
Sinhfodd[4][8]=0.000920658;
 
Coshfodd[0][9]=0.000479913;
Coshfodd[1][9]=-0.000163212;
Coshfodd[2][9]=0.000249142;
Coshfodd[3][9]=0.000205497;
Coshfodd[4][9]=0.000113472;
 
Sinhfodd[0][9]=8.44075e-05;
Sinhfodd[1][9]=0.000212998;
Sinhfodd[2][9]=0.000615293;
Sinhfodd[3][9]=-0.000785324;
Sinhfodd[4][9]=0.00125246;
 
 
//Pos HF
Coshfpodd[0][0]=0.211314;
Coshfpodd[1][0]=0.174177;
Coshfpodd[2][0]=0.144249;
Coshfpodd[3][0]=0.115908;
Coshfpodd[4][0]=0.0930134;
 
Sinhfpodd[0][0]=0.187436;
Sinhfpodd[1][0]=0.163774;
Sinhfpodd[2][0]=0.140886;
Sinhfpodd[3][0]=0.119966;
Sinhfpodd[4][0]=0.102252;
 
Coshfpodd[0][1]=0.00827523;
Coshfpodd[1][1]=0.00346349;
Coshfpodd[2][1]=0.00199434;
Coshfpodd[3][1]=-0.0002839;
Coshfpodd[4][1]=-0.00150858;
 
Sinhfpodd[0][1]=0.0489457;
Sinhfpodd[1][1]=0.0367092;
Sinhfpodd[2][1]=0.0247474;
Sinhfpodd[3][1]=0.0158639;
Sinhfpodd[4][1]=0.00980521;
 
Coshfpodd[0][2]=-0.00307317;
Coshfpodd[1][2]=-0.00217467;
Coshfpodd[2][2]=-9.73683e-05;
Coshfpodd[3][2]=0.000926677;
Coshfpodd[4][2]=0.0006759;
 
Sinhfpodd[0][2]=0.00551217;
Sinhfpodd[1][2]=0.00394088;
Sinhfpodd[2][2]=0.00270071;
Sinhfpodd[3][2]=0.000356355;
Sinhfpodd[4][2]=0.000346394;
 
Coshfpodd[0][3]=-0.00112294;
Coshfpodd[1][3]=-0.000576354;
Coshfpodd[2][3]=8.05764e-05;
Coshfpodd[3][3]=-0.000258083;
Coshfpodd[4][3]=-0.000569882;
 
Sinhfpodd[0][3]=-2.20752e-05;
Sinhfpodd[1][3]=-0.000993295;
Sinhfpodd[2][3]=-1.01016e-05;
Sinhfpodd[3][3]=0.000436679;
Sinhfpodd[4][3]=0.000588912;
 
Coshfpodd[0][4]=-0.00185923;
Coshfpodd[1][4]=-0.000620384;
Coshfpodd[2][4]=-0.000308041;
Coshfpodd[3][4]=-0.000153693;
Coshfpodd[4][4]=-4.26736e-05;
 
Sinhfpodd[0][4]=0.000202882;
Sinhfpodd[1][4]=-1.56752e-05;
Sinhfpodd[2][4]=-0.000349277;
Sinhfpodd[3][4]=-0.000419399;
Sinhfpodd[4][4]=-0.000498944;
 
Coshfpodd[0][5]=-0.000588031;
Coshfpodd[1][5]=-0.000445819;
Coshfpodd[2][5]=-0.000694237;
Coshfpodd[3][5]=-0.000129472;
Coshfpodd[4][5]=0.000191705;
 
Sinhfpodd[0][5]=-0.000143425;
Sinhfpodd[1][5]=-0.00126898;
Sinhfpodd[2][5]=-0.00124232;
Sinhfpodd[3][5]=-0.00104103;
Sinhfpodd[4][5]=-0.000321715;
 
Coshfpodd[0][6]=-0.000747981;
Coshfpodd[1][6]=-0.000322662;
Coshfpodd[2][6]=-0.0003523;
Coshfpodd[3][6]=0.00120537;
Coshfpodd[4][6]=0.00116943;
 
Sinhfpodd[0][6]=-0.000146285;
Sinhfpodd[1][6]=-0.000526237;
Sinhfpodd[2][6]=-0.000710654;
Sinhfpodd[3][6]=-0.00056922;
Sinhfpodd[4][6]=0.000860305;
 
Coshfpodd[0][7]=1.30333e-05;
Coshfpodd[1][7]=-0.000574761;
Coshfpodd[2][7]=0.000866161;
Coshfpodd[3][7]=0.000647918;
Coshfpodd[4][7]=0.000755211;
 
Sinhfpodd[0][7]=-0.000788513;
Sinhfpodd[1][7]=-0.000649986;
Sinhfpodd[2][7]=0.000215666;
Sinhfpodd[3][7]=-0.000106754;
Sinhfpodd[4][7]=-0.000974752;
 
Coshfpodd[0][8]=0.00044673;
Coshfpodd[1][8]=0.000553999;
Coshfpodd[2][8]=-5.53844e-05;
Coshfpodd[3][8]=0.000768013;
Coshfpodd[4][8]=0.00128607;
 
Sinhfpodd[0][8]=-0.000641856;
Sinhfpodd[1][8]=0.000325097;
Sinhfpodd[2][8]=-3.85279e-05;
Sinhfpodd[3][8]=-0.000283828;
Sinhfpodd[4][8]=0.000497363;
 
Coshfpodd[0][9]=-0.000373811;
Coshfpodd[1][9]=-0.000414764;
Coshfpodd[2][9]=-0.00094499;
Coshfpodd[3][9]=0.000249229;
Coshfpodd[4][9]=-0.000115688;
 
Sinhfpodd[0][9]=-0.000118422;
Sinhfpodd[1][9]=0.000232653;
Sinhfpodd[2][9]=0.000302499;
Sinhfpodd[3][9]=-5.80764e-05;
Sinhfpodd[4][9]=-0.000310238;
 
 
//Neg HF
Coshfnodd[0][0]=0.143198;
Coshfnodd[1][0]=0.123435;
Coshfnodd[2][0]=0.104174;
Coshfnodd[3][0]=0.0868202;
Coshfnodd[4][0]=0.0713904;
 
Sinhfnodd[0][0]=-0.0134187;
Sinhfnodd[1][0]=-0.0176279;
Sinhfnodd[2][0]=-0.0209195;
Sinhfnodd[3][0]=-0.0219885;
Sinhfnodd[4][0]=-0.0230039;
 
Coshfnodd[0][1]=0.0115229;
Coshfnodd[1][1]=0.00766144;
Coshfnodd[2][1]=0.00540734;
Coshfnodd[3][1]=0.00426428;
Coshfnodd[4][1]=0.00204709;
 
Sinhfnodd[0][1]=-0.00467142;
Sinhfnodd[1][1]=-0.00373388;
Sinhfnodd[2][1]=-0.00333549;
Sinhfnodd[3][1]=-0.00232355;
Sinhfnodd[4][1]=-0.00285057;
 
Coshfnodd[0][2]=0.000100862;
Coshfnodd[1][2]=-0.000183643;
Coshfnodd[2][2]=-1.15435e-05;
Coshfnodd[3][2]=0.000912898;
Coshfnodd[4][2]=0.000196662;
 
Sinhfnodd[0][2]=-0.000364584;
Sinhfnodd[1][2]=-0.00130993;
Sinhfnodd[2][2]=-0.00161429;
Sinhfnodd[3][2]=-0.000208578;
Sinhfnodd[4][2]=0.00145948;
 
Coshfnodd[0][3]=0.00031335;
Coshfnodd[1][3]=0.00110755;
Coshfnodd[2][3]=-0.000392825;
Coshfnodd[3][3]=0.000213687;
Coshfnodd[4][3]=0.000101033;
 
Sinhfnodd[0][3]=-0.000344655;
Sinhfnodd[1][3]=0.00057043;
Sinhfnodd[2][3]=-0.000522327;
Sinhfnodd[3][3]=0.000124599;
Sinhfnodd[4][3]=0.000482713;
 
Coshfnodd[0][4]=-0.00151621;
Coshfnodd[1][4]=0.000449275;
Coshfnodd[2][4]=0.000638674;
Coshfnodd[3][4]=0.000425311;
Coshfnodd[4][4]=0.00065104;
 
Sinhfnodd[0][4]=-0.000679454;
Sinhfnodd[1][4]=0.00129754;
Sinhfnodd[2][4]=0.000541677;
Sinhfnodd[3][4]=0.000828516;
Sinhfnodd[4][4]=-3.21968e-05;
 
Coshfnodd[0][5]=3.94024e-05;
Coshfnodd[1][5]=2.4386e-05;
Coshfnodd[2][5]=-0.00039558;
Coshfnodd[3][5]=-1.73944e-05;
Coshfnodd[4][5]=-0.000320274;
 
Sinhfnodd[0][5]=-0.000343615;
Sinhfnodd[1][5]=0.00204929;
Sinhfnodd[2][5]=0.000830729;
Sinhfnodd[3][5]=0.00021198;
Sinhfnodd[4][5]=-0.000273911;
 
Coshfnodd[0][6]=-0.00102235;
Coshfnodd[1][6]=-0.000358564;
Coshfnodd[2][6]=-0.000934868;
Coshfnodd[3][6]=6.90355e-05;
Coshfnodd[4][6]=0.000212332;
 
Sinhfnodd[0][6]=0.000491109;
Sinhfnodd[1][6]=-0.000668178;
Sinhfnodd[2][6]=-0.000810249;
Sinhfnodd[3][6]=1.68002e-05;
Sinhfnodd[4][6]=0.000979539;
 
Coshfnodd[0][7]=0.000461715;
Coshfnodd[1][7]=-2.52382e-05;
Coshfnodd[2][7]=0.000638766;
Coshfnodd[3][7]=0.000132271;
Coshfnodd[4][7]=0.000201985;
 
Sinhfnodd[0][7]=-0.000614767;
Sinhfnodd[1][7]=-0.000725354;
Sinhfnodd[2][7]=-0.000363347;
Sinhfnodd[3][7]=0.000229585;
Sinhfnodd[4][7]=0.000680409;
 
Coshfnodd[0][8]=-0.000468759;
Coshfnodd[1][8]=-0.000261694;
Coshfnodd[2][8]=-0.00015467;
Coshfnodd[3][8]=0.000902;
Coshfnodd[4][8]=-0.000648467;
 
Sinhfnodd[0][8]=-0.000139925;
Sinhfnodd[1][8]=9.78905e-05;
Sinhfnodd[2][8]=-0.000237522;
Sinhfnodd[3][8]=-0.000911584;
Sinhfnodd[4][8]=-0.000165213;
 
Coshfnodd[0][9]=-0.000688687;
Coshfnodd[1][9]=-0.000788665;
Coshfnodd[2][9]=0.000501068;
Coshfnodd[3][9]=-0.000490159;
Coshfnodd[4][9]=-0.000371843;
 
Sinhfnodd[0][9]=-6.7115e-05;
Sinhfnodd[1][9]=0.00112134;
Sinhfnodd[2][9]=-0.000172883;
Sinhfnodd[3][9]=0.000985205;
Sinhfnodd[4][9]=0.000675578;
 
 
//Mid Tracker
Costrodd[0][0]=0.00051371;
Costrodd[1][0]=0.00373764;
Costrodd[2][0]=0.00349983;
Costrodd[3][0]=0.00356028;
Costrodd[4][0]=0.00318654;
 
Sintrodd[0][0]=-0.12502;
Sintrodd[1][0]=-0.105935;
Sintrodd[2][0]=-0.0883446;
Sintrodd[3][0]=-0.0718185;
Sintrodd[4][0]=-0.0580632;
 
Costrodd[0][1]=-0.0115279;
Costrodd[1][1]=-0.00588545;
Costrodd[2][1]=-0.000996934;
Costrodd[3][1]=0.00237565;
Costrodd[4][1]=0.00366513;
 
Sintrodd[0][1]=-0.0295677;
Sintrodd[1][1]=-0.0217771;
Sintrodd[2][1]=-0.0169092;
Sintrodd[3][1]=-0.0117475;
Sintrodd[4][1]=-0.00901538;
 
Costrodd[0][2]=-0.00777486;
Costrodd[1][2]=-0.00635934;
Costrodd[2][2]=-0.00353239;
Costrodd[3][2]=-0.00264597;
Costrodd[4][2]=0.00103704;
 
Sintrodd[0][2]=-0.00489782;
Sintrodd[1][2]=-0.00379356;
Sintrodd[2][2]=-0.00258162;
Sintrodd[3][2]=-0.00125675;
Sintrodd[4][2]=-0.00138379;
 
Costrodd[0][3]=-0.001632;
Costrodd[1][3]=-0.00111506;
Costrodd[2][3]=-0.000423455;
Costrodd[3][3]=0.000211307;
Costrodd[4][3]=-0.00110733;
 
Sintrodd[0][3]=0.00131081;
Sintrodd[1][3]=0.0018158;
Sintrodd[2][3]=7.59279e-05;
Sintrodd[3][3]=0.000994401;
Sintrodd[4][3]=-0.000936797;
 
Costrodd[0][4]=-0.00157498;
Costrodd[1][4]=-0.000357811;
Costrodd[2][4]=-7.3098e-05;
Costrodd[3][4]=-9.85033e-05;
Costrodd[4][4]=-0.000208517;
 
Sintrodd[0][4]=0.000217473;
Sintrodd[1][4]=-0.000246886;
Sintrodd[2][4]=0.000635205;
Sintrodd[3][4]=-0.000489905;
Sintrodd[4][4]=0.000471789;
 
Costrodd[0][5]=0.00136649;
Costrodd[1][5]=-0.000886338;
Costrodd[2][5]=0.000481151;
Costrodd[3][5]=-0.000669583;
Costrodd[4][5]=0.00119391;
 
Sintrodd[0][5]=0.00060679;
Sintrodd[1][5]=-2.45429e-05;
Sintrodd[2][5]=0.000418563;
Sintrodd[3][5]=0.000997473;
Sintrodd[4][5]=-0.000107828;
 
Costrodd[0][6]=-0.000518161;
Costrodd[1][6]=-0.00171814;
Costrodd[2][6]=0.000288434;
Costrodd[3][6]=0.000418945;
Costrodd[4][6]=-0.000357328;
 
Sintrodd[0][6]=0.000532354;
Sintrodd[1][6]=0.000870866;
Sintrodd[2][6]=0.00169355;
Sintrodd[3][6]=0.000439792;
Sintrodd[4][6]=4.41815e-05;
 
Costrodd[0][7]=0.000265381;
Costrodd[1][7]=-0.000797212;
Costrodd[2][7]=0.000455332;
Costrodd[3][7]=0.00102593;
Costrodd[4][7]=0.000743254;
 
Sintrodd[0][7]=-0.000650049;
Sintrodd[1][7]=9.7921e-05;
Sintrodd[2][7]=0.00012297;
Sintrodd[3][7]=0.000143796;
Sintrodd[4][7]=0.000530193;
 
Costrodd[0][8]=0.000164517;
Costrodd[1][8]=-0.000634593;
Costrodd[2][8]=6.39358e-05;
Costrodd[3][8]=-0.000354771;
Costrodd[4][8]=-0.000518855;
 
Sintrodd[0][8]=0.000740947;
Sintrodd[1][8]=-2.63232e-05;
Sintrodd[2][8]=-0.000280208;
Sintrodd[3][8]=0.000388594;
Sintrodd[4][8]=-0.00106537;
 
Costrodd[0][9]=0.000249664;
Costrodd[1][9]=-0.000442425;
Costrodd[2][9]=2.56174e-05;
Costrodd[3][9]=8.62314e-06;
Costrodd[4][9]=-0.00173249;
 
Sintrodd[0][9]=0.000249314;
Sintrodd[1][9]=-0.000222667;
Sintrodd[2][9]=-0.000457108;
Sintrodd[3][9]=-0.000108543;
Sintrodd[4][9]=-0.000337884;
 

}//End of Angular Corrections Function


+EOF
