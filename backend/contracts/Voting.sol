//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";
error cannot_add_new_candidate_voting_on_going_or_closed();
error candidate_already_exist_we_cannot_add_him_again();
error cannot_add_new_voter_voting_on_going();
error voter_already_exist_we_cannot_add_him_again();
error voting_is_not_ongoing();
error voter_not_exist_or_already_Voted();
error candidate_not_exist();
error cannot_start_voting_its_has_been();
error voting_is_not_closed_yet();

// functionality needed
// Add Candidates ( name, id)
// cast Vote ( vote candidate by their ID)
// Query Vote: Who has recieved how much
contract Voting is Ownable {
    enum State {
        REGISTRATION,
        ONGOING,
        CLOSED
    }
    State private state;
    // Voter Detail Storage
    address[] voters;
    struct Voter {
        string name;
        bool voted;
        bool registered;
    }
    mapping(address => Voter) addressToVoter;

    // Candidate Detail Storage
    address[] candidates;
    struct Candidate {
        string name;
        uint id;
        uint total_vote;
        bool exist;
    }
    mapping(address => Candidate) addressToCandidate;
    mapping(uint256 => address) idToCandidateAddress;
    // voting details storage
    mapping(address => Candidate) voterToCandidate;
    mapping(address => uint256) candidateToNumVotes;
    uint256 totalPeopleVoted;

    constructor() Ownable(msg.sender) {
        state = State.REGISTRATION;
        totalPeopleVoted = 0;
    }

    function addCandidate(
        address _candidateAddress,
        string memory _name,
        uint256 _id
    ) public onlyOwner {
        if (state != State.REGISTRATION)
            revert cannot_add_new_candidate_voting_on_going_or_closed();
        if (!addressToCandidate[_candidateAddress].exist)
            revert candidate_already_exist_we_cannot_add_him_again();
        candidates.push(_candidateAddress);
        Candidate memory new_Candidate = Candidate(_name, _id, 0, true);
        idToCandidateAddress[_id] = _candidateAddress;
        addressToCandidate[_candidateAddress] = new_Candidate;
    }

    function addVoter(
        address _voterAddress,
        string memory _name
    ) public onlyOwner {
        if (state == State.ONGOING)
            revert cannot_add_new_voter_voting_on_going();
        if (addressToVoter[_voterAddress].registered)
            revert voter_already_exist_we_cannot_add_him_again();
        voters.push(_voterAddress);
        addressToVoter[_voterAddress] = Voter(_name, false, true);
    }

    function voteTo(address _voterAddress, uint256 _id) public {
        if (state != State.ONGOING) revert voting_is_not_ongoing();
        if (
            (!addressToVoter[_voterAddress].registered) ||
            (addressToVoter[_voterAddress].voted)
        ) revert voter_not_exist_or_already_Voted();
        if (idToCandidateAddress[_id] == address(0))
            revert candidate_not_exist();
        address _candidateAddress = idToCandidateAddress[_id];
        addressToCandidate[_candidateAddress].total_vote++;
        totalPeopleVoted += 1;
        addressToVoter[_voterAddress].voted = true;
    }

    function query(uint256 _id) public returns (uint256) {
        return addressToCandidate[idToCandidateAddress[_id]].total_vote;
    }

    function startVoting() public onlyOwner {
        if (state == State.CLOSED) revert cannot_start_voting_its_has_been();
        state = State.ONGOING;
    }

    function stopVoting() public onlyOwner {
        state = State.CLOSED;
    }

    function resetVoting() public {
        if (state == State.CLOSED) revert voting_is_not_closed_yet();
        totalPeopleVoted = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            addressToCandidate[candidates[i]].total_vote = 0;
        }
        for (uint256 i = 0; i < voters.length; i++) {
            addressToVoter[voters[i]].voted = false;
        }
    }
}
