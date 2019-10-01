

/**
 * @file NBA_MVP_Ballot.sol
 * @author Mohammed Samsuddin <Mshmsudd@buffalo.edu>
 * @author Taktuk Taktuk < taktukta @ buffalo.edu > 
 * @date created 22nd Sept 2019
 * @date last modified 26th Sept 2019
 */

pragma solidity >=0.4.22 <0.6.0;

contract NBA_MVP_Ballot {
    
    struct voter{
        address voter;
        bool hasVoted;
        bool isRegistered;

    }
    
            struct Player{
            uint playerId;
            uint points;                                            
            bool isRegistered;
                
    }
    
    // -------------------------------------------------------------------------------
    
    

    uint candidateNumber = 0 ;   // to keep track of how many candidates there are
    uint iter= 0;
    
    mapping(uint => Player)candidateRegister;  // 
    mapping(address => voter) voterRegister;
    mapping(address => uint) votePreference;  // for preference.
    mapping(uint => uint) candidatePoints;  // i = 0... 4     =>   playerID1 , playerID2, playerID3 ,... playerID5

// ------------------------------------------------------------------------------------------------------


 // to register such voter, we will locate their voter object and make their instance variable isRegistered to true
     
function registerVoter(address _voterAddress) public {
    voterRegister[_voterAddress] = voter(_voterAddress, false,true);  //voter ( voterId , hasVoted , isRegistered)
    }
    
    
//candidate means the Player that will be contending for MVP 

// this function will take in the playerID of candidate and register them accordingdly
function registerCandidate(uint _playerId) public returns (uint) {
    if(candidateNumber > 5 ){
         // what if candidates are capped?
    }
        candidateRegister[_playerId] = Player(_playerId, 0, true) ;  //registerCandidate("LBJ")  ...  source: https://solidity.readthedocs.io/en/v0.4.24/types.html
        candidateNumber += 1;  // now that we have a candidate registered , we can increase the counter
        candidatePoints[iter] = _playerId;  // pair each number 0...4 with playerID
        iter += 1;
        return _playerId;
}

// to unregister such candidate, we will locate their Player object and make their instance variable isRegistered to false
function unRegisterCandidate(uint _playerId) public  {
        candidateRegister[_playerId] = Player(_playerId, 0, false) ;  //registerCandidate("LBJ")  ...  source: https://solidity.readthedocs.io/en/v0.4.24/types.html
        candidateNumber -= 1;
        
}

// to unregister such voter, we will locate their voter object and make their instance variable isRegistered to false

function unRegisterVoter(address _voterAddress) public {
    voterRegister[_voterAddress] = voter(_voterAddress, false,false);   // hasVoted == false
    }


    /*
1st place - 10 points
2nd place - 7 points
3rd place - 5 points
4th place - 3 points
5th place - 1 point

*/

// user will enter playerId of their top preferences
// the candidates will have their points updated accoridng to the voter's preferences
function votePlayer(address _voterAddress , uint pref1 , uint pref2, uint pref3, uint pref4, uint pref5) public {
    if(voterRegister[_voterAddress].isRegistered && !(voterRegister[_voterAddress].hasVoted)  ) {  // verifying that voter is registered
     candidateRegister[pref1].points += 10;                                                     // also that the user hasn't already voted!
     candidateRegister[pref2].points += 7;          //also make sure all the candidates are registered
     candidateRegister[pref3].points += 5;
     candidateRegister[pref4].points += 3;
     candidateRegister[pref5].points += 1;
    voterRegister[_voterAddress].hasVoted = true;
                                                           //vote!  update players points accordingly
    }
}
    
// this is used to collect all the points. We do so by accessing the playerID of the hashmap to get value -> points
function tallyPoints (uint _playerId) public view returns(uint _points){
    if(candidateRegister[_playerId].isRegistered){
  _points = candidateRegister[_playerId].points;
    }
 return _points;
}

//this function is not working yet
  function winningProposal() public view returns (uint) {
        uint256 mostPoints = 0;
        uint winner ; // playerID of player with most points 
        for (uint i = 0; i < candidateNumber; i++){
            if (candidateRegister[candidatePoints[i]].points > mostPoints) { // candidate[i] gives u the ID of candidate
                mostPoints = candidateRegister[candidatePoints[i]].points ; // each int .. from 0 to 4 is paired with 
                                                                                //value playerID
                winner = candidatePoints[i];
          
            }
 
            
            
        }
            
            return winner;
    }
    
    
  }
