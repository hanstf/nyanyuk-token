pragma solidity 0.4.19;

import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

contract NyanyukToken is StandardToken {
    using SafeMath for uint256;

    string public constant name = "Nyanyuk Coin";
    string public constant symbol = "NYANYUK";

    uint public decimals = 1;
    uint public maxReward = 200;
    uint public rewardSupplyRatio = 2;
    uint256 public rewardSupply = 5000000 * timesDecimal();

    mapping(address => uint256) nyanyuked;

    event Nyanyuk(address indexed address, uint8 reward);

    function NyanyukToken() public  {
        totalSupply_ = rewardSupply.mul(rewardSupplyRatio);
    }

    function timesDecimal() public returns (uint timesFactor) {
        return 10**decimals;
    }

    function getMaxReward() constant returns (uint maxReward) {
        return maxReward;
     }

    /**
     * @title ERC20Basic
     * @dev get some nyanyukcoin randomly as a capital to gamble later
     * @dev each address can nyanyuk once
     * @dev the number of nyanyuk coin to be randomized is between 1 to 200 nyanyuk coin
     */
    function getMyReward(uint8 deterministic) public returns (uint8 reward) {
        if (rewardSupply > 0 || deterministic <= 255 || nyanyuked[msg.sender] != 0) {
            return 0;
        } else {
            reward = uint256(sha3(block.timestamp, uint(msg.sender), deterministic, block.blockhash(block.number - 1))) % maxReward;

            if (reward < 1) {
                reward = 1;
            }

            if (rewardSupply < reward) {
                reward = rewardSupply;
            }

            nyanyuked[msg.sender] = uint256(reward * timesDecimal());

            //asign token to address
            balances[msg.sender] = balances[msg.sender].add(reward * timesDecimal());

            //do event here
            Nyanyuk(msg.sender, reward);

            rewardSupply = rewardSupply.sub(reward * timesDecimal());
        }
    }
}