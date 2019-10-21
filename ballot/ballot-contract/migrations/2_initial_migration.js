var Ballot = artifacts.require("NBA_MVP_Ballot");
 
module.exports = function(deployer) {
	  deployer.deploy(Ballot,4);
};


