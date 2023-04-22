const { network } = require("hardhat")
const {
    developmentChains,
    DECIMALS,
    INITIAL_ANS,
} = require("../help-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    // const chainId = network.config.chainId

    if (developmentChains.includes(network.name)) {
        log("Local network detected! Deploying mocks.. .. .. .. ")
        await deploy("MockV3Aggregator", {
            contract: "MockV3Aggregator",
            from: deployer,
            log: true,
            args: [DECIMALS, INITIAL_ANS],
        })
        log("Mocks deployed!")
        log(
            "------------------------------------------------------------------------------"
        )
    }
}

module.exports.tags = ["all", "mocks"]
