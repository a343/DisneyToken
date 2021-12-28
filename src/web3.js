import Web3 from "web3";
 
window.ethereum.request({ method: "eth_requestAccounts" });
 
//const web3 = new Web3(window.ethereum); // To use testnet (rinkeby, ropnat..)
const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:7545')); // To use ganache


export default web3;