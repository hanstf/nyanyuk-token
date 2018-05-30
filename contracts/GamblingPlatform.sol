pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract GamblingPlatform is Ownable {
    using SafeMath for uint256;

    uint256 public maxBet;
    ERC20 public nyanyukToken;

    uint256 public bankBalance;

    uint256 public nonce;

    struct Bet {
        bool isWinning;
        uint diceResult;
        address playerAddress;
        uint256 amountBet;
    }

    Bet[] bets;
    mapping(address => uint256) balances;

    /**
      * @dev player withdrawn and deposited is used to notify the player if withdrawal has succeeded, thus we can send them a message
      */
    event BetResultReleased (address indexed playerAddress, uint256 amount, bool isWinning, uint diceResult);

    /**
      * @dev player withdrawn and deposited is used to notify the player if withdrawal has succeeded, thus we can send them a message
      */
    event PlayerWithdrawn (address indexed playerAddress, uint256 amount);
    event PlayerDeposited (address indexed playerAddress, uint256 amount);

    /**
      * @dev owner deposit and owner withdrawn is used to notify the group that owner just throw money
      */
    event OwnerDeposited (uint256 amount);
    event OwnerWithdrawn (uint256 amount);

    constructor(uint256 _maxBet, ERC20 _nyanyukTokenAddress) public  {
        maxBet = _maxBet;
        nyanyukToken = _nyanyukTokenAddress;
    }

    /**
      * @dev owner deposit token
      * @dev owner has to approve this smart contract address before running this fn with amount respected to the deposited amount
      * @dev it means that owner address has to have nyanyuktoken inside
      * @param _amount the amount owner wanted to deposit
      * @return whether the deposit process has succeeded ?
      */
    function ownerDeposit(uint256 _amount) external onlyOwner() returns (bool) {
        changeNonce();
        require(_amount > 0);
        require(bankBalance.add(_amount) > 0);
        require(nyanyukToken.allowance(msg.sender, address(this)) == _amount);
        require(nyanyukToken.transferFrom(msg.sender, address(this), _amount) == true);

        bankBalance = bankBalance.add(_amount);
        emit OwnerDeposited(_amount);
        return true;
    }

    /**
      * @dev owner withdraw token
      * @dev pretty straight forward, just send the owner address the amount want to withdraw
      * @param _amount the amount owner wanted to withdraw
      * @return whether the withdrawal process has succeeded ?
      */
    function ownerWithdraw(uint256 _amount) external onlyOwner() returns (bool) {
        changeNonce();
        require(_amount > 0);
        require(bankBalance >= _amount);
        require(nyanyukToken.transfer(owner, _amount));
        bankBalance = bankBalance.sub(_amount);
        emit OwnerWithdrawn(_amount);
        return true;
    }

    /**
      * @dev player deposit token
      * @dev almost same as owner deposit
      * @param _amount the amount player wanted to deposit
      * @return whether the deposit process has succeeded ?
      */
    function playerDeposit(uint256 _amount) external returns (bool) {
        changeNonce();
        require(_amount > 0);
        require(balances[msg.sender].add(_amount) > 0);
        require(nyanyukToken.allowance(msg.sender, address(this)) == _amount);
        require(nyanyukToken.transferFrom(msg.sender, address(this), _amount) == true);

        balances[msg.sender] = balances[msg.sender].add(_amount);
        emit PlayerDeposited(msg.sender, _amount);
        return true;
    }

    /**
      * @dev player withdraw token
      * @dev pretty straight forward, just send the owner address the amount want to withdraw
      * @param _amount the amount owner wanted to withdraw
      * @return whether the withdrawal process has succeeded ?
      */
    function playerWithdraw(uint256 _amount) external onlyOwner() returns (bool) {
        changeNonce();
        require(_amount > 0);
        require(balances[msg.sender] >= _amount);
        //since owner only can withdraw bankbalance so player money inside our contract remain untouched
        require(nyanyukToken.transfer(msg.sender, _amount));

        balances[msg.sender] = balances[msg.sender].sub(_amount);
        emit PlayerWithdrawn(msg.sender, _amount);
        return true;
    }

    function getPlayerBalance(address playerAddress) external view returns (uint256) {
        return balances[playerAddress];
    }

    function getBankBalance() external view returns (uint256) {
        return bankBalance;
    }

    /**
      * @dev gambling function
      * @dev recipe = current block + amount + sender address + nonce(every call will add the nonce)
      * @dev if player win, we add their balance if lost add bank balance
      * @param _amount the amount owner wanted to withdraw
      * @return whether the player is winning or not
      */
    function gamble(uint256 _amount) external returns (bool isWinning) {
        changeNonce();

        require(_amount > 0);
        require(_amount < maxBet);

        require(balances[msg.sender] >= _amount);

        //so that bank can have enough amount to pay
        require(bankBalance >= _amount);

        uint8 _diceResult = uint8((uint256(keccak256(block.blockhash(block.number - 1),  _amount, msg.sender, nonce)) % 100) + 1);

        if (_diceResult > 50) {
           //means player win
           isWinning = true;
           balances[msg.sender] = balances[msg.sender].add(_amount);
           bankBalance = bankBalance.sub(_amount);
        } else {
           isWinning = false;
           balances[msg.sender] = balances[msg.sender].sub(_amount);
           bankBalance = bankBalance.add(_amount);
        }

        Bet memory _bet = Bet(isWinning, _diceResult, msg.sender, _amount);
        bets.push(_bet);

        emit BetResultReleased (msg.sender, _amount, isWinning, _diceResult);
    }

    function changeNonce() internal {
        //when nonce overflow it will start again from 0 so we are good to go
        nonce = nonce + 1;
    }
}