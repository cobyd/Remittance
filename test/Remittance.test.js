const assert = require("assert");
const ganache = require("ganache-cli");
const Web3 = require("web3");
const provider = ganache.provider();
const web3 = new Web3(provider);
const { interface, bytecode } = require("../compile.js");

let remittance;
let accounts;
let password;
let hashword;
let oneFinney;

beforeEach(async () => {
  password = "the_password";
  hashword = web3.utils.keccak256(web3.utils.toHex(password));
  oneFinney = web3.utils.toWei("1", "finney");
  accounts = await web3.eth.getAccounts();
  remittance = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({
      data: bytecode,
      arguments: [accounts[1], hashword]
    })
    .send({
      from: accounts[0],
      gas: "1000000",
      value: oneFinney
    });
  remittance.setProvider(provider);
});

describe("Remittance", () => {
  it("Successfully deploys", () => {
    assert.ok(remittance.options.address);
  });
  it("Has the correct balance", async () => {
    let balance = await web3.eth.getBalance(remittance.options.address);
    assert.equal(balance, oneFinney);
  });
  it("Distributes ether to the recipient", async () => {
    let startingAccountBalance = await web3.eth.getBalance(accounts[1]);
    await remittance.methods
      .receive(web3.utils.toHex(password))
      .send({ from: accounts[1], gas: "1000000" });
    let contractBalance = await web3.eth.getBalance(remittance.options.address);
    let finalAccountBalance = await web3.eth.getBalance(accounts[1]);
    assert.equal(contractBalance, 0);
    assert(
      finalAccountBalance > startingAccountBalance,
      "Funds were not received"
    );
  });
});
