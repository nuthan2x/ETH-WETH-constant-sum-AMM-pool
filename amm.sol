// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.8.16;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";

contract constant_SUM_AMM{
    IERC20 public immutable ETH;
    IERC20 public immutable WETH;

    uint public total_LPtokens;
    mapping(address => uint) public LPtoken_user; // no. of LPtokens hold by that address

    constructor(address _ETH, address _WETH){
        ETH = IERC20(_ETH);
        WETH = IERC20(_WETH);
    }

    function _mint(address _to, uint _amount) external{
        total_LPtokens += _amount;
        LPtoken_user[_to] += _amount;
    }

     function _burn(address _from, uint _amount) external{
        total_LPtokens += _amount;
        LPtoken_user[_from] += _amount;
    }
    
    function swap(address _tokenIn, uint _amountIn) external payable returns (uint amountOut) {
        require( _tokenIn == address(token1),
            "invalid token"
        );
}
