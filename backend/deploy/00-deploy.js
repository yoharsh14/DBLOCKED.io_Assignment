const {verify} = require("../utils/verify.js")
const {network} = require("hardhat")
require("dotenv").config();
const{developmentChains } = require("../helper-hardhat-config");

module.exports = async(hre)=>{
    const {getNamedAccounts,deployments} = hre;
    const {deploy,log} = deployments;
    const {deployer} = await getNamedAccounts();
    
    const voter = await deploy("Voting",{
        from:deployer,
        args:[],
        log: true,
        waitCongirmations:network.config.blockConfirmations||1,
    })
    if(!developmentChains.includes(network.name)){
        log("verifying...")
        await verify(voter.address,[]);
    }
    log("------------------DONE--------------------")
}