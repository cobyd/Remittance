const path = require("path");
const solc = require("solc");
const fs = require("fs-extra");

// const remittanceFactoryPath = path.resolve(
//   __dirname,
//   "contracts",
//   "RemittanceFactory.sol"
// );
const remittancePath = path.resolve(__dirname, "contracts", "Remittance.sol");

// const remittanceFactorySrc = fs.readFileSync(remittanceFactoryPath, "utf8");
const remittanceSrc = fs.readFileSync(remittancePath, "utf8");

module.exports = solc.compile(remittanceSrc, 1).contracts[":Remittance"];
