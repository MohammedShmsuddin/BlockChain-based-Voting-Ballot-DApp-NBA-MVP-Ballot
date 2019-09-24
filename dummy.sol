

/**
 * @file NBA_MVP_Ballot.sol
 * @author Mohammed Samsuddin <Mshmsudd@buffalo.edu>
 * @date created 22nd Sept 2019
 * @date last modified 26th Sept 2019
 */

pragma solidity >=0.4.22 <0.6.0;

contract NBA_MVP_Ballot {
    
    
    
// have a function that will initialize the five MVP canditdates

    


    // A vote comprises 2 parts, the wallet address of the voter, and the choice he makes. 
    struct vote {
        address voterAddress;
        
    }
    
    //  getVote ... parse ... 
    


   
  
  
//   function votePlayer(Player first,Player second, Player third,Player fourth,Player fifth) public {
      
      
//      // voter enters preference 
     
//   }
    
    // A voter has 2 attributes, his name, and whether or not he has voted.
    struct voter{
     address voter;
        bool isVoted;
        bool isRegistered;
        
    }
    
    struct preference{ 
        uint playerIdOne;  //player ID of first preference in voter's CHOICE 
        uint playerIdTwo;
        uint playerIdThree;
        uint playerIdFour;
        uint playerIdFive;
    }
    
    
    struct Player{
    uint playerId;
    uint points;                                             // can we update this along the way?
    bool qualifiedCandidate;
        
    }
    //Player(55 , 0 )
    // voter 
    
    
    // candidate are stored in a mapping called candidateRegister
    // mapping(string => vote) public candidateRegister;
    uint candidateNumber = 0 ;
    mapping(uint => Player)candidateRegister;
    mapping(address => voter) voterRegister;
    mapping(address => preference) votePreference;
// now say we have 0x9Dd preference 55 11 22 44 10  .. we can match those playerId and increment points based on who placed what 

function registerCandidate(uint _playerId) public returns (uint) {
        candidateRegister[_playerId] = Player(_playerId, 0, true) ;  //registerCandidate("LBJ")  ...  source: https://solidity.readthedocs.io/en/v0.4.24/types.html
        candidateNumber += 1;  // now that we have a candidate registered , we can increase the counter
        return _playerId;
}
      
      
function registerVoter(address _voterAddress) public {
    //  registerVoter[_voterAddress] = voter(_voterAddress,false);
    //  v = voter(_voterAddress , false, true );
    voterRegister[_voterAddress] = voter(_voterAddress, false,true);
    }
    /*
1st place - 10 points
2nd place - 7 points
3rd place - 5 points
4th place - 3 points
5th place - 1 point

*/

// user will enter playerId of their top preferences

function votePlayer(address _voterAddress , uint pref1 , uint pref2, uint pref3, uint pref4, uint pref5) public {
    if(voterRegister[_voterAddress].isRegistered){  // verifying that voter is registered
     candidateRegister[pref1].points += 10;
     candidateRegister[pref2].points += 7;
                                      //vote!  update players points accordingly
    }
}
    
    


function tallyPoints (uint _playerId) public returns(uint){
   if(candidateRegister[_playerId].qualifiedCandidate){
   return candidateRegister[_playerId].points;
   } 
  return 0;
    // candidateRegister[_playerId].playerId;
}
    
//  verify that the voter is registered, and if so then record their preference


    
        
     
    
    //first make sure Voter is registered...
    // use voter's address to vote
    //   function voteCandidate( address _addressOfVoter,string memory firstpick,  string memory secondpick,string memory thirdpick,string memory fourthpick,string memory fifthpickr ) public inState(State.Created) onlyOfficial {
   
    // candidateRegister[_candidateName] = Player(PICK PLAYER NAME , POINTS )
   
   
    // }

    
    
    // add voter
    // Next, the official add voters to the voterRegister mapping.
    // This involves entering the voter's wallet address and his name into the mapping.
    // Line 104 states that this function is only executable when the contract is in the state of "Created",
    // so that no one, not even the chairman is allowed to add new voters once voting has begun.
    // Lines 104 says onlyOfficial, which means that only the official himself is allowed to run this function. You wouldn't want the voter to be able to add himself to the voterRegister!
    // function addVoter(address _voterAddress, string memory _voterName) public inState(State.Created) onlyOfficial {
    //     voter memory v;
    //     v.voterName = _voterName;
    //     v.voted = false;
    //     voterRegister[_voterAddress] = v;
    //     totalVoter++;
    //     emit voterAdded(_voterAddress);
    // }
    
    
    
    
    // add candidate
    // Next, the official add candidate to the candidateRegister mapping.
  
// addCandidate("Giannis Antetekounmpo")

}
