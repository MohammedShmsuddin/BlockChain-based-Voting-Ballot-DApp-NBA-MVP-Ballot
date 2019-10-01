



/**
 * @file NBA_MVP_Ballot.sol
 * @author Mohammed Samsuddin <Mshmsudd@buffalo.edu>
 * @author Taktuk Taktuk      <taktukta@buffalo.edu>
 * @date created 22nd Sept 2019
 * @date last modified 29th Sept 2019
 */

pragma solidity >=0.4.22 <0.6.0;

contract NBA_MVP_Ballot {
    

// -------------------------------------------------------------- Data and Attributes ----------------------------------------------------------------------------------------
    
    
    // A voter has 3 attributes, his address
    // boolean variable hasVoted
    // And boolean variable isRegistered
    struct voter{
        address voterAddress;
        bool hasVoted;
        bool isRegistered;

    }
    

    // a player have 3 attributes
    // an integer variable player ID 
    // an integer variable points
    // an boolean variable isRegistered
    struct Player{
        uint playerId;
        uint points;            // can we update this along the way?
        bool isRegistered;
                
    }
    
    Player[5] player;   // only 5 players are allowed to participate in the election
    uint public candidateNumber = 0 ;   // to keep track of how many candidates there are
    uint public voterNumber = 0 ;   // to keep track of how many voter there are
    uint public totalVote = 0; // total number of vote
    
    // The ballot official name, wallet address and proposal are kept as public variables for everyone to see. 
    address public ballotOfficialAddress; 
    
    uint iter= 0;      //         

    // candidate are stored in a mapping called candidateRegister
    mapping(uint => Player) candidateRegister;  
    
    // voter are stored in a mapping called voterRegister.
    // voterRegister is public so anyone can check who are the eligible voters.
    // One may ask why I wouldn't store my voters in arrays.
    // The challenge with using arrays in an Ethereum blockchain is that you are likely to start running out of gas while trying to traverse the records of a considerably sized array.
    mapping(address => voter) voterRegister;
    
    mapping(address => uint) votePreference;  // for preference.
    
    mapping(uint => uint) candidatePoints;  // i = 0... 4     =>   playerID1 , playerID2, playerID3 ,... playerID5
    
    
    // The ballot contract goes through 3 states.
    // When the chairman creates it, it is in the state of "Created".
    // Once he indicates that voting starts, the ballot contract turns to the state of "Voting".
    // When counting starts, the goes into the state of "Ended". 
    enum State { Created, Voting, Ended }
	State public state;


// -------------------------------------------------------------- Modifiers ----------------------------------------------------------------------------------------

    // The onlyOfficial() modifier
    // calling this function is the same address as what is saved in ballotOfficialAddress.
    // This ensures that only the oficial himself is allowed to call the function.
    // In the event that the official denies ever starting the ballot, this will serve as evidence that it was really him, unless someone stole his wallet and private key.
	modifier onlyOfficial() {
		require(msg.sender == ballotOfficialAddress);
		_;
	}

    // The modifier for inState is declared from lines 89 to 94.
    // It checks to ensure that the contract is currently in the state provided as variable to the inState() modifier.
	modifier inState(State _state) {
		require(state == _state);
		_;
	}


// -------------------------------------------------------------- Events ----------------------------------------------------------------------------------------

    // event
    event voterAdded(address voter);
    event candidateAdded(uint _candidateID);
    event voteStarted();
    event voteEnded(uint finalResult);
    event voteDone(address voter);



// -------------------------------------------------------------- Functions ----------------------------------------------------------------------------------------



    // Creates a new ballot contract.
	// The official initializes the contract with the constructor by providing his _ballotOfficialName and _proposal.
	// The constructor reads his wallet address and update the ballotOfficialAddress.
	// This is important because folks who might wonder if this is a legitimate ballot can compare what they know is the chairman's wallet address to what is saved here.
	// At this point, the state of the contract is "Created"
	constructor() public {
	    
        ballotOfficialAddress = msg.sender;
        state = State.Created;
    }


    // to register such voter, we will locate their voter object and make their instance variable isRegistered to true
    function registerVoter(address _voterAddress) public inState(State.Created) onlyOfficial {
        voter memory v;
        v.voterAddress = _voterAddress;
        v.hasVoted = false;
        v.isRegistered = true;
        voterRegister[_voterAddress] = v;  //voter ( voterId , hasVoted , isRegistered)
        voterNumber++;
        emit voterAdded(_voterAddress);
        
    }
    
    
    
    //candidate means the Player that will be contending for MVP 
    // this function will take in the playerID of candidate and register them accordingdly
    function registerCandidate(uint _playerId) public inState(State.Created) onlyOfficial returns (uint) {
        
        if (candidateNumber > 5) {
             return candidateNumber;
        } else if (candidateNumber <= 5) {
            candidateRegister[_playerId] = Player(_playerId, 0, true) ;  //registerCandidate("LBJ")  ...  source: https://solidity.readthedocs.io/en/v0.4.24/types.html
            candidateNumber++;  // now that we have a candidate registered , we can increase the counter
            candidatePoints[iter] = _playerId;  // pair each number 0...4 with playerID 
            iter++;
            return _playerId;
        }
        emit candidateAdded(_playerId);
    }


    // to unregister such candidate, we will locate their Player object and make their instance variable isRegistered to false
    function unRegisterCandidate(uint _playerId) public inState(State.Created) onlyOfficial returns (uint) {
        //candidateRegister[_playerId] = Player(_playerId, 0, false) ;  //registerCandidate("LBJ")  ...  source: https://solidity.readthedocs.io/en/v0.4.24/types.html
        //candidateNumber--;
            
            
        for (uint i = 0; i <= candidateNumber; i++){
            if(candidateRegister[i].playerId == _playerId){
                player[i] = Player(0,0,false);  // if player exists in player array.. remove it somehow
                candidateNumber--;
            }
        }
           
        return candidateNumber; 
    }

    // to unregister such voter, we will locate their voter object and make their instance variable isRegistered to false
    function unRegisterVoter(address _voterAddress) public inState(State.Created) onlyOfficial {
        voterRegister[_voterAddress] = voter(_voterAddress, false,false);   // hasVoted == false
    }


                            /*
                                1st place - 10 points
                                2nd place - 7 points
                                3rd place - 5 points
                                4th place - 3 points
                                5th place - 1 point
                                
                            */
                                
                                
                                
    // declare voting starts now
    function startVoting() public inState(State.Created) onlyOfficial {
        state = State.Voting;     
        emit voteStarted();
    }
    

    // user will enter playerId of their top preferences
    // the candidates will have their points updated accoridng to the voter's preferences
    function votePlayer(address _voterAddress , uint pref1 , uint pref2, uint pref3, uint pref4, uint pref5) public {
        
        if(voterRegister[_voterAddress].isRegistered && !(voterRegister[_voterAddress].hasVoted)) {  // verifying that voter is registered
            candidateRegister[pref1].points += 10;                                                     // also that the user hasn't already voted!
            candidateRegister[pref2].points += 7;
            candidateRegister[pref3].points += 5;
            candidateRegister[pref4].points += 3;
            candidateRegister[pref5].points += 1;
            voterRegister[_voterAddress].hasVoted = true;
            totalVote++;
                                                               //vote!  update players points accordingly
        }
    
        emit voteDone(msg.sender);
    }
    
    
    
    // End the voting
    function endVoting() public inState(State.Voting) onlyOfficial {
        state = State.Ended;

    }
    
    
    // this is used to collect all the points. We do so by accessing the playerID of the hashmap to get value -> points
    function tallyPoints (uint _playerId) public view inState(State.Ended) returns (uint){
      uint _points = candidateRegister[_playerId].points;
      return _points;
    }
    
    
    // Return the Winner
    function winningProposal() public inState(State.Ended) returns (uint) {
        
        uint256 mostPoints = 0;
        uint winner ; // playerID of player with most points 
        
        for (uint i = 0; i < candidateNumber; i++){
            if (candidateRegister[candidatePoints[i]].points > mostPoints) { // candidate[i] gives u the ID of candidate
                mostPoints = candidateRegister[candidatePoints[i]].points ; // each int .. from 0 to 4 is paired with                                                                  
                winner = candidatePoints[i];
          
            }
        }
        
        emit voteEnded(winner);
        return winner;
    }
    
    
    
    
    
}   // END OF NBA_MVP_Ballot
