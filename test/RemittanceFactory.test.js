const assert = require("assert");
const ganache = require("ganache-cli");
const Web3 = require("web3");
const provider = ganache.provider();
const web3 = new Web3(provider);
const { interface, bytecode } = require("../compile.js");

let remittanceFactory;
let accounts;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();
  remittanceFactory = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({
      data: bytecode
    })
    .send({ from: accounts[0], gas: "1000000" });
  remittanceFactory.setProvider(provider);
});

describe("Remittance Factory", () => {
  it("Successfully deploys", () => {
    assert.ok(remittanceFactory.options.address);
  });
  it("Succeessfully creates a remittance", async () => {
    deployedRemittance = await remittanceFactory.methods
      .createRemittance(
        accounts[2],
        web3.utils.keccak256(web3.utils.toHex("the_password"))
      )
      .send({
        from: accounts[1],
        gas: "1000000",
        value: web3.utils.toWei("1", "finney")
      });
    assert.ok(deployedRemittance.events.LogNewRemittance.address);
  });
});
