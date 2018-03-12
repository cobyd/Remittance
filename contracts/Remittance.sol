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
    address public recipient;
    bytes32 public hashword;
    
    event LogNewRemittance(address indexed owner, address indexed recipient, address remittanceContract, uint value);
    event LogReceipt();
    
    function Remittance(address _approvedRecipient, bytes32 _hashword) public payable {
        recipient = _approvedRecipient;
        hashword = _hashword;
        emit LogNewRemittance(owner, _approvedRecipient, this, msg.value);
    }
    
    function receive(bytes _password) public {
        require(keccak256(_password) == hashword);
        require(msg.sender == recipient);
        emit LogReceipt();
        selfdestruct(recipient);
    }
}