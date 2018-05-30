pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract NyanyukToken is StandardToken, Ownable {
    using SafeMath for uint256;

    string public constant name = "Nyanyuk Coin";
    string public constant symbol = "NYANYUK";

    uint256 public rewardSupply = 5000000;
    uint public decimals = 0;
    uint public defaultMaxPossibleReward = 200; // default max reward to get from lottery
    uint public rewardToTotalSupplyRatio = 2;

    bool public isTokenSentToOwner = false;

    struct Ticket {
        bool isUsed;
        uint rewardReceived;
        address ownerAddress;
        uint maxPossibleReward;
        uint expiryDate;
    }

    mapping(bytes32 => Ticket) tickets;
    mapping(address => bytes32[]) addressTickets;

    uint256 ticketLength;

    event RewardReceived(address indexed rewardReceiver, bytes32 ticketId, uint8 reward);
    event TicketCreated(address indexed rewardReceiver, bytes32 indexed ticketId);

    function timesDecimal() public view returns (uint) {
        return 10**decimals;
    }

    function getRewardSupplyInSmallestUnit() public view returns (uint256) {
        return rewardSupply * timesDecimal();
    }

    constructor(uint256 _rewardSupply, uint _defaultMaxPossibleReward, uint _rewardToTotalSupplyRatio) public  {
        if (_rewardSupply != 0) {
            rewardSupply = _rewardSupply * timesDecimal();
        }
        if (_defaultMaxPossibleReward != 0) {
            defaultMaxPossibleReward = _defaultMaxPossibleReward;
        }
        if (_rewardToTotalSupplyRatio  != 0) {
            rewardToTotalSupplyRatio = _rewardToTotalSupplyRatio;
        }
        totalSupply_ = rewardSupply.mul(rewardToTotalSupplyRatio);
     }

    /**
     * @dev valid ticket criterias:
     * @dev - valid ticket
     * @dev - ticket owner = msg.sender
     * @dev - ticket has not being used
     * @dev - ticket has not been expired
     */
    modifier onlyValidTicket(bytes32 _ticketId) {
        Ticket memory ticket = tickets[_ticketId];
        require(ticket.ownerAddress != address(0));
        require(ticket.ownerAddress == msg.sender);
        require(ticket.isUsed == false);
        require(ticket.expiryDate >= now);
        _;
    }

    /**
     * @dev get tickets owned by an address
     * @param _ticketReceiver address representing the address in which we wanted to get the tickets
     * @return list of tickets particular address owned
     */
     function getTickets(address _ticketReceiver) public view returns (bytes32[]) {
        return addressTickets[_ticketReceiver];
     }

    /**
     * @dev get details of the ticket from ticket id
     * @param _ticketId bytes32 representing ticket id in hash
     * @return destructured ticket
     */
     function getTicketDetails(bytes32 _ticketId) public view returns (bool, uint, address, uint, uint) {
        return (tickets[_ticketId].isUsed, tickets[_ticketId].rewardReceived, tickets[_ticketId].ownerAddress, tickets[_ticketId].maxPossibleReward, tickets[_ticketId].expiryDate);
     }

    /**
     * @dev used by the owner to generate ticket for a particular address with hash as key
     * @param _ticketReceiver address representing address of this ticket will belong to
     * @param _maxPossibleReward uint representing maximum possible rewards particular address can receive
     * @param _expiryDate uint representing expiry date of the ticket
     */
    function createTicket(address _ticketReceiver, uint _maxPossibleReward, uint _expiryDate) external onlyOwner returns (bytes32 _ticketId) {
        require(_ticketReceiver != address(0));
        uint maxPossibleReward = defaultMaxPossibleReward;
        if (_maxPossibleReward > 0) {
            maxPossibleReward = _maxPossibleReward;
        }
        uint expiryDate = now + (7 * 24 * 60 * 60);
        if (_expiryDate > 0) {
            //by default set expiry date as 1 week after
            expiryDate = _expiryDate;
        }
        ticketLength++;

        Ticket memory newTicket = Ticket(false, 0, _ticketReceiver, maxPossibleReward, expiryDate);
        _ticketId = keccak256(_ticketReceiver, maxPossibleReward, expiryDate, ticketLength);
        tickets[_ticketId] = newTicket;


        //store the tickets into that address
        addressTickets[_ticketReceiver].push(_ticketId);

        emit TicketCreated(msg.sender, _ticketId);
    }

    /**
     * @dev get some nyanyukcoin randomly
     * @dev each ticket can only be used for this function once
     * @dev the number of nyanyuk coin to be randomized is between given max possible reward of a ticket
     * @dev only the owner of the ticket can call this
     * @param _ticketId bytes32 representing the ticket id to redeem
     */
    function getMyReward(bytes32 _ticketId) external onlyValidTicket(_ticketId) returns (uint8 _reward) {
        require(rewardSupply > 0);
        Ticket memory ticket = tickets[_ticketId];
        _reward = uint8(uint256(keccak256(block.timestamp, uint(msg.sender), block.blockhash(block.number - 1), _ticketId)) % ticket.maxPossibleReward);

        if (_reward < 1) {
            _reward = 1;
        }

        if (rewardSupply < uint256(_reward)) {
            // since it is lower than reward supply so we assume we can convert supply as uint8
            _reward = uint8(rewardSupply);
        }

        tickets[_ticketId].isUsed = true;
        tickets[_ticketId].rewardReceived = _reward;

        //asign token to address in cents
        balances[msg.sender] = balances[msg.sender].add(uint256(_reward * timesDecimal()));

        //do event here
        emit RewardReceived(msg.sender, _ticketId, _reward);

        // in nyanyuk
        rewardSupply = rewardSupply.sub(uint256(_reward));
    }

    /**
     * @dev send token to owner
     */
    function sendToOwner() external onlyOwner() returns (bool success) {
        require(isTokenSentToOwner == false);
        balances[msg.sender] = balances[msg.sender].add(totalSupply_.sub(rewardSupply));
        isTokenSentToOwner = true;
        success = true;
    }
}