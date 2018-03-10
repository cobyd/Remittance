# Remittance

## What

#### You will create a smart contract named Remittance whereby:

* [x] Alice creates a Remittance contract with Ether in it and a puzzle.
* [x] Alice sends a one-time-password to Bob; over SMS, say.
* [x] Bob treks to Carol's shop.
* [x] Bob gives Carol his one-time-password.
* [x] Carol submits the password to Alice's remittance contract.
* [x] the contract yields the Ether to Carol.
* [x] Carol gives local currency to Bob.
* [x] Alice is notified that the transaction went through.

Stretch goals:

* [x] add a deadline, after which Alice can claim back the unchallenged Ether
* [] add a limit to how far in the future the deadline can be
* [] add a kill switch to the whole contract
* [x] make the contract a utility that can be used by David, Emma and anybody with an address
* [] make you, the owner of the contract, take a cut of the Ethers smaller than what it would cost Alice to deploy the same contract herself
