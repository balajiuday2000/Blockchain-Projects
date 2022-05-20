// SPDX-License-Identifier: DEats
pragma solidity ^0.7.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import "contracts/Foodie.sol";
contract DEats {
    
    struct Restaurant {
        string name;
        uint256 fund;
    }
    
    struct User {
        string name;
    }
    
    struct DeliveryGuy{
        string name;
        uint256 fund;
    }
    
    struct Order {
        address Customer;
        address Restaurant;
        address DeliveryPerson;
        uint Price;
    }
    
    mapping(address=>Restaurant) public restaurants;
    mapping(address=>DeliveryGuy) public deliveryGuys;
    mapping(address => User) public users;
    
    uint orderid;
    mapping (uint => Order) public orders;
    uint256 deliveryFee = 10;
    uint commissionRate = 5;
    event orderPlaced(uint256 orderId, address customer, address restaurant);
    event orderAccepted(uint256 orderId, address customer, address restaurant);
    event deliveryAccepted(uint256 orderId, address deliverer);
    event orderOut(uint256 orderId, address customer, address restaurant, address deliverer);
    event orderReceived(uint256 orderId, address customer);

    FoodieToken Foodie;
    
    constructor () public {
      Foodie = FoodieToken(0xd9145CCE52D386f254917e481eB44e9943F39138);
  }
    
    function addRestaurant(string memory _name, uint256 _fund) public{
        
        Restaurant memory res = Restaurant(_name,_fund);
        require(res.fund >= 100,"Insufficient funds");
        Foodie.transferFrom(msg.sender, address(this), res.fund);
        restaurants[msg.sender] = res;
    }
    
    function addUser(string memory _name) public {
        
        User memory user = User(_name);
        users[msg.sender] = user;
    }
    
    function addDeliveryGuy(string memory _name, uint256 _fund) public{
        
        DeliveryGuy memory dg = DeliveryGuy(_name,_fund);
        require(dg.fund >= 100,"Insufficient funds");
        Foodie.transferFrom(msg.sender, address(this), dg.fund);
        deliveryGuys[msg.sender] = dg;
        
    }
    
    function PlaceOrder(address _restaurantaddress, uint _amount) public{
        
        orderid++;
        orders[orderid].Customer = msg.sender;
        orders[orderid].Restaurant = _restaurantaddress;
        orders[orderid].Price = _amount;
        Foodie.transferFrom(msg.sender,address(this), (orders[orderid].Price + deliveryFee));
        emit orderPlaced(orderid, orders[orderid].Customer,  orders[orderid].Restaurant);
    }
    
    
    function calculateCommission(uint256 fund) private view returns(uint256){
        
        return (fund/100)* commissionRate;
    }
    
    
    
    function AcceptOrder(uint _orderId) public {
        
        require(orders[_orderId].Restaurant == msg.sender);
        address resaddress = orders[_orderId].Restaurant;
        Restaurant memory res = restaurants[resaddress];
        res.fund = res.fund - calculateCommission((orders[_orderId].Price));
        emit orderAccepted(_orderId, orders[_orderId].Customer,  orders[_orderId].Restaurant);
    }
    
    
    function AcceptDelivery(uint _orderId) public {
        
        orders[_orderId].DeliveryPerson = msg.sender;    
        address dgAddr = orders[_orderId].DeliveryPerson;
        DeliveryGuy memory dg = deliveryGuys[dgAddr];
        dg.fund = dg.fund - calculateCommission((orders[_orderId].Price));
        emit deliveryAccepted(_orderId, orders[_orderId].DeliveryPerson);
    }
    
    
    function OutForDelivery(uint _orderId) public view{

        address resaddress = orders[_orderId].Restaurant;
        require(msg.sender == resaddress);
       
    }
    
    function PickedUp(uint _orderId) public{
        uint resamount = orders[_orderId].Price;
        address resaddress = orders[_orderId].Restaurant;
        require(msg.sender ==  orders[_orderId].DeliveryPerson);
        Foodie.transfer(resaddress, resamount);
        Restaurant memory res = restaurants[resaddress];
        res.fund = res.fund - calculateCommission((orders[_orderId].Price));
        emit orderOut(_orderId, orders[_orderId].Customer,  orders[_orderId].Restaurant,  orders[_orderId].DeliveryPerson);
    }
    

    
    function received(uint _orderId) public{
        
        address deladdress = orders[_orderId].DeliveryPerson;
        require(msg.sender == orders[_orderId].Customer);
        Foodie.transfer(deladdress, 10);
        DeliveryGuy memory dg = deliveryGuys[deladdress];
        dg.fund = dg.fund + calculateCommission((orders[_orderId].Price));
        emit orderReceived(_orderId, orders[_orderId].Customer);
    }
   
    
}