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

    event LogCancel();
    
    function Cancellable() public {
        cannotCanelUntil = block.number + 50000;
    }
    
    function Cancel() public ownerOnly {
        require(block.number > cannotCanelUntil);
        emit LogCancel();
        selfdestruct(owner);
    }
}

contract Remittance is Cancellable {
    address recepient;
    bytes32 hashword;
    
    event LogNewRemittance(address indexed owner, address indexed recepient, address remittanceContract, uint value);
    event LogReceipt();
    
    function Remittance(address _approvedRecepient, bytes32 _hashword) public payable {
        recepient = _approvedRecepient;
        hashword = _hashword;
        emit LogNewRemittance(owner, _approvedRecepient, this, msg.value);
    }
    
    function receive(bytes32 _password) public {
        require(keccak256(_password) == hashword);
        require(msg.sender == recepient);
        emit LogReceipt();
        selfdestruct(recepient);
    }
}