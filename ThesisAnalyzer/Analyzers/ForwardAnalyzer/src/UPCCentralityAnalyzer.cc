#include "Analyzers/ForwardAnalyzer/interface/UPCCentralityAnalyzer.h"
#include "DataFormats/HeavyIonEvent/interface/CentralityBins.h"
#include "DataFormats/HeavyIonEvent/interface/Centrality.h"


using namespace edm;

UPCCentralityAnalyzer::UPCCentralityAnalyzer(const edm::ParameterSet& iConfig):centV(iConfig.getParameter<string>("centralityVariable")){}

UPCCentralityAnalyzer::~UPCCentralityAnalyzer(){}

void UPCCentralityAnalyzer::beginJob(){
	mFileServer->file().SetCompressionLevel(9);
	mFileServer->file().cd();

	string tName(centV+"CentralityTree");	
	CenTree = new TTree(tName.c_str(),tName.c_str());

	CenTree->Branch("CentralityNpart",&cent[0],"NpartMean/D");
	CenTree->Branch("CentralityValue",&cent[1],"centralityValue/D");
	CenTree->Branch("CentralityBin",&centi,"Bin/I");
}

void UPCCentralityAnalyzer::analyze(const edm::Event& iEvent, const edm::EventSetup& iSetup){
	CentProv = new CentralityProvider(iSetup);
	CentProv->newEvent(iEvent,iSetup);
	
	if (!CentProv) CentProv = new CentralityProvider(iSetup);
        CentProv->newEvent(iEvent,iSetup);
        const reco::Centrality* centrality = CentProv->raw();
	
	cent[0]=CentProv->NpartMean();
	cent[1]=CentProv->centralityValue();
	centi=CentProv->getBin();

	CenTree->Fill();
}
