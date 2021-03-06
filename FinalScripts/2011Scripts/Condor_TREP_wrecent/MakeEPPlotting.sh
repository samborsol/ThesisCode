#!/bin/sh
 

b=$(sed -ne "${1}{p;q;}" files.txt)

cat > TRV1EPPlotting_${1}.C << +EOF

#include<TH1F>
#include<TProfile>
#include<iostream>
#include<iomanip>
#include"TFile.h"
#include"TTree.h"
#include"TLeaf.h"
#include"TChain.h"
//Functions in this macro///
void Initialize();
void FillPTStats();
void FillFlowVectors();
void FillAngularCorrections();
void FlowAnalysis();
////////////////////////////


//Files and chains
TChain* chain2;
TChain* chain3;
TChain* chain4;


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
//NumberOfEvents=100;
//NumberOfEvents=50000;
//NumberOfEvents=100000;
//NumberOfEvents=5000000;
//  NumberOfEvents = chain->GetEntries();

const Int_t nCent=5;//Number of Centrality classes

///Looping Variables
Int_t Centrality=0; //This will be the centrality variable later
Int_t NumberOfHits=0;//This will be for both tracks and Hits
Float_t pT=0.;
Float_t phi=0.;
Float_t eta=0.;
Float_t Zposition=0.;


Float_t centlo[nCent];
Float_t centhi[nCent];
centlo[0]=0;  centhi[0]=10;
centlo[1]=10;  centhi[1]=20;
centlo[2]=20;  centhi[2]=30;
centlo[3]=30;  centhi[3]=40;
centlo[4]=40;  centhi[4]=50;

//Create the output ROOT file
TFile *myFile;

//PT Bin Centers
TProfile *PTCenters[nCent];

//EP Resolution Plots

//For Resolution of V1 Even
TProfile *TRPMinusTRM[nCent];
TProfile *TRMMinusTRC[nCent];
TProfile *TRPMinusTRC[nCent];

//For Resolution of V1 Odd
TProfile *TRPMinusTRMOdd[nCent];
TProfile *TRMMinusTRCOdd[nCent];
TProfile *TRPMinusTRCOdd[nCent];


//Make Subdirectories for what will follow
TDirectory *myPlots;//the top level
TDirectory *epangles;//where i will store the ep angles
TDirectory *outerep;
TDirectory *posep;
TDirectory *negep;
TDirectory *midep;

TDirectory *resolutions;//top level for resolutions
TDirectory *psioneoddres;//where i will store standard EP resolution plots
TDirectory *psioneevenres;//where i will store psi1(even)

TDirectory *v1plots;//where i will store the v1 plots
TDirectory *v1etaoddplots;//v1(eta) [odd] plots
TDirectory *v1etaevenplots; //v1(eta)[even] plots
TDirectory *v1ptevenplots; //v1(pT)[even] plots
TDirectory *v1ptoddplots;//v1(pT)[odd] plots

TDirectory *flowvecplots;

//TProfiles to save <pT> and <pT^2> info ....All this is for Ollitrault weights
Float_t ptavwhole[nCent]={0.},pt2avwhole[nCent]={0.};
Float_t ptavpos[nCent]={0.},pt2avpos[nCent]={0.};
Float_t ptavneg[nCent]={0.},pt2avneg[nCent]={0.};
Float_t ptavmid[nCent]={0.},pt2avmid[nCent]={0.};

//Looping Variables
//v1 even
Float_t X_wholetracker[nCent]={0.},Y_wholetracker[nCent]={0.},
  X_postracker[nCent]={0.},Y_postracker[nCent]={0.},
  X_negtracker[nCent]={0.},Y_negtracker[nCent]={0.},
  X_midtracker[nCent]={0.},Y_midtracker[nCent]={0.};

//v1 odd
Float_t X_wholeoddtracker[nCent]={0.},Y_wholeoddtracker[nCent]={0.},
  X_posoddtracker[nCent]={0.},Y_posoddtracker[nCent]={0.},
  X_negoddtracker[nCent]={0.},Y_negoddtracker[nCent]={0.},
  X_midoddtracker[nCent]={0.},Y_midoddtracker[nCent]={0.};



//////////////////////////////////////
// The following variables and plots
// are for the AngularCorrections
// function
///////////////////////////////////////


//These Will store the angular correction factors
//v1 even
//Whole Tracker
Float_t CosineWholeTracker[nCent][jMax],SineWholeTracker[nCent][jMax];

//Pos Tracker
Float_t CosinePosTracker[nCent][jMax],SinePosTracker[nCent][jMax];

//Neg Tracker
Float_t CosineNegTracker[nCent][jMax],SineNegTracker[nCent][jMax];

//Mid Tracker
Float_t CosineMidTracker[nCent][jMax],SineMidTracker[nCent][jMax];

//v1 odd
//Whole Tracker
Float_t CosineWholeOddTracker[nCent][jMax],SineWholeOddTracker[nCent][jMax];

//Pos Tracker
Float_t CosinePosOddTracker[nCent][jMax],SinePosOddTracker[nCent][jMax];

//Neg Tracker
Float_t CosineNegOddTracker[nCent][jMax],SineNegOddTracker[nCent][jMax];

//Mid Tracker
Float_t CosineMidOddTracker[nCent][jMax],SineMidOddTracker[nCent][jMax];

//EP Plots
//Even
   //Whole Tracker
TH1F *PsiEvenRaw[nCent];
TH1F *PsiEvenFirst[nCent];
TH1F *PsiEvenFinal[nCent];
   //Pos Tracker
TH1F *PsiPEvenRaw[nCent];
TH1F *PsiPEvenFirst[nCent];
TH1F *PsiPEvenFinal[nCent];
   //Neg Tracker
TH1F *PsiNEvenRaw[nCent];
TH1F *PsiNEvenFirst[nCent];
TH1F *PsiNEvenFinal[nCent];
   //Mid Tracker
TH1F *PsiMEvenRaw[nCent];
TH1F *PsiMEvenFirst[nCent];
TH1F *PsiMEvenFinal[nCent];

//Odd
  //Whole Tracker 
TH1F *PsiOddRaw[nCent];
TH1F *PsiOddFirst[nCent];
TH1F *PsiOddFinal[nCent];
   //Pos Tracker
TH1F *PsiPOddRaw[nCent];
TH1F *PsiPOddFirst[nCent];
TH1F *PsiPOddFinal[nCent];
   //Neg Tracker
TH1F *PsiNOddRaw[nCent];
TH1F *PsiNOddFirst[nCent];
TH1F *PsiNOddFinal[nCent];
   //Mid Tracker
TH1F *PsiMOddRaw[nCent];
TH1F *PsiMOddFirst[nCent];
TH1F *PsiMOddFinal[nCent];

//Flow vector plot
TH1F *Xvector[nCent];
TH1F *Yvector[nCent];
/////////////////////////////////////////
/// Variables that are used in the //////
// Flow Analysis function////////////////
/////////////////////////////////////////

//RAW EP's
Float_t EPwholetracker=0.,EPpostracker=0.,EPnegtracker=0.,EPmidtracker=0.,
  EPwholeoddtracker=0.,EPposoddtracker=0.,EPnegoddtracker=0.,EPmidoddtracker=0.;

//Corrected EP's
Float_t EPcorrwholetracker=0.,EPcorrpostracker=0.,EPcorrnegtracker=0.,EPcorrmidtracker=0.,
  EPcorrwholeoddtracker=0.,EPcorrposoddtracker=0.,EPcorrnegoddtracker=0.,EPcorrmidoddtracker=0.;

//v1 even stuff
Float_t AngularCorrectionWholeTracker=0.,EPfinalwholetracker=0.,
  AngularCorrectionPosTracker=0.,EPfinalpostracker=0.,
  AngularCorrectionNegTracker=0.,EPfinalnegtracker=0.,
  AngularCorrectionMidTracker=0.,EPfinalmidtracker=0.;


//v1 odd

Float_t AngularCorrectionWholeOddTracker=0.,EPfinalwholeoddtracker=0.,
  AngularCorrectionPosOddTracker=0.,EPfinalposoddtracker=0.,
  AngularCorrectionNegOddTracker=0.,EPfinalnegoddtracker=0.,
  AngularCorrectionMidOddTracker=0.,EPfinalmidoddtracker=0.;


//v1 even
Float_t Xcorr_wholetracker=0.,Ycorr_wholetracker=0.,
  Xcorr_postracker=0.,Ycorr_postracker=0.,
  Xcorr_negtracker=0.,Ycorr_negtracker=0.,
  Xcorr_midtracker=0.,Ycorr_midtracker=0.;

//v1 odd
Float_t Xcorr_wholeoddtracker=0.,Ycorr_wholeoddtracker=0.,
  Xcorr_posoddtracker=0.,Ycorr_posoddtracker=0.,
  Xcorr_negoddtracker=0.,Ycorr_negoddtracker=0.,
  Xcorr_midoddtracker=0.,Ycorr_midoddtracker=0.;

/////////////////
///FLOW PLOTS////
////////////////
TProfile *V1EtaOdd[nCent];
TProfile *V1EtaEven[nCent];
TProfile *V1PtEven[nCent];
TProfile *V1PtOdd[nCent];


//Permanent Variables
//v1 even
Float_t Xav_wholetracker[nCent]={0.},Yav_wholetracker[nCent]={0.},
  Xav_postracker[nCent]={0.},Yav_postracker[nCent]={0.},
  Xav_negtracker[nCent]={0.},Yav_negtracker[nCent]={0.},
  Xav_midtracker[nCent]={0.},Yav_midtracker[nCent]={0.};

//v1 odd
Float_t Xav_wholeoddtracker[nCent]={0.},Yav_wholeoddtracker[nCent]={0.},
  Xav_posoddtracker[nCent]={0.},Yav_posoddtracker[nCent]={0.},
  Xav_negoddtracker[nCent]={0.},Yav_negoddtracker[nCent]={0.},
  Xav_midoddtracker[nCent]={0.},Yav_midoddtracker[nCent]={0.};

//Standard Deviations
//v1 even
Float_t Xstdev_wholetracker[nCent]={0.},Ystdev_wholetracker[nCent]={0.},
  Xstdev_postracker[nCent]={0.},Ystdev_postracker[nCent]={0.},
  Xstdev_negtracker[nCent]={0.},Ystdev_negtracker[nCent]={0.},
  Xstdev_midtracker[nCent]={0.},Ystdev_midtracker[nCent]={0.};

//v1 odd
Float_t Xstdev_wholeoddtracker[nCent]={0.},Ystdev_wholeoddtracker[nCent]={0.},
  Xstdev_posoddtracker[nCent]={0.},Ystdev_posoddtracker[nCent]={0.},
  Xstdev_negoddtracker[nCent]={0.},Ystdev_negoddtracker[nCent]={0.},
  Xstdev_midoddtracker[nCent]={0.},Ystdev_midoddtracker[nCent]={0.};

///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
/////////////////// END OF GLOBAL VARIABLES ///////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////

//Running the Macro
Int_t TRV1EPPlotting_${1}(){//put functions in here
  Initialize();
  FillPTStats();
  FillFlowVectors();
  FillAngularCorrections();
  FlowAnalysis();
  myFile->Write();
  return 0;
}

void Initialize(){

  float eta_bin_small[13]={-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.0,0.1,0.2,0.3,0.4,0.5,0.6};

  double pt_bin[17]={0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.4,2.8,3.2,3.6,4.5,6.5,9.5,12};

  chain2= new TChain("hiLowPtPixelTracksTree");
    chain3=new TChain("hiSelectedVertexTree");
  chain4=new TChain("HFtowersCentralityTree");
  
    //Tracks Tree                                                 
    chain2->Add("/data/users/jgomez2/BetterTrees/$b");                                 
   //Vertex Tree                                                                                     
   chain3->Add("/data/users/jgomez2/BetterTrees/$b");                                     
  //Centrality Tree                                                                                     
  chain4->Add("/data/users/jgomez2/BetterTrees/$b"); 

    NumberOfEvents= chain2->GetEntries();
  //Create the output ROOT file
  myFile = new TFile("TREP_EPPlotting_${1}.root","recreate");

  //Make Subdirectories for what will follow
  myPlots = myFile->mkdir("Plots");
  myPlots->cd();

  flowvecplots=myPlots->mkdir("FlowVectors");


  //Directory for the EP angles
  epangles = myPlots->mkdir("EventPlanes");
  //Outer Tracker
  outerep = epangles->mkdir("WholeTracker");
  //Pos Tracker
  posep = epangles->mkdir("PositiveTracker");
  //Negative Tracker
  negep = epangles->mkdir("NegativeTracker");
  //Mid Tracker
  midep = epangles->mkdir("CentralTracker");

  //Directory for Resolution Plots
  resolutions = myPlots->mkdir("EventPlaneResolutions");
  psioneevenres = resolutions->mkdir("PsiOneEvenResolution");
  psioneoddres = resolutions->mkdir("PsiOneOddResolution");


  //Directory For Final v1 plots
  v1plots = myPlots->mkdir("V1Results");
  v1etaoddplots = v1plots->mkdir("V1EtaOdd");
  v1etaevenplots = v1plots->mkdir("V1EtaEven");
  v1ptevenplots = v1plots->mkdir("V1pTEven");
  v1ptoddplots = v1plots->mkdir("V1pTOdd");




  char ptcentname[128];
  char ptcenttitle[128];

  char res4name[128],res4title[128];
  char res5name[128],res5title[128];
  char res6name[128],res6title[128];

  //Psi1 Raw, Psi1 Final
  //Psi1(even)
  //Whole Tracker
  char epevenrawname[128],epevenrawtitle[128];
  char epevenfirstname[128],epevenfirsttitle[128];
  char epevenfinalname[128],epevenfinaltitle[128];
  //Pos Tracker
  char pevenrawname[128],pevenrawtitle[128];
  char pevenfirstname[128],pevenfirsttitle[128];
  char pevenfinalname[128],pevenfinaltitle[128];
  //Neg Tracker
  char nevenrawname[128],nevenrawtitle[128];
  char nevenfirstname[128],nevenfirsttitle[128];
  char nevenfinalname[128],nevenfinaltitle[128];
  //Mid Tracker
  char mevenrawname[128],mevenrawtitle[128];
  char mevenfirstname[128],mevenfirsttitle[128];
  char mevenfinalname[128],mevenfinaltitle[128];

  //Psi1(odd)
  //Whole Tracker
  char epoddrawname[128],epoddrawtitle[128];
  char epoddfirstname[128],epoddfirsttitle[128];
  char epoddfinalname[128],epoddfinaltitle[128];
  //Pos Tracker
  char poddrawname[128],poddrawtitle[128];
  char poddfirstname[128],poddfirsttitle[128];
  char poddfinalname[128],poddfinaltitle[128];
  //Neg Tracker
  char noddrawname[128],noddrawtitle[128];
  char noddfirstname[128],noddfirsttitle[128];
  char noddfinalname[128],noddfinaltitle[128];
  //Mid Tracker
  char moddrawname[128],moddrawtitle[128];
  char moddfirstname[128],moddfirsttitle[128];
  char moddfinalname[128],moddfinaltitle[128];


  //V1 Plots
  char v1etaoddname[128],v1etaoddtitle[128];
  char v1etaevenname[128],v1etaeventitle[128];
  char v1ptoddname[128],v1ptoddtitle[128];
  char v1ptevenname[128],v1pteventitle[128];


  //V1 odd resolutions
  char v1oddres1name[128],v1oddres1title[128];
  char v1oddres2name[128],v1oddres2title[128];
  char v1oddres3name[128],v1oddres3title[128];

  char xvecname[128],xvectitle[128];
  char yvecname[128],yvectitle[128];

  for (int i=0;i<nCent;i++)
    {
      //V1 odd eta
      v1etaoddplots->cd();
      sprintf(v1etaoddname,"V1EtaOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1etaoddtitle,"v_{1}^{odd}(#eta) for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      V1EtaOdd[i]= new TProfile(v1etaoddname,v1etaoddtitle,12,eta_bin_small);

      //v1 even eta
      v1etaevenplots->cd();
      sprintf(v1etaevenname,"V1EtaEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1etaeventitle,"v_{1}^{even}(#eta) for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      V1EtaEven[i]= new TProfile(v1etaevenname,v1etaeventitle,12,eta_bin_small);

      //v1 pt even
      v1ptevenplots->cd();
      sprintf(v1ptevenname,"V1PtEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1pteventitle,"v_{1}^{even}(p_{T}) for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      V1PtEven[i]= new TProfile(v1ptevenname,v1pteventitle,16,pt_bin);


      //v1 pt odd
      v1ptoddplots->cd();
      sprintf(v1ptoddname,"V1PtOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1ptoddtitle,"v_{1}^{odd}(p_{T}) for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      V1PtOdd[i]= new TProfile(v1ptoddname,v1ptoddtitle,16,pt_bin);

      v1plots->cd();
      sprintf(ptcentname,"pTcenter_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(ptcenttitle,"Bin Center for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      PTCenters[i]= new TProfile(ptcentname,ptcenttitle,16,pt_bin); //or can make a TH1f and fill a specific range
/////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////
      //Event Plane Plots
      outerep->cd();
      //Psi1Even
      //Whole Tracker
      //Raw
      sprintf(epevenrawname,"Psi1EvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epevenrawtitle,"#Psi_{1}^{even} Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiEvenRaw[i] = new TH1F(epevenrawname,epevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiEvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");

      //First
      sprintf(epevenfirstname,"Psi1EvenFirst_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epevenfirsttitle,"#Psi_{1}^{even} First %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiEvenFirst[i] = new TH1F(epevenfirstname,epevenfirsttitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiEvenFirst[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      
      //Final
      sprintf(epevenfinalname,"Psi1EvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epevenfinaltitle,"#Psi_{1}^{even} Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiEvenFinal[i] = new TH1F(epevenfinalname,epevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiEvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");


     //Pos Tracker
      posep->cd();
      //Raw
      sprintf(pevenrawname,"Psi1PEvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(pevenrawtitle,"#Psi_{1}^{even}(TR^{+}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPEvenRaw[i] = new TH1F(pevenrawname,pevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPEvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //First
      sprintf(pevenfirstname,"Psi1PEvenFirst_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(pevenfirsttitle,"#Psi_{1}^{even}(TR^{+}) First %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPEvenFirst[i] = new TH1F(pevenfirstname,pevenfirsttitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPEvenFirst[i]->GetXaxis()->SetTitle("EP Angle (radians)");

      //Final
      sprintf(pevenfinalname,"Psi1PEvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(pevenfinaltitle,"#Psi_{1}^{even}(TR^{+}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPEvenFinal[i] = new TH1F(pevenfinalname,pevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPEvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

     //Neg Tracker
      negep->cd();
      //Raw
      sprintf(nevenrawname,"Psi1NEvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(nevenrawtitle,"#Psi_{1}^{even}(TR^{-}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNEvenRaw[i] = new TH1F(nevenrawname,nevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNEvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //First
      sprintf(nevenfirstname,"Psi1NEvenFirst_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(nevenfirsttitle,"#Psi_{1}^{even}(TR^{-}) First %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNEvenFirst[i] = new TH1F(nevenfirstname,nevenfirsttitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNEvenFirst[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(nevenfinalname,"Psi1NEvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(nevenfinaltitle,"#Psi_{1}^{even}(TR^{-}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNEvenFinal[i] = new TH1F(nevenfinalname,nevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNEvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

     //Mid Tracker
      midep->cd();
      //Raw
      sprintf(mevenrawname,"Psi1MEvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(mevenrawtitle,"#Psi_{1}^{even}(TR^{mid}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiMEvenRaw[i] = new TH1F(mevenrawname,mevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiMEvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //First
      sprintf(mevenfirstname,"Psi1MEvenFirst_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(mevenfirsttitle,"#Psi_{1}^{even}(TR^{mid}) First %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiMEvenFirst[i] = new TH1F(mevenfirstname,mevenfirsttitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiMEvenFirst[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(mevenfinalname,"Psi1MEvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(mevenfinaltitle,"#Psi_{1}^{even}(TR^{mid}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiMEvenFinal[i] = new TH1F(mevenfinalname,mevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiMEvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //Psi1Odd
      outerep->cd();
      //WholeTracker
      //Raw
      sprintf(epoddrawname,"Psi1OddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epoddrawtitle,"#Psi_{1}^{odd} Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiOddRaw[i] = new TH1F(epoddrawname,epoddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiOddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //First
      sprintf(epoddfirstname,"Psi1OddFirst_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epoddfirsttitle,"#Psi_{1}^{odd} First %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiOddFirst[i] = new TH1F(epoddfirstname,epoddfirsttitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiOddFirst[i]->GetXaxis()->SetTitle("EP Angle (radians)");


      //Final
      sprintf(epoddfinalname,"Psi1OddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epoddfinaltitle,"#Psi_{1}^{odd} Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiOddFinal[i] = new TH1F(epoddfinalname,epoddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiOddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

     //Pos Tracker
      posep->cd();
      //Raw
      sprintf(poddrawname,"Psi1POddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(poddrawtitle,"#Psi_{1}^{odd}(TR^{+}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPOddRaw[i] = new TH1F(poddrawname,poddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPOddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //First
      sprintf(poddfirstname,"Psi1POddFirst_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(poddfirsttitle,"#Psi_{1}^{odd}(TR^{+}) First %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPOddFirst[i] = new TH1F(poddfirstname,poddfirsttitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPOddFirst[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(poddfinalname,"Psi1POddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(poddfinaltitle,"#Psi_{1}^{odd}(TR^{+}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPOddFinal[i] = new TH1F(poddfinalname,poddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPOddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

     //Neg Tracker
      negep->cd();
      //Raw
      sprintf(noddrawname,"Psi1NOddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(noddrawtitle,"#Psi_{1}^{odd}(TR^{-}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNOddRaw[i] = new TH1F(noddrawname,noddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNOddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //First
      sprintf(noddfirstname,"Psi1NOddFirst_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(noddfirsttitle,"#Psi_{1}^{odd}(TR^{-}) First %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNOddFirst[i] = new TH1F(noddfirstname,noddfirsttitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNOddFirst[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(noddfinalname,"Psi1NOddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(noddfinaltitle,"#Psi_{1}^{odd}(TR^{-}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNOddFinal[i] = new TH1F(noddfinalname,noddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNOddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

     //Mid Tracker
      midep->cd();
      //Raw
      sprintf(moddrawname,"Psi1MOddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(moddrawtitle,"#Psi_{1}^{odd}(TR^{mid}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiMOddRaw[i] = new TH1F(moddrawname,moddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiMOddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");

      //First
      sprintf(moddfirstname,"Psi1MOddFirst_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(moddfirsttitle,"#Psi_{1}^{odd}(TR^{mid}) First %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiMOddFirst[i] = new TH1F(moddfirstname,moddfirsttitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiMOddFirst[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(moddfinalname,"Psi1MOddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(moddfinaltitle,"#Psi_{1}^{odd}(TR^{mid}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiMOddFinal[i] = new TH1F(moddfinalname,moddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiMOddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");


/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
      //For Resolution of V1 Even
      psioneevenres->cd();
      sprintf(res4name,"TRPMinusTRM_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(res4title,"First Order EP resolution TRPMinusTRM %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRPMinusTRM[i]= new TProfile(res4name,res4title,1,0,1);

      sprintf(res5name,"TRMMinusTRC_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(res5title,"First Order EP resolution TRMMinusTRC %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRMMinusTRC[i]= new TProfile(res5name,res5title,1,0,1);

      sprintf(res6name,"TRPMinusTRC_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(res6title,"First Order EP resolution TRPMinusTRC %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRPMinusTRC[i]= new TProfile(res6name,res6title,1,0,1);


      //For Resolution of V1 Odd
      psioneoddres->cd();
      sprintf(v1oddres1name,"TRPMinusTRMOdd_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1oddres1title,"First Order EP resolution TRPMinusTRMOdd %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRPMinusTRMOdd[i]= new TProfile(v1oddres1name,v1oddres1title,1,0,1);

      sprintf(v1oddres2name,"TRMMinusTRCOdd_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1oddres2title,"First Order EP resolution TRMMinusTRCOdd %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRMMinusTRCOdd[i]= new TProfile(v1oddres2name,v1oddres2title,1,0,1);

      sprintf(v1oddres3name,"TRPMinusTRCOdd_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1oddres3title,"First Order EP resolution TRPMinusTRCOdd %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRPMinusTRCOdd[i]= new TProfile(v1oddres3name,v1oddres3title,1,0,1);

     flowvecplots->cd();
      sprintf(xvecname,"XvectorEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(xvectitle,"XvectorEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Xvector[i]= new TH1F(xvecname,xvectitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);      
      Xvector[i]->GetXaxis()->SetTitle("X angle (GeV*radians)");
         
      sprintf(yvecname,"YvectorEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(yvectitle,"YvectorEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Yvector[i]= new TH1F(yvecname,yvectitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);      
      Yvector[i]->GetXaxis()->SetTitle("Y angle (GeV*radians)");


     }//end of centrality loop
}//end of initialize function

void FillPTStats(){

  }//end of fillptstats function



void FlowAnalysis(){
  for (Int_t i=0;i<NumberOfEvents;i++)
    {
      if ( !(i%10000) ) cout << " 1st round, event # " << i << " / " << NumberOfEvents << endl;

      chain2->GetEntry(i);//grab the ith event

      chain2->GetEntry(i);//grab the ith event
      chain3->GetEntry(i);
      chain4->GetEntry(i);
  
      //Grab the Track Leaves
      NumTracks= (TLeaf*) chain2->GetLeaf("nTracks");
      TrackMom= (TLeaf*) chain2->GetLeaf("pt");
      TrackPhi= (TLeaf*) chain2->GetLeaf("phi");
      TrackEta= (TLeaf*) chain2->GetLeaf("eta");

       //Filter On Centrality
      CENTRAL= (TLeaf*) chain4->GetLeaf("Bin");
      Centrality= CENTRAL->GetValue();
      if (Centrality>100) continue;

      //Make Vertex Cuts if Necessary
      Vertex=(TLeaf*) chain3->GetLeaf("z");
      Zposition=Vertex->GetValue();
      //if(Zposition<=5) continue;


      for (int q=0;q<nCent;q++)
        {
          //v1 Even
          X_wholetracker[q]=0.;
          Y_wholetracker[q]=0.;
          X_postracker[q]=0.;
          Y_postracker[q]=0.;
          X_negtracker[q]=0.;
          Y_negtracker[q]=0.;
          X_midtracker[q]=0.;
          Y_midtracker[q]=0.;

          //v1 odd
          X_wholeoddtracker[q]=0.;
          Y_wholeoddtracker[q]=0.;
          X_posoddtracker[q]=0.;
          Y_posoddtracker[q]=0.;
          X_negoddtracker[q]=0.;
          Y_negoddtracker[q]=0.;
          X_midoddtracker[q]=0.;
          Y_midoddtracker[q]=0.;
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
          if(pT<0)
            {
              continue;
            }
          for (Int_t c=0;c<nCent;c++)
            {
              if ( (Centrality*0.5) > centhi[c] ) continue;
              if ( (Centrality*0.5) < centlo[c] ) continue;
              if(eta>=1.4)
                {
                  X_wholetracker[c]+=cos(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  Y_wholetracker[c]+=sin(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  X_postracker[c]+=cos(phi)*(pT-(pt2avpos[c]/ptavpos[c]));
                  Y_postracker[c]+=sin(phi)*(pT-(pt2avpos[c]/ptavpos[c]));
                  //v1 odd
                  X_wholeoddtracker[c]+=cos(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  Y_wholeoddtracker[c]+=sin(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  X_posoddtracker[c]+=cos(phi)*(pT-(pt2avpos[c]/ptavpos[c]));
                  Y_posoddtracker[c]+=sin(phi)*(pT-(pt2avpos[c]/ptavpos[c]));
                }
              else if(eta<=-1.4)
                {
                  X_wholetracker[c]+=cos(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  Y_wholetracker[c]+=sin(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  X_negtracker[c]+=cos(phi)*(pT-(pt2avneg[c]/ptavneg[c]));
                  Y_negtracker[c]+=sin(phi)*(pT-(pt2avneg[c]/ptavneg[c]));
                  //v1 odd
                  X_wholeoddtracker[c]+=cos(phi)*(-1.0*(pT-(pt2avwhole[c]/ptavwhole[c])));
                  Y_wholeoddtracker[c]+=sin(phi)*(-1.0*(pT-(pt2avwhole[c]/ptavwhole[c])));
                  X_negoddtracker[c]+=cos(phi)*(-1.0*(pT-(pt2avneg[c]/ptavneg[c])));
                  Y_negoddtracker[c]+=sin(phi)*(-1.0*(pT-(pt2avneg[c]/ptavneg[c])));
                }
              else if(eta<=0.6 && eta>0)
                {
                  X_midtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_midtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  //v1 odd
                  X_midoddtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_midoddtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                }
              else if(eta>=-0.6 && eta<0)
                {
                  X_midtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_midtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  //v1 odd
                  X_midoddtracker[c]+=cos(phi)*(-1.0*(pT-(pt2avmid[c]/ptavmid[c])));
                  Y_midoddtracker[c]+=sin(phi)*(-1.0*(pT-(pt2avmid[c]/ptavmid[c])));
                }
            }//end of loop over centrality classes
        }//end of loop over tracks


      //Time to fill the appropriate histograms, this will be <X> <Y>
      for (Int_t c=0;c<nCent;c++)
        {
          if ( (Centrality*0.5) > centhi[c] ) continue;
          if ( (Centrality*0.5) < centlo[c] ) continue;

//////////////////////////////////
//FIRST FILL THE RAW HISTOS//////
////////////////////////////////////

          //V1 even
          //Whole Tracker
          EPwholetracker=(1./1.)*atan2(Y_wholetracker[c],X_wholetracker[c]);
	  if (EPwholetracker>(pi)) EPwholetracker=(EPwholetracker-(TMath::TwoPi()));
          if (EPwholetracker<(-1.0*(pi))) EPwholetracker=(EPwholetracker+(TMath::TwoPi()));
          PsiEvenRaw[c]->Fill(EPwholetracker);


          //Pos Tracker
          EPpostracker=(1./1.)*atan2(Y_postracker[c],X_postracker[c]);
          if (EPpostracker>(pi)) EPpostracker=(EPpostracker-(TMath::TwoPi()));
          if (EPpostracker<(-1.0*(pi))) EPpostracker=(EPpostracker+(TMath::TwoPi()));
          PsiPEvenRaw[c]->Fill(EPpostracker);

          //neg Tracker
          EPnegtracker=(1./1.)*atan2(Y_negtracker[c],X_negtracker[c]);
          if (EPnegtracker>(pi)) EPnegtracker=(EPnegtracker-(TMath::TwoPi()));
          if (EPnegtracker<(-1.0*(pi))) EPnegtracker=(EPnegtracker+(TMath::TwoPi()));
          PsiNEvenRaw[c]->Fill(EPnegtracker);


          //mid Tracker
          EPmidtracker=(1./1.)*atan2(Y_midtracker[c],X_midtracker[c]);
          if (EPmidtracker>(pi)) EPmidtracker=(EPmidtracker-(TMath::TwoPi()));
          if (EPmidtracker<(-1.0*(pi))) EPmidtracker=(EPmidtracker+(TMath::TwoPi()));
          PsiMEvenRaw[c]->Fill(EPmidtracker);

          //V1 odd
          //Whole Tracker
          EPwholeoddtracker=(1./1.)*atan2(Y_wholeoddtracker[c],X_wholeoddtracker[c]);
          if (EPwholeoddtracker>(pi)) EPwholeoddtracker=(EPwholeoddtracker-(TMath::TwoPi()));
          if (EPwholeoddtracker<(-1.0*(pi))) EPwholeoddtracker=(EPwholeoddtracker+(TMath::TwoPi()));
          PsiOddRaw[c]->Fill(EPwholeoddtracker);


          //Pos Tracker
          EPposoddtracker=(1./1.)*atan2(Y_posoddtracker[c],X_posoddtracker[c]);
          if (EPposoddtracker>(pi)) EPposoddtracker=(EPposoddtracker-(TMath::TwoPi()));
          if (EPposoddtracker<(-1.0*(pi))) EPposoddtracker=(EPposoddtracker+(TMath::TwoPi()));
          PsiPOddRaw[c]->Fill(EPposoddtracker);

          //neg Tracker
          EPnegoddtracker=(1./1.)*atan2(Y_negoddtracker[c],X_negoddtracker[c]);
          if (EPnegoddtracker>(pi)) EPnegoddtracker=(EPnegoddtracker-(TMath::TwoPi()));
          if (EPnegoddtracker<(-1.0*(pi))) EPnegoddtracker=(EPnegoddtracker+(TMath::TwoPi()));
          PsiNOddRaw[c]->Fill(EPnegoddtracker);


          //mid Tracker
          EPmidoddtracker=(1./1.)*atan2(Y_midoddtracker[c],X_midoddtracker[c]);
          if (EPmidoddtracker>(pi)) EPmidoddtracker=(EPmidoddtracker-(TMath::TwoPi()));
          if (EPmidoddtracker<(-1.0*(pi))) EPmidoddtracker=(EPmidoddtracker+(TMath::TwoPi()));
          PsiMOddRaw[c]->Fill(EPmidoddtracker);
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

          //V1 even
          //Whole Tracker
          Xcorr_wholetracker=(X_wholetracker[c]-Xav_wholetracker[c])/Xstdev_wholetracker[c];
          Ycorr_wholetracker=(Y_wholetracker[c]-Yav_wholetracker[c])/Ystdev_wholetracker[c];
	  Xvector[c]->Fill(Xcorr_wholetracker[c]);
          Yvector[c]->Fill(Ycorr_wholetracker[c]);
	  EPcorrwholetracker=(1./1.)*atan2(Ycorr_wholetracker,Xcorr_wholetracker);
          if (EPcorrwholetracker>(pi)) EPcorrwholetracker=(EPcorrwholetracker-(TMath::TwoPi()));
          if (EPcorrwholetracker<(-1.0*(pi))) EPcorrwholetracker=(EPcorrwholetracker+(TMath::TwoPi()));
          PsiEvenFirst[c]->Fill(EPcorrwholetracker);     

          //Pos Tracker
          Xcorr_postracker=(X_postracker[c]-Xav_postracker[c])/Xstdev_postracker[c];
          Ycorr_postracker=(Y_postracker[c]-Yav_postracker[c])/Ystdev_postracker[c];
          EPcorrpostracker=(1./1.)*atan2(Ycorr_postracker,Xcorr_postracker);
          if (EPcorrpostracker>(pi)) EPcorrpostracker=(EPcorrpostracker-(TMath::TwoPi()));
          if (EPcorrpostracker<(-1.0*(pi))) EPcorrpostracker=(EPcorrpostracker+(TMath::TwoPi()));
          PsiPEvenFirst[c]->Fill(EPcorrpostracker);
          

          //neg Tracker
          Xcorr_negtracker=(X_negtracker[c]-Xav_negtracker[c])/Xstdev_negtracker[c];
          Ycorr_negtracker=(Y_negtracker[c]-Yav_negtracker[c])/Ystdev_negtracker[c];
          EPcorrnegtracker=(1./1.)*atan2(Ycorr_negtracker,Xcorr_negtracker);
          // if (c==2) std::cout<<Xcorr_negtracker<<" "<<Ycorr_negtracker<<" "<<EPnegtracker<<std::endl;
          if (EPcorrnegtracker>(pi)) EPcorrnegtracker=(EPcorrnegtracker-(TMath::TwoPi()));
          if (EPcorrnegtracker<(-1.0*(pi))) EPcorrnegtracker=(EPcorrnegtracker+(TMath::TwoPi()));
          PsiNEvenFirst[c]->Fill(EPcorrnegtracker);


          //mid Tracker
          Xcorr_midtracker=(X_midtracker[c]-Xav_midtracker[c])/Xstdev_midtracker[c];
          Ycorr_midtracker=(Y_midtracker[c]-Yav_midtracker[c])/Ystdev_midtracker[c];
          EPcorrmidtracker=(1./1.)*atan2(Ycorr_midtracker,Xcorr_midtracker);
          if (EPcorrmidtracker>(pi)) EPcorrmidtracker=(EPcorrmidtracker-(TMath::TwoPi()));
          if (EPcorrmidtracker<(-1.0*(pi))) EPcorrmidtracker=(EPcorrmidtracker+(TMath::TwoPi()));
          PsiMEvenFirst[c]->Fill(EPcorrmidtracker);          

          //V1 Odd
          //Whole Tracker
          Xcorr_wholeoddtracker=(X_wholeoddtracker[c]-Xav_wholeoddtracker[c])/Xstdev_wholeoddtracker[c];
          Ycorr_wholeoddtracker=(Y_wholeoddtracker[c]-Yav_wholeoddtracker[c])/Ystdev_wholeoddtracker[c];
          EPcorrwholeoddtracker=(1./1.)*atan2(Ycorr_wholeoddtracker,Xcorr_wholeoddtracker);
          if (EPcorrwholeoddtracker>(pi)) EPcorrwholeoddtracker=(EPcorrwholeoddtracker-(TMath::TwoPi()));
          if (EPcorrwholeoddtracker<(-1.0*(pi))) EPcorrwholeoddtracker=(EPcorrwholeoddtracker+(TMath::TwoPi()));
          PsiOddFirst[c]->Fill(EPcorrwholeoddtracker);

          //Pos Tracker
          Xcorr_posoddtracker=(X_posoddtracker[c]-Xav_posoddtracker[c])/Xstdev_posoddtracker[c];
          Ycorr_posoddtracker=(Y_posoddtracker[c]-Yav_posoddtracker[c])/Ystdev_posoddtracker[c];
          EPcorrposoddtracker=(1./1.)*atan2(Ycorr_posoddtracker,Xcorr_posoddtracker);
          if (EPcorrposoddtracker>(pi)) EPcorrposoddtracker=(EPcorrposoddtracker-(TMath::TwoPi()));
          if (EPcorrposoddtracker<(-1.0*(pi))) EPcorrposoddtracker=(EPcorrposoddtracker+(TMath::TwoPi()));
          PsiPOddFirst[c]->Fill(EPcorrposoddtracker);


          //neg Tracker
          Xcorr_negoddtracker=(X_negoddtracker[c]-Xav_negoddtracker[c])/Xstdev_negoddtracker[c];
          Ycorr_negoddtracker=(Y_negoddtracker[c]-Yav_negoddtracker[c])/Ystdev_negoddtracker[c];
          EPcorrnegoddtracker=(1./1.)*atan2(Ycorr_negoddtracker,Xcorr_negoddtracker);
          // if (c==2) std::cout<<Xcorr_negtracker<<" "<<Ycorr_negtracker<<" "<<EPnegtracker<<std::endl;
          if (EPcorrnegoddtracker>(pi)) EPcorrnegoddtracker=(EPcorrnegoddtracker-(TMath::TwoPi()));
          if (EPcorrnegoddtracker<(-1.0*(pi))) EPcorrnegoddtracker=(EPcorrnegoddtracker+(TMath::TwoPi()));
          PsiNOddFirst[c]->Fill(EPcorrnegoddtracker);


          //mid Tracker
          Xcorr_midoddtracker=(X_midoddtracker[c]-Xav_midoddtracker[c])/Xstdev_midoddtracker[c];
          Ycorr_midoddtracker=(Y_midoddtracker[c]-Yav_midoddtracker[c])/Ystdev_midoddtracker[c];
          EPcorrmidoddtracker=(1./1.)*atan2(Ycorr_midoddtracker,Xcorr_midoddtracker);
          if (EPcorrmidoddtracker>(pi)) EPcorrmidoddtracker=(EPcorrmidoddtracker-(TMath::TwoPi()));
          if (EPcorrmidoddtracker<(-1.0*(pi))) EPcorrmidoddtracker=(EPcorrmidoddtracker+(TMath::TwoPi()));
          PsiMOddFirst[c]->Fill(EPcorrmidoddtracker);


          //Zero the angular correction variables

          //v1 even stuff
          AngularCorrectionWholeTracker=0.;EPfinalwholetracker=0.;
          AngularCorrectionPosTracker=0.;EPfinalpostracker=0.;
          AngularCorrectionNegTracker=0.;EPfinalnegtracker=0.;
          AngularCorrectionMidTracker=0.;EPfinalmidtracker=0.;

          //v1 odd stuff
          AngularCorrectionWholeOddTracker=0.;EPfinalwholeoddtracker=0.;
          AngularCorrectionPosOddTracker=0.;EPfinalposoddtracker=0.;
          AngularCorrectionNegOddTracker=0.;EPfinalnegoddtracker=0.;
          AngularCorrectionMidOddTracker=0.;EPfinalmidoddtracker=0.;

          //Compute Angular Corrections
          for (Int_t k=1;k<(jMax+1);k++)
            {
              //v1 even
              //Whole Tracker
              AngularCorrectionWholeTracker+=((2./k)*(((-SineWholeTracker[c][k-1])*(cos(k*EPwholetracker)))+((CosineWholeTracker[c][k-1])*(sin(k*EPwholetracker)))));

              //Pos Tracker
              AngularCorrectionPosTracker+=((2./k)*(((-SinePosTracker[c][k-1])*(cos(k*EPpostracker)))+((CosinePosTracker[c][k-1])*(sin(k*EPpostracker)))));


              //Neg Tracker
              AngularCorrectionNegTracker+=((2./k)*(((-SineNegTracker[c][k-1])*(cos(k*EPnegtracker)))+((CosineNegTracker[c][k-1])*(sin(k*EPnegtracker)))));

              //Mid Tracker
              AngularCorrectionMidTracker+=((2./k)*(((-SineMidTracker[c][k-1])*(cos(k*EPmidtracker)))+((CosineMidTracker[c][k-1])*(sin(k*EPmidtracker)))));

              //v1 odd
              //Whole Tracker
              AngularCorrectionWholeOddTracker+=((2./k)*(((-SineWholeOddTracker[c][k-1])*(cos(k*EPwholeoddtracker)))+((CosineWholeOddTracker[c][k-1])*(sin(k*EPwholeoddtracker)))));

              //Pos Tracker
              AngularCorrectionPosOddTracker+=((2./k)*(((-SinePosOddTracker[c][k-1])*(cos(k*EPposoddtracker)))+((CosinePosOddTracker[c][k-1])*(sin(k*EPposoddtracker)))));


              //Neg Tracker
              AngularCorrectionNegOddTracker+=((2./k)*(((-SineNegOddTracker[c][k-1])*(cos(k*EPnegoddtracker)))+((CosineNegOddTracker[c][k-1])*(sin(k*EPnegoddtracker)))));

              //Mid Tracker
              AngularCorrectionMidOddTracker+=((2./k)*(((-SineMidOddTracker[c][k-1])*(cos(k*EPmidoddtracker)))+((CosineMidOddTracker[c][k-1])*(sin(k*EPmidoddtracker)))));


            }//end of angular correction calculation


          //Add the final Corrections to the Event Plane
          //and store it and do the flow measurement with it


          //Tracker

          //v1 even
          //Whole Tracker
          EPfinalwholetracker=EPcorrwholetracker+AngularCorrectionWholeTracker;
          if (EPfinalwholetracker>(pi)) EPfinalwholetracker=(EPfinalwholetracker-(TMath::TwoPi()));
          if (EPfinalwholetracker<(-1.0*(pi))) EPfinalwholetracker=(EPfinalwholetracker+(TMath::TwoPi()));
          PsiEvenFinal[c]->Fill(EPfinalwholetracker);

          //Pos Tracker
          EPfinalpostracker=EPcorrpostracker+AngularCorrectionPosTracker;
          if (EPfinalpostracker>(pi)) EPfinalpostracker=(EPfinalpostracker-(TMath::TwoPi()));
          if (EPfinalpostracker<(-1.0*(pi))) EPfinalpostracker=(EPfinalpostracker+(TMath::TwoPi()));
          PsiPEvenFinal[c]->Fill(EPfinalpostracker);

          //Neg Tracker
          EPfinalnegtracker=EPcorrnegtracker+AngularCorrectionNegTracker;
          //if(c==2) std::cout<<EPfinalnegtracker<<std::endl;
          if (EPfinalnegtracker>(pi)) EPfinalnegtracker=(EPfinalnegtracker-(TMath::TwoPi()));
          if (EPfinalnegtracker<(-1.0*(pi))) EPfinalnegtracker=(EPfinalnegtracker+(TMath::TwoPi()));
          PsiNEvenFinal[c]->Fill(EPfinalnegtracker);


          //Mid Tracker
          EPfinalmidtracker=EPcorrmidtracker+AngularCorrectionMidTracker;
          if (EPfinalmidtracker>(pi)) EPfinalmidtracker=(EPfinalmidtracker-(TMath::TwoPi()));
          if (EPfinalmidtracker<(-1.0*(pi))) EPfinalmidtracker=(EPfinalmidtracker+(TMath::TwoPi()));
          PsiMEvenFinal[c]->Fill(EPfinalmidtracker);

          //v1 odd
          //Whole Tracker
          EPfinalwholeoddtracker=EPcorrwholeoddtracker+AngularCorrectionWholeOddTracker;
          if (EPfinalwholeoddtracker>(pi)) EPfinalwholeoddtracker=(EPfinalwholeoddtracker-(TMath::TwoPi()));
          if (EPfinalwholeoddtracker<(-1.0*(pi))) EPfinalwholeoddtracker=(EPfinalwholeoddtracker+(TMath::TwoPi()));
          PsiOddFinal[c]->Fill(EPfinalwholeoddtracker);

          //Pos Tracker
          EPfinalposoddtracker=EPcorrposoddtracker+AngularCorrectionPosOddTracker;
          if (EPfinalposoddtracker>(pi)) EPfinalposoddtracker=(EPfinalposoddtracker-(TMath::TwoPi()));
          if (EPfinalposoddtracker<(-1.0*(pi))) EPfinalposoddtracker=(EPfinalposoddtracker+(TMath::TwoPi()));
          PsiPOddFinal[c]->Fill(EPfinalposoddtracker);


          //Neg Tracker
          EPfinalnegoddtracker=EPcorrnegoddtracker+AngularCorrectionNegOddTracker;
          //if(c==2) std::cout<<EPfinalnegtracker<<std::endl;
          if (EPfinalnegoddtracker>(pi)) EPfinalnegoddtracker=(EPfinalnegoddtracker-(TMath::TwoPi()));
          if (EPfinalnegoddtracker<(-1.0*(pi))) EPfinalnegoddtracker=(EPfinalnegoddtracker+(TMath::TwoPi()));
          PsiNOddFinal[c]->Fill(EPfinalnegoddtracker);


          //Mid Tracker
          EPfinalmidoddtracker=EPcorrmidoddtracker+AngularCorrectionMidOddTracker;
          if (EPfinalmidoddtracker>(pi)) EPfinalmidoddtracker=(EPfinalmidoddtracker-(TMath::TwoPi()));
          if (EPfinalmidoddtracker<(-1.0*(pi))) EPfinalmidoddtracker=(EPfinalmidoddtracker+(TMath::TwoPi()));
          PsiMOddFinal[c]->Fill(EPfinalmidoddtracker);


          //Resolutions
          //Even v1
          TRPMinusTRM[c]->Fill(0,cos(EPfinalpostracker-EPfinalnegtracker));
          TRMMinusTRC[c]->Fill(0,cos(EPfinalnegtracker-EPfinalmidtracker));
          TRPMinusTRC[c]->Fill(0,cos(EPfinalpostracker-EPfinalmidtracker));
          //Odd V1
          TRPMinusTRMOdd[c]->Fill(0,cos(EPfinalposoddtracker-EPfinalnegoddtracker));
          TRMMinusTRCOdd[c]->Fill(0,cos(EPfinalnegoddtracker-EPfinalmidoddtracker));
          TRPMinusTRCOdd[c]->Fill(0,cos(EPfinalposoddtracker-EPfinalmidoddtracker));



          //Loop again over tracks to find the flow
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
              //              std::cout<<pT<<" "<<eta<<" "<<phi<<std::endl;
              if(fabs(eta)<0.6 && pT>0.4)
                {
                  V1EtaOdd[c]->Fill(eta,cos(phi-EPfinalwholeoddtracker));
                  if(pT<=3.5) V1EtaEven[c]->Fill(eta,cos(phi-EPfinalwholetracker));
                  V1PtOdd[c]->Fill(pT,cos(phi-EPfinalwholeoddtracker));
                  PTCenters[c]->Fill(pT,pT);
                  V1PtEven[c]->Fill(pT,cos(phi-EPfinalwholetracker));
                }
            }//end of loop over tracks
        }//End of loop over centralities
    }//End of loop over events
}//End of Flow Analysis Function

void FillAngularCorrections(){
}//End of Fill Angular Corrections Function

void FillFlowVectors(){
}//End of fill flowvectors function

+EOF
