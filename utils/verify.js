const { run } = require("hardhat")

const verify = async (ContractAddress, agrs) => {
    console.log("Verifying contract.. .. .. .. ..")
    try {
        await run("verify:verify", {
            address: ContractAddress,
            constructorArguments: agrs,
        })
    } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already Verified")
        } else {
            console.log(e)
        }
    }
}

module.exports = { verify }
