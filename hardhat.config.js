require('dotenv').config();
require('@nomiclabs/hardhat-waffle');

const { URL, PRIVATE_KEY } = process.env;

module.exports = {
  solidity: '0.8.0',
  networks: {
    rinkeby: {
      url: URL,
      accounts: [`${PRIVATE_KEY}`]
    },
  },
};