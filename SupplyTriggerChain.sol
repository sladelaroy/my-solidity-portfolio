// SPDX-License-Identifier: MIT
pragma solidity 0.8.16; 


contract Owner {
    address public owner;
    constructor () {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "you are not the owner");
        _;
    }

    function isOwner() public view returns(bool) {
        require(owner == msg.sender, "you are not the owner");
        return true;
    }
}

contract ItemPay {
    uint public priceInWei;
    uint public index;
    uint pricePaid;
    ItemSale parentContract;

    constructor(ItemSale _parentContract, uint _priceInWei, uint _itemIndex) {
        priceInWei = _priceInWei;
        index = _itemIndex;
        parentContract = _parentContract;
    }

    receive() external payable { 
        require(pricePaid == 0, "Item has already being paid for");
        require(priceInWei == msg.value, "item has to be paid for in full");

        pricePaid += msg.value;
        (bool success, ) = address(parentContract).call{value:msg.value}(abi.encodeWithSignature("triggerPayment(uint256)", index));
        require(success, "transaction wasn't successful, reverting");
    }

    fallback() external payable { }

}

contract ItemSale is Owner {

    enum SupplyChainState{created, paid, delivered}
    struct S_item {
        ItemPay itemPay;
        string identifier;
        uint itemPrice;
        ItemSale.SupplyChainState state;
    }

    mapping (uint => S_item) public items;
    uint itemIndex;

    event SupplyChainStep(uint itemIndex, uint step, address itemAddress);


    function createItem(string memory _identifier, uint _itemPrice) public onlyOwner {
        ItemPay _item = new ItemPay(this, _itemPrice, itemIndex);
        items[itemIndex].itemPay = _item;
        items[itemIndex].identifier = _identifier;
        items[itemIndex].itemPrice = _itemPrice;
        items[itemIndex].state = SupplyChainState.created;
        itemIndex++;
        emit SupplyChainStep(itemIndex, uint(items[itemIndex].state), address(_item));
    }

    function triggerPayment(uint _itemIndex) public payable {
        require(items[_itemIndex].itemPrice == msg.value, "item has to be paid for in full");
        require(items[_itemIndex].state == SupplyChainState.created, "item is further in the chain");
        items[_itemIndex].state = SupplyChainState.paid;
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex].state), address(items[_itemIndex].itemPay));
    }

    function deliverItem(uint _itemIndex) public {
        require(items[_itemIndex].state == SupplyChainState.paid, "item is further in the chain");
        items[_itemIndex].state = SupplyChainState.delivered;
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex].state), address(items[_itemIndex].itemPay));
    }
}
