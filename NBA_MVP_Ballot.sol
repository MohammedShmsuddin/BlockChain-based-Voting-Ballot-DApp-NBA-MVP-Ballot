

/**
 * @file NBA_MVP_Ballot.sol
 * @author Mohammed Samsuddin <Mshmsudd@buffalo.edu>
 * @date created 22nd Sept 2019
 * @date last modified 26th Sept 2019
 */

pragma solidity >=0.4.22 <0.6.0;

contract NBA_MVP_Ballot {
    
    // A vote comprises 2 parts, the wallet address of the voter, and the choice he makes. 
    struct vote {
        address voterAddress;
        uint 1st;
        uint 2nd;
        uint 3rd;
        uint 4th;
        uint 5th;
    }
    
    
    // A voter has 2 attributes, his name, and whether or not he has voted.
    struct voter{
        string voterName;
        bool voted;
    }
    
    
    
    // totalVoter is used to track the total number of voters in the voters register and totalVote is used to track the total number of votes cast.
    // I am tracking these numbers as they change when, say, a new vote is cast instead of tallying the votes at the end of the voting process
    // because I am avoiding the need to traverse the mappings (because you can't traverse mappings in Solidity)
    // and I do not wish to use arrays due to the high chance of running into gas limitation issues.
    uint public totalVoter = 0;
    uint public totalVote = 0;
    
    // The ballot official name, wallet address and proposal are kept as public variables for everyone to see. 
    address public ballotOfficialAddress;      
    string public ballotOfficialName;
    string public proposal;
    
    // The ballot contract goes through 3 states.
    // When the chairman creates it, it is in the state of "Created".
    // Once he indicates that voting starts, the ballot contract turns to the state of "Voting".
    // When counting starts, the goes into the state of "Ended". 
    enum State { Created, Voting, Ended }
	State public state;
    
    // voter are stored in a mapping called voterRegister.
    // voterRegister is public so anyone can check who are the eligible voters.
    // One may ask why I wouldn't store my voters in arrays.
    // The challenge with using arrays in an Ethereum blockchain is that you are likely to start running out of gas while trying to traverse the records of a considerably sized array. 
    mapping(address => voter) public voterRegister;
    
    // candidate are stored in a mapping called candidateRegister
    mapping(string => vote) public candidateRegister
    
    
    // Creates a new ballot contract.
	// The official initializes the contract with the constructor by providing his _ballotOfficialName and _proposal.
	// The constructor reads his wallet address and update the ballotOfficialAddress.
	// This is important because folks who might wonder if this is a legitimate ballot can compare what they know is the chairman's wallet address to what is saved here.
	// At this point, the state of the contract is "Created"
	constructor(string memory _ballotOfficialName, string memory _proposal) public {
	    
        ballotOfficialAddress = msg.sender;
        ballotOfficialName = _ballotOfficialName;
        proposal = _proposal;
        state = State.Created;
    }
    
    
    // The onlyOfficial() modifier
    // calling this function is the same address as what is saved in ballotOfficialAddress.
    // This ensures that only the oficial himself is allowed to call the function.
    // In the event that the official denies ever starting the ballot, this will serve as evidence that it was really him, unless someone stole his wallet and private key.
	modifier onlyOfficial() {
		require(msg.sender ==ballotOfficialAddress);
		_;
	}

    // The modifier for inState is declared from lines 78 to 81.
    // It checks to ensure that the contract is currently in the state provided as variable to the inState() modifier.
	modifier inState(State _state) {
		require(state == _state);
		_;
	}
    
    
    // event
    event voterAdded(address voter);
    event voteStarted();
    event voteEnded(uint finalResult);
    event voteDone(address voter);
    
    
    
    
    
    
    
    
    
    // add voter
    // Next, the official add voters to the voterRegister mapping.
    // This involves entering the voter's wallet address and his name into the mapping.
    // Line 104 states that this function is only executable when the contract is in the state of "Created",
    // so that no one, not even the chairman is allowed to add new voters once voting has begun.
    // Lines 104 says onlyOfficial, which means that only the official himself is allowed to run this function. You wouldn't want the voter to be able to add himself to the voterRegister!
    function addVoter(address _voterAddress, string memory _voterName) public inState(State.Created) onlyOfficial {
        voter memory v;
        v.voterName = _voterName;
        v.voted = false;
        voterRegister[_voterAddress] = v;
        totalVoter++;
        emit voterAdded(_voterAddress);
    }
    
    
    
    
    // add candidate
    // Next, the official add candidate to the candidateRegister mapping.
    function addCandidate(string memory _candidateName) public inState(State.Created) onlyOfficial {
        
        
    }






    // declare voting starts now
    function startVoting() public inState(State.Created) onlyOfficial {
        state = State.Voting;     
        emit voteStarted();
    }





    // vote
    function Vote() public inState(State.Voting) {
        bool found = false;
        
        
        emit voteDone(msg.sender);
    }
    
    
    
    
    // 
    function endVoting() public inState(State.Voting) onlyOfficial {
        state = State.Ended;
        emit voteEnded(finalResult);
    }
    
    
    function finalResult() public inState(State.Ended) {
        
    }
    
    
    
    
}   // END OF NBA_MVP_Ballot
