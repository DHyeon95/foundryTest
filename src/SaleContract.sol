// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/ISBTContract.sol";
import "./interfaces/ISBTPriceContract.sol";
import "./interfaces/IERC20.sol";
import "./access/Ownable.sol";

contract SaleContract is Ownable {
  ISBTContract public tokenContract;
  ISBTPriceContract public priceContract;
  IERC20 public constant stableContract = IERC20(0x28661511CDA7119B2185c647F23106a637CC074f);
  uint256 public count;
  bool public killSwitch = false;

  modifier checkSwitch() {
    require(killSwitch == false, "Contract stopped");
    _;
  }

  modifier checkContract() {
    require(tokenContract != ISBTContract(address(0)), "Contract not set");
    require(priceContract != ISBTPriceContract(address(0)), "Contract not set");
    _;
  }

  constructor() Ownable(_msgSender()) {}

  function buySBTBFC() external payable checkContract checkSwitch {
    // BFC : native token
    uint256 price = priceContract.getSBTPriceBFC();
    require(msg.value == price, "Invalid price");
    count = count + 1;
    tokenContract.mintSBT(_msgSender(), count);
  }

  function buySBTUSDC() external checkContract checkSwitch {
    uint256 price = priceContract.getSBTPriceUSDC();
    stableContract.transferFrom(_msgSender(), address(this), price);
    count = count + 1;
    tokenContract.mintSBT(_msgSender(), count);
  }

  function withdrawBFC(uint256 amount) external checkSwitch onlyOwner {
    payable(owner()).transfer(amount);
  }

  function withdrawUSDC(uint256 amount) external checkSwitch onlyOwner {
    stableContract.transfer(owner(), amount);
  }

  function setSBTPriceContract(address _contract) external onlyOwner {
    priceContract = ISBTPriceContract(_contract);
  }

  function setSwitch(bool input) external onlyOwner {
    killSwitch = input;
  }

  function setSBTContract(address _contract) external onlyOwner {
    tokenContract = ISBTContract(_contract);
  }
}
