pragma solidity ^0.4.21;

contract Owned {
    address owner;

    function Owned() public {
        owner = msg.sender;
    }

    modifier ownerOnly {
        require(msg.sender == owner);
        _;
    }
}

contract RemittanceManager is Owned {
    struct Remittance {
        address sender;
        address recipient;
        uint value;
        uint cancelAvailableAfter;
    }
    mapping(bytes32=>Remittance) public remittances;
    
    event LogNewRemittance(address indexed owner, address indexed recipient, address remittanceContract, uint value);
    event LogReceipt(address indexed recipient);
    event LogKey(bytes32 key);
    
    function RemittanceManager() public {}
    
    function createRemittance(address _approvedRecipient, bytes32 _hashword) public payable {
        require(msg.value > 0);
        require(remittances[_hashword].sender == 0);
        uint ownerCut = msg.value / 20;
        uint remittanceValue = msg.value - ownerCut;
        Remittance memory r = Remittance({
            sender: msg.sender,
            recipient: _approvedRecipient,
            value: remittanceValue,
            cancelAvailableAfter: block.number + 50000
        });
        remittances[_hashword] = r;
        owner.transfer(ownerCut);
        emit LogKey(_hashword);
        emit LogNewRemittance(owner, _approvedRecipient, this, msg.value);
    }

    function cancelRemittance(bytes32 _key) public {
        require(remittances[_key].sender == msg.sender);
        require(block.number > remittances[_key].cancelAvailableAfter);
        uint value = remittances[_key].value;
        require(value > 0);
        remittances[_key].value = 0;
        msg.sender.transfer(value);
    }
    
    function receive(string _password) public {
        bytes32 key = keccackHash(msg.sender, _password);
        uint value = remittances[key].value;
        require(value > 0);
        remittances[key].value = 0;
        emit LogReceipt(msg.sender);
        remittances[key].recipient.transfer(value);
    }

    // used by client to generate hash to initialize remittance
    function keccackHash(address _recipient, string _password) public pure returns(bytes32) {
        require(_recipient != 0);
        return keccak256(_recipient, _password);
    }
}