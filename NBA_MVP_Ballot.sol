

/**
 * @file NBA_MVP_Ballot.sol
 * @author Mohammed Samsuddin <Mshmsudd@buffalo.edu>
 * @date created 22nd Sept 2019
 * @date last modified 26th Sept 2019
 */

pragma solidity >=0.4.22 <0.6.0;

contract NBA_MVP_Ballot {
    

    // A vote comprises 2 parts, the wallet address of the voter, and the choice he makes. 
    // struct vote {
    //     address voterAddress;
        
    // }
    
    
    // A voter has 2 attributes, his name, and whether or not he has voted.
    struct voter{
        address voter;
        bool hasVoted;
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
    
        Player[5] player;
        uint iter =0;
    // candidate are stored in a mapping called candidateRegister
    // mapping(string => vote) public candidateRegister;
    uint candidateNumber = 0 ;
    mapping(uint => Player)candidateRegister;
    mapping(address => voter) voterRegister;
    mapping(address => preference) votePreference;
    
    
// now say we have 0x9Dd preference 55 11 22 44 10  .. we can match those playerId and increment points based on who placed what 

function registerCandidate(uint _playerId) public returns (uint) {
    if()
        candidateRegister[_playerId] = Player(_playerId, 0, true) ;  //registerCandidate("LBJ")  ...  source: https://solidity.readthedocs.io/en/v0.4.24/types.html
        candidateNumber += 1;  // now that we have a candidate registered , we can increase the counter
        player[iter] = candidateRegister[_playerId];
        iter++;
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
    if(voterRegister[_voterAddress].isRegistered && !(voterRegister[_voterAddress].hasVoted)) {  // verifying that voter is registered
     candidateRegister[pref1].points += 10;                                                     // also that the user hasn't already voted!
     candidateRegister[pref2].points += 7;
     candidateRegister[pref3].points += 5;
     candidateRegister[pref4].points += 3;
     candidateRegister[pref5].points += 1;
    voterRegister[_voterAddress].hasVoted = true;
                                                           //vote!  update players points accordingly
    }
}
    
    
/*

This is a warning not an error. You can ignore it and nothing bad will happen.

However, it is helpfully telling you that since your function doesn't change 
the state, you can mark it as view. See this answer for what that means and why it's a good idea:
source: https://ethereum.stackexchange.com/questions/39561/solidity-function-state-mutability-warning?noredirect=1&lq=1

so it will be fixed if we implement it to our main ballot.sol
*/
function tallyPoints (uint _playerId) public view returns(uint _points){
  if(candidateRegister[_playerId].qualifiedCandidate){
  _points = candidateRegister[_playerId].points;
  }
 return _points;
    // candidateRegister[_playerId].playerId;
}


  function winningProposal() public view returns (uint _winningProposal) {
        uint winningVoteCount = 0;
    
        for (uint prop = 0; prop < player.length; prop++)
            if (player[prop].points > winningVoteCount) {
                winningVoteCount = player[prop].points;
                _winningProposal = player[prop].playerId;
            }
          
    }
    
//  verify that the voter is registered, and if so then record their preference


    
    

    
    
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
    
  

}
