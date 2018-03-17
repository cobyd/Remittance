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
  oneFinney = web3.utils.toWei("1", "finney");
  accounts = await web3.eth.getAccounts();
  remittance = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({
      data: bytecode
    })
    .send({
      from: accounts[0],
      gas: "1000000"
    });
  remittance.setProvider(provider);
  password = "the_password";
  hashword = await remittance.methods.keccackHash(accounts[2], password).call();
});

describe("Remittance", () => {
  it("Successfully deploys", () => {
    assert.ok(remittance.options.address);
  });
  it("Creates a remittance", async () => {
    let tx = await remittance.methods
      .createRemittance(accounts[2], hashword)
      .send({ from: accounts[1], gas: "1000000", value: oneFinney });
    let r = await remittance.methods.remittances(hashword).call();
    assert.equal(r[0], accounts[1]);
    assert.equal(r[1], accounts[2]);
    assert.equal(r[2], "950000000000000");
  });
  it("Can withdraw", async () => {
    let startingBalance = await web3.eth.getBalance(accounts[2]);
    await remittance.methods
      .createRemittance(accounts[2], hashword)
      .send({ from: accounts[1], gas: "1000000", value: oneFinney });
    await remittance.methods
      .receive(password)
      .send({ from: accounts[2], gas: "1000000" });
    let endingBalance = await web3.eth.getBalance(accounts[2]);
    assert(endingBalance > startingBalance, "Withdrawl failed");
  });
  it("Cannot create a new remittance with a used key", async () => {
    await remittance.methods
      .createRemittance(accounts[2], hashword)
      .send({ from: accounts[1], gas: "1000000", value: oneFinney });
    await remittance.methods
      .receive(password)
      .send({ from: accounts[2], gas: "1000000" });
    try {
      await remittance.methods
        .createRemittance(accounts[2], hashword)
        .send({ from: accounts[1], gas: "1000000", value: oneFinney });
      assert(false, "Should throw in transaction");
    } catch (e) {
      assert(e);
    }
  });
});
