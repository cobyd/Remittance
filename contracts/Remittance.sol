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

contract Cancellable is Owned {
    uint cannotCanelUntil;
    
    function Cancellable() public {
        cannotCanelUntil = block.number + 50000;
    }
    
    function Cancel() public ownerOnly {
        require(block.number > cannotCanelUntil);
        selfdestruct(owner);
    }
}

contract RemittanceFactory {
    event LogNewRemittance(address indexed owner, address remittanceContract, uint value);
    
    function RemittanceFactory() public {}
    
    function createRemittance(address _approvedRecepient, bytes32 _hashword) public payable {
        require(msg.value > 0);
        Remittance r = new Remittance(msg.sender, _approvedRecepient, _hashword);
        emit LogNewRemittance(msg.sender, r, msg.value);
    }
}

contract Remittance is Cancellable {
    address recepient;
    bytes32 hashword;
    
    event LogReceipt(uint block);
    
    function Remittance(address _owner, address _approvedRecepient, bytes32 _hashword) public payable {
        owner = _owner;
        recepient = _approvedRecepient;
        hashword = _hashword;
    }
    
    function receive(bytes32 _password) public {
        require(keccak256(_password) == hashword);
        require(msg.sender == recepient);
        emit LogReceipt(block.number);
        selfdestruct(recepient);
    }
}