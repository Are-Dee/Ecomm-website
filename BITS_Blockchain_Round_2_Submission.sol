// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract shoppy {

    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    event ProductPurchased(address indexed buyer, string productId, uint purchaseId, uint amountPaid);

    uint id;
    uint purchaseId;

    struct seller {
        string name;
        address addr;
        uint bankGuarantee;
        bool bgPaid;
    }

    struct product {
        string productId;
        string productName;
        string Category;
        uint price;
        string description;
        address payable seller;
        bool isActive;
    }

    struct ordersPlaced {
        string productId;
        uint purchaseId;
        address orderedBy;
    }

    struct sellerShipment {
        string productId;
        uint purchaseId;
        string shipmentStatus;
        string deliveryAddress;
        address payable orderedBy;
        bool isActive;
        bool isCanceled;
    }

    struct user {
        string name;
        string email;
        string deliveryAddress;
        bool isCreated;
    }

    struct orders {
        string productId;
        string orderStatus;
        uint purchaseId;
        string shipmentStatus;
    }

    mapping(address => seller) public sellers;
    mapping(string => product) products;
    product[] public allProducts;
    mapping(address => ordersPlaced[]) sellerOrders;
    mapping(address => mapping(uint => sellerShipment)) sellerShipments;
    mapping(address => user) users;
    mapping(address => orders[]) userOrders;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    function sellerSignUp(string memory _name) public payable {
        require(!sellers[msg.sender].bgPaid, "You are Already Registered");
        require(msg.value == 5 ether, "Bank Guarantee of 5ETH Required");
        owner.transfer(msg.value);
        sellers[msg.sender].name = _name;
        sellers[msg.sender].addr = msg.sender;
        sellers[msg.sender].bankGuarantee = msg.value;
        sellers[msg.sender].bgPaid = true;
    }

    function createAccount(string memory _name, string memory _email, string memory _deliveryAddress) public {
        users[msg.sender].name = _name;
        users[msg.sender].email = _email;
        users[msg.sender].deliveryAddress = _deliveryAddress;
        users[msg.sender].isCreated = true;
    }


    function purchaseItems(string[] memory _productIds) public payable {
        require(_productIds.length > 0, "At least one product ID must be provided.");

        uint totalAmount = 0;

        for (uint i = 0; i < _productIds.length; i++) {
            require(products[_productIds[i]].isActive, "Invalid product ID or product is not active.");
            require(products[_productIds[i]].price > 0, "Product price must be greater than zero.");

            totalAmount += products[_productIds[i]].price;
        }

        require(msg.value >= totalAmount, "Insufficient funds to purchase items.");

        for (uint i = 0; i < _productIds.length; i++) {
            products[_productIds[i]].seller.transfer(products[_productIds[i]].price);
            purchaseId = id++;
            orders memory order = orders(_productIds[i], "Order Placed With Seller", purchaseId, sellerShipments[products[_productIds[i]].seller][purchaseId].shipmentStatus);
            userOrders[msg.sender].push(order);
            ordersPlaced memory ord = ordersPlaced(_productIds[i], purchaseId, msg.sender);
            sellerOrders[products[_productIds[i]].seller].push(ord);

            sellerShipments[products[_productIds[i]].seller][purchaseId].productId = _productIds[i];
            sellerShipments[products[_productIds[i]].seller][purchaseId].orderedBy = payable(msg.sender);
            sellerShipments[products[_productIds[i]].seller][purchaseId].purchaseId = purchaseId;
            sellerShipments[products[_productIds[i]].seller][purchaseId].deliveryAddress = users[msg.sender].deliveryAddress;
            sellerShipments[products[_productIds[i]].seller][purchaseId].isActive = true;
        }

        
        emit ProductPurchased(msg.sender, _productIds[0], purchaseId, totalAmount);
    }

    function withdrawETH(uint amount) public payable onlyOwner {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(address(this).balance >= amount, "Insufficient balance to withdraw");

        owner.transfer(amount);
    }

    function addProduct(string memory _productId, string memory _productName, string memory _category, uint _price, string memory _description) public {
        require(sellers[msg.sender].bgPaid, "You are not Registered as Seller");
        require(!products[_productId].isActive, "Product With this Id is already Active. Use other UniqueId");

        product memory newProduct = product(_productId, _productName, _category, _price, _description, payable(msg.sender), true);
        products[_productId] = newProduct;
        allProducts.push(newProduct);
    }

    function filterByPrice(uint _minPrice, uint _maxPrice) public view returns (product[] memory) {
    require(_minPrice <= _maxPrice, "Invalid price range");

    uint count = 0;
    for (uint i = 0; i < allProducts.length; i++) {
        if (allProducts[i].price >= _minPrice && allProducts[i].price <= _maxPrice) {
            count++;
        }
    }

    product[] memory filteredProducts = new product[](count);

    count = 0;
    for (uint i = 0; i < allProducts.length; i++) {
        if (allProducts[i].price >= _minPrice && allProducts[i].price <= _maxPrice) {
            filteredProducts[count] = allProducts[i];
            count++;
        }
    }

        return filteredProducts;
    }


    function cancelOrder(string memory _productId, uint _purchaseId) public payable {
        require(sellerShipments[products[_productId].seller][_purchaseId].orderedBy == msg.sender, "You are not Authorized to This Product PurchaseId");
        require(sellerShipments[products[_productId].seller][purchaseId].isActive, "You Already Canceled This order");

        sellerShipments[products[_productId].seller][_purchaseId].shipmentStatus = "Order Canceled By Buyer, Payment will Be Refunded";
        sellerShipments[products[_productId].seller][_purchaseId].isCanceled = true;
        sellerShipments[products[_productId].seller][_purchaseId].isActive = false;
    }

    function updateShipment(uint _purchaseId, string memory _shipmentDetails) public {
        require(sellerShipments[msg.sender][_purchaseId].isActive, "Order is either inActive or cancelled");

        sellerShipments[msg.sender][_purchaseId].shipmentStatus = _shipmentDetails;
    }

    function refund(string memory _productId, uint _purchaseId) public payable {
        require(sellerShipments[msg.sender][_purchaseId].isCanceled, "Order is not Yet Cancelled");
        require(!sellerShipments[products[_productId].seller][purchaseId].isActive, "Order is Active and not yet Cancelled");
        require(msg.value == products[_productId].price, "Value Must be Equal to Product Price");

        sellerShipments[msg.sender][_purchaseId].orderedBy.transfer(msg.value);
        sellerShipments[products[_productId].seller][_purchaseId].shipmentStatus = "Order Canceled By Buyer, Payment Refunded";
    }

    function myOrders(uint _index) public view returns (string memory, string memory, uint, string memory) {
        return (userOrders[msg.sender][_index].productId, userOrders[msg.sender][_index].orderStatus, userOrders[msg.sender][_index].purchaseId, sellerShipments[products[userOrders[msg.sender][_index].productId].seller][userOrders[msg.sender][_index].purchaseId].shipmentStatus);
    }

    function getOrdersPlaced(uint _index) public view returns (string memory, uint, address, string memory) {
        return (sellerOrders[msg.sender][_index].productId, sellerOrders[msg.sender][_index].purchaseId, sellerOrders[msg.sender][_index].orderedBy, sellerShipments[msg.sender][sellerOrders[msg.sender][_index].purchaseId].shipmentStatus);
    }

    function getShipmentDetails(uint _purchaseId) public view returns (string memory, string memory, address, string memory) {
        return (sellerShipments[msg.sender][_purchaseId].productId, sellerShipments[msg.sender][_purchaseId].shipmentStatus, sellerShipments[msg.sender][_purchaseId].orderedBy, sellerShipments[msg.sender][_purchaseId].deliveryAddress);
    }
}
