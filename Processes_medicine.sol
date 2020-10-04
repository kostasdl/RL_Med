pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract Processes_medicine{

    struct Process {
        uint id; // 
	    string name;       
        uint timestamp;
        string description;
	    bool active;
        bool complete;
        address maker; 
        string hashIPFS; 
        uint involvedproduct;
    }

    mapping(uint => Process) private processChanges; //
  
    uint private productsCount;
    uint private pedigreeCount;
    uint private processCount;
    uint private stakeholdersCount;

    event updateEvent ();
    
    event changeStatusEvent ();

    event changeStateEvent ();

    address constant public stakeholder = 0xE0f5206BBD039e7b0592d8918820024e2a7437b9;
    address constant public stakeholder2 = 0xE0F5206bbd039e7b0592d8918820024E2A743222;

    constructor (uint _time_stamp, uint _involved_product) public { // Εισαγωγή νέων διαδικασιών στο σύστημα. Μετράμε άυξοντα αριθμό από το id=1.
        addProcess("1st_check",_time_stamp,"first check and estimation before sent to refurbish center",_involved_product);
        addProcess("Cleaning",_time_stamp,"cleaning and sterilizing in refurbish center",_involved_product);
        addProcess("Integrity_check",_time_stamp,"device optical check for structural integrity",_involved_product);
        addProcess("SW_update_check",_time_stamp,"software updates and battery check",_involved_product);
        addProcess("Packaging",_time_stamp,"device packaging ready for shipment",_involved_product);
    }
    
    function addProcess (string memory _name, uint _timestamp, string memory _description, uint _involvedproduct) public {

        processCount++;
        processChanges[processCount].id = processCount;
        processChanges[processCount].name = _name; 
        processChanges[processCount].timestamp = _timestamp; 
        processChanges[processCount].description = _description; 
        processChanges[processCount].active = false; 
        processChanges[processCount].complete = false;
        processChanges[processCount].maker = msg.sender;
        processChanges[processCount].involvedproduct = _involvedproduct;
        emit updateEvent();
    }

    function changeStatus (uint _id, bool _active) public { 
        require(_id > 0 && _id <= processCount); 
        processChanges[processCount].active = _active;
        emit changeStatusEvent(); 
    }

    function changeState (uint _id, bool _complete) public {
        require(_id > 0 && _id <= processCount);

        // Ελέγχουμε αν πληρούνται οι προϋποθέσεις για να δηλωθεί ως ολοκληρωμένη μια διαδικασία
        require(processChanges[_id-1].complete == true ||  keccak256(abi.encodePacked((processChanges[_id].name))) == keccak256(abi.encodePacked(("1st_check"))) );
        processChanges[processCount].complete = _complete;
        emit changeStateEvent(); // trigger event 
    }
    
    function getProcessProduct (uint _id) public view returns (uint)  {
        require(_id > 0 && _id <= processCount);
        require(msg.sender == processChanges[_id].maker);
        return processChanges[_id].involvedproduct;
    }

    function getProcess (uint _processId) public view returns (Process memory)  {
        require(_processId > 0 && _processId <= processCount); 
        require(msg.sender==processChanges[_processId].maker);
        return processChanges[_processId];
    }
    
    function getNumberOfProcesses () public view returns (uint){
        return processCount;
    }
    
    function getComplete (uint _productId) public view returns (uint) {    
        // Η διαδικασία ανακατασκευής έχει ολοκληρωθεί μόνο αν η τελευταία διαδικασία ονόματι "packaging" έχει ολοκληρωθεί 
        uint index;
        for (index = 1; index <= processCount; index++) {
          if ( keccak256(abi.encodePacked((processChanges[index].name))) == keccak256(abi.encodePacked(("Packaging"))) && processChanges[index].complete == true && processChanges[index].involvedproduct == _productId && processChanges[index].maker == msg.sender) {
              return index;   // Λαμβάνουμε το process id της διαδικασίας "packaging" για το συγκεκριμένο productid
          } 
        }
    }
    
}
