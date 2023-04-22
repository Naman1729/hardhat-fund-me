//SPDX-License-Identifier: MIT
// Pragma
pragma solidity ^0.8.7;
// Imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";
// Error Codes
error FundMe__NotOwner();

// Interfaces, Libraries, Contracts
/**
 * @title A Contract for crowd funding
 * @author Naman Gautam
 * @notice This Contract is to demo a sample funding contract
 * @dev This implements price feeds as our library
 */
contract FundMe {
    // Type Declarations
    using PriceConverter for uint256;

    // State Variables!
    address private immutable i_owner;
    address[] private s_funders;
    mapping(address => uint256) private s_AddressToAmountFunded;
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;

    AggregatorV3Interface private s_priceFeed;

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner!!");
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    // Functions Order;
    //// constructor
    //// receive
    //// fallback
    //// external
    //// public
    //// internal
    //// private
    //// view / pure

    constructor(address __priceFeedAddress__) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(__priceFeedAddress__);
    }

    // receive() external payable {
    //     fund();
    // }

    // fallback() external payable {
    //     fund();
    // }

    /**
     * @notice This function funds this contract
     * @dev This implements price feeds as our library
     */

    function fund() public payable {
        require(
            msg.value.getConverstionRate(s_priceFeed) >= MINIMUM_USD,
            "DIDN'T SEND ENOUGH!"
        );
        s_AddressToAmountFunded[msg.sender] = msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        //require(msg.sender == owner,"Sender is not owner!!");
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_AddressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // payable(msg.sender).transfer(address(this).balance);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        // call vs delegatecall
        require(callSuccess, "Call failed");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        // mappings can't be in memory, storage!
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_AddressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success, "Call failed");
    }

    // view / pure
    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 funderIndex) public view returns (address) {
        return s_funders[funderIndex];
    }

    function getAddressToAmountFunded(
        address funder
    ) public view returns (uint256) {
        return s_AddressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
