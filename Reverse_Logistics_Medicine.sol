pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./Processes_medicine.sol";
import "./Stakeholders.sol";


contract Reverse_Logistics_Medicine{

    
    struct Product {
        uint id;
        string name;
        uint quantity;
        string others;  
        uint numberoftraces;
        uint numberofcomponents;
        uint [] tracesProduct; // το ID της ιχνηλάτισης
        uint [] componentsProduct;
        address maker; // αυτός που ενημερώνει το σύστημα
        string globalId; 
        bytes32 hashIPFS; // περιγραφή κατασκευής (σειριακός αριθμός)
        bool ship_ready; // ένδειξη ολοκλήρωσης και ετοιμότητας προς αποστολή
    }
    
    mapping(uint => Product) private products;

    struct Trace {
        uint id;
        uint id_product;
        string location;
        string temp_owner; // ο διανομέας ή το εργαστήριο ανακατασκευής
        uint timestamp;
        address maker; // αυτός που ενημερώνει το σύστημα
    }

    mapping(uint => Trace) private traces;
    

    uint private productsCount;
    uint private tracesCount;


    //καθορισμός των διευθύνσεων των εμπλεκόμενων μερών
    address constant public customer = 0xE0f5206BBD039e7b0592d8918820024e2a7437b9;
    address constant public wholesaler = 0xE0F5206bbd039E7B0592D8918820024E2a743445;
    address constant public distributor = 0xE0F5206bbd039e7b0592d8918820024E2A743222;
    address constant public manufacturer = 0x50e00dE2c5cC4e456Cf234FCb1A0eFA367ED016E;
    address constant public govermment = 0x1533234Bd32f59909E1D471CF0C9BC80C92c97d2;
    address constant public refurbisher = 0x395BE1C1Eb316f82781462C4C028893e51d8b2a5;

    bool private  triggered;
    bool private  delivery;
    bool private  received;
    
    event triggeredEvent (); // Αποδοχή νέας παραγγελίας
    event deliveryEvent ();
    event receivedEvent ();
    event updateEvent ();


    constructor () public { // Δημιουργούμε μια παραγγελία. Ο αύξων αριθμός ξεκινάει με id=1
        addProduct("Example",200, "Delivey in 3 days","5400AA","ADDeFFtt45045594xxE3948");
        addTrace(1,"some coordinates", "name or address of actual owner",1573564413);
        triggered=false;
        delivery=false;
        received=false;
    }

    // ΛΕΙΤΟΥΡΓΙΕΣ ΣΧΕΤΙΚΑ ΜΕ ΤΟ ΠΡΟΪΟΝ

    function addProduct (string memory _name, uint _quantity, string memory _others, string memory _globalID, bytes32 _hashIpfs) private {
        //require(msg.sender==vendor);
        require(keccak256(abi.encodePacked((_name))) == keccak256(abi.encodePacked(("Type-A"))) ||
                keccak256(abi.encodePacked((_name))) == keccak256(abi.encodePacked(("Type-B"))) ||
                keccak256(abi.encodePacked((_name))) == keccak256(abi.encodePacked(("Type-C"))));

        productsCount ++; // Προσθέτει τον αύξοντα αριθμό όπου αντιπροσωπέυει το ID 
        products[productsCount].id = productsCount; 
        products[productsCount].name = _name;
        products[productsCount].quantity = _quantity;
        products[productsCount].others = _others;
        products[productsCount].numberoftraces = 0;
        products[productsCount].numberofcomponents = 0; 
        products[productsCount].maker = msg.sender;
        products[productsCount].globalId = _globalID;
        products[productsCount].hashIPFS = _hashIpfs;
    }

    
    function getNumberOfProducts () public view returns (uint){
        //require(msg.sender==customer || msg.sender==wholesaler || msg.sender==distributor);
        
        return productsCount;
    }

    function UpdateProduct (uint _productId, string memory _others) public { 
        ///require(msg.sender==wholesaler || msg.sender==distributor);
        require(_productId > 0 && _productId <= productsCount); 

        products[_productId].others = _others;  // αλλαγή κατάστασης
        emit updateEvent();
    }

    // Έλεγχος για το περιεχόμενο του συμβολαίου
    function getProduct (uint _productId) public view returns (Product memory) {
        //require(msg.sender==wholesaler || msg.sender==customer);
        require(_productId > 0 && _productId <= productsCount); 

        return products[_productId];
    }

    function getProductGlobalID (uint _productId) public view returns (string memory) {
        //require(msg.sender==customer);
        require(_productId > 0 && _productId <= productsCount); 

        return products[_productId].globalId;
    }

      function getProductHistoric (uint _productId) public view returns (bytes32) {
        //require(msg.sender==customer);
        require(_productId > 0 && _productId <= productsCount); 

        return products[_productId].hashIPFS;
    }
    
    // ΛΕΙΤΟΥΡΓΙΕΣ ΣΧΕΤΙΚΑ ΜΕ ΤΗΝ ΙΧΝΗΛΑΤΙΣΗ

    function addTrace (uint _productId, string memory _location, string memory _temp_owner, uint _timestamp) public {
        //require(msg.sender==wholesaler || msg.sender==distributor);
        require(_productId > 0 && _productId <= productsCount);
        
        tracesCount ++; // Προσθέτει τον αύξοντα αριθμό όπου αντιπροσωπέυει το ID
        traces[tracesCount] = Trace(tracesCount, _productId, _location,_temp_owner,_timestamp,msg.sender);
        products[_productId].tracesProduct.push(tracesCount);
        products[_productId].numberoftraces++;        
        emit updateEvent();
    }

    function getNumberOfTraces () public view returns (uint) {
        //require(msg.sender==customer || msg.sender==wholesaler || msg.sender==distributor);        
        return tracesCount;
    }

    function getTrace (uint _traceId) public view returns (Trace memory)  {
        //require(msg.sender==customer );
        require(_traceId > 0 && _traceId <= tracesCount); 
        return traces[_traceId];
    }

    function getNumberOfTracesProduct (uint _productId) public view returns (uint) {
        //require(msg.sender==customer || msg.sender==wholesaler || msg.sender==distributor);
        require(_productId > 0 && _productId <= productsCount);   
        return products[_productId].numberoftraces;
    }

    function getTracesProduct (uint _productId) public view returns (uint [] memory)  {
        //require(msg.sender==customer );
        require(_productId > 0 && _productId <= productsCount);
        return products[_productId].tracesProduct;
    }

    function retrieveHashProduct (uint _productId) public view returns (bytes32){ 
        //computehash according to unique characteristics
        // hash has to identify a unique transaction so timestamp and locations and products should be used.
        // this example hashes a transaction as a whole.
        return keccak256(abi.encodePacked(block.number,msg.data, products[_productId].id, products[_productId].name, products[_productId].quantity, products[_productId].others, products[_productId].numberoftraces, products[_productId].numberofcomponents, products[_productId].maker));
    }

    function triggerContract () public { 
        //require(msg.sender==customer);
        triggered=true;
        emit triggeredEvent();
    }

    function deliverOrder () public { 
        //require(msg.sender==wholesaler);
        delivery=true;
        emit deliveryEvent();
    }

    function receivedOrder () public { 
        //require(msg.sender==customer);
        received=true;
        emit receivedEvent();
    }

    function updateNumberOfProcesses (address addr) public view returns (uint){
        
        Processes_medicine p = Processes_medicine(addr);
        return p.getNumberOfProcesses();       
    }
    
    function updateNumberOfStakeholders (address addr) public view returns (uint){
        
        Stakeholders s = Stakeholders(addr);
        return s.getNumberOfStakeholders();    
    }
    
    // Καθιστά το προιόν έτοιμο προς αποστολή ως ένδειξη ολοκλήρωσης της ανακατασκεύης
    Processes_medicine public ps;
    function setReadyForShipment (uint _productId) public { //view returns (uint){
        uint temp_index;
        //Ελέγχουμε αν η λειτουργία "getComplete" του άλλου συμβολαίου επιστρέφει το id της τελευταίας διαδικασίας για το συγκεκριμένο productId εφόσον σε αυτή έχει δηλωθεί η ένδειξη "ολοκληρωμένη" 
        temp_index = ps.getComplete(_productId);
        require (temp_index > 0 && _productId > 0 && _productId <= productsCount); 
        products[_productId].ship_ready = true;
        emit updateEvent();
       // return temp_index;
    }

}
