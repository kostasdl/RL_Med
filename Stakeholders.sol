pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract Stakeholders{
 
    struct Stakeholder{
        uint id;
        string name;
        uint timestamp;
        uint [] involvedproducts;
        string description;
        address maker;
        bool active;
        string hashIPFS;
    }

    mapping(uint => Stakeholder) private stakeholderChanges;

    uint private productsCount;
    uint private stakeholderCount;

    event updateEvent ();
    
    event changeStatusEvent ();

    address constant public stakeholder = 0xE0f5206BBD039e7b0592d8918820024e2a7437b9;
    address constant public stakeholder2 = 0xE0F5206bbd039e7b0592d8918820024E2A743222;

    constructor () public {
        addStakeholder("Manufacturer",1573564413,"Manufactures medical devices. ");
    }
    
    function addStakeholder (string memory _name, uint _timestamp, string memory _description) public {

        stakeholderCount++;
        stakeholderChanges[stakeholderCount].id = stakeholderCount;
        stakeholderChanges[stakeholderCount].name = _name; 
        stakeholderChanges[stakeholderCount].timestamp = _timestamp; 
        stakeholderChanges[stakeholderCount].description = _description; 
        stakeholderChanges[stakeholderCount].active = true; 
        stakeholderChanges[stakeholderCount].maker = msg.sender;
        emit updateEvent();
    }

    function addStakeholderProduct(uint _id) public {
        stakeholderChanges[stakeholderCount].involvedproducts.push(_id);
        emit updateEvent();
    }
    
    function getStakeholdersProduct (uint _id) public view returns (uint [] memory)  {
        require(_id > 0 && _id <= stakeholderCount);
        require(msg.sender == stakeholderChanges[_id].maker);        
        return stakeholderChanges[_id].involvedproducts;
    }

    function changeStatus (uint _id, bool _active) public {
        require(_id > 0 && _id <= stakeholderCount); 
        stakeholderChanges[stakeholderCount].active = _active;
        emit changeStatusEvent();
    }

    function getStakeholder (uint _id) public view returns (Stakeholder memory)  {
        require(_id > 0 && _id <= stakeholderCount);  
        require(msg.sender == stakeholderChanges[_id].maker);        
        return stakeholderChanges[_id];
    }
    
    function getNumberOfStakeholders () public view returns (uint){
        return stakeholderCount;
    }
}
