pragma solidity ^0.4.18;
import '../math/SafeMath.sol';
import '../ownership/Ownable.sol';
import './StandardToken.sol';

contract CrowdsaleToken is StandardToken, Ownable {
    using SafeMath for uint256;
    mapping (address => bool) public crowdsales;
    mapping (address => uint256) public waiting;
    uint256 public saled;

    event Sale(address to, uint256 value);
    event Release(address to);
    event Reject(address to);
    event SetCrowdsale(address addr, bool state);

    function setCrowdsale(address _addr, bool _state) onlyOwner public {
        crowdsales[_addr] = _state;
        SetCrowdsale(_addr, _state);
    }

    modifier onlyCrowdsale() {
        require(crowdsales[msg.sender]);
        _;
    }

    function sale(address _to, uint256 _value) public onlyCrowdsale returns (bool) {
        require(_to != address(0));
        assert(saled.add(_value) <= balances[owner]);

        saled = saled.add(_value);
        waiting[_to] = waiting[_to].add(_value);
        Sale(_to, _value);
        return true;
    }

    // send waiting tokens to customer's balance
    function release(address _to) external onlyOwner {
        require(_to != address(0));

        uint256 val = waiting[_to];
        waiting[_to] = 0;
        balances[owner] = balances[owner].sub(val);
        balances[_to] = balances[_to].add(val);
        Release(_to);
    }

    // reject waiting token
    function reject(address _to) external onlyOwner {
        require(_to != address(0));

        saled = saled.sub(waiting[_to]);
        waiting[_to] = 0;

        Reject(_to);
    }
}