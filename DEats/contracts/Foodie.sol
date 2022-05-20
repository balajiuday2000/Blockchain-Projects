// SPDX-License-Identifier: DEats
pragma solidity ^0.7.0;
 
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
 
contract FoodieToken is ERC20 {
    address owner;
    constructor() ERC20("Foodie", "FOD") public {
        _mint(msg.sender, 21000000);
        owner = msg.sender;
    }
    
    function approveContract(address recipient, uint value)external{
        approve(recipient,value);
    }
    
    function returnOwner() public view returns(address _owner){
        return owner;
    }
}