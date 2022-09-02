// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.8.16;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";

//inspired from solidity by example
// this code is just to learn the math behind AMM, still has lot of functionality to add.
// best played/visualized in REMIX IDE

contract constant_SUM_AMM{
    IERC20 public immutable ETH;
    IERC20 public immutable WETH;

    uint public ETH_reserve;
    uint public WETH_reserve;

    uint public total_LPtokens;
    mapping(address => uint) public LPtoken_ofuser; // no. of LPtokens hold by that address

    constructor(address _ETH, address _WETH){
        ETH = IERC20(_ETH);
        WETH = IERC20(_WETH);
    }

    function _mint(address _to, uint _amount) internal{
        total_LPtokens += _amount;
        LPtoken_ofuser[_to] += _amount;
    }

    function _burn(address _from, uint _amount) internal{
        total_LPtokens -= _amount;
        LPtoken_ofuser[_from] -= _amount;
    }
    

    function Swap(address _tokenIn,uint _amountIn) external {
        bool ETH_in = _tokenIn  == address(ETH);
        bool WETH_in = _tokenIn  == address(WETH);
        require(ETH_in || WETH_in, "invalid token In");
        
        //SWAP In
      ETH_in ?
          (ETH.transferFrom(msg.sender, address(this), _amountIn),ETH_reserve += _amountIn):
          (WETH.transferFrom(msg.sender, address(this), _amountIn),WETH_reserve += _amountIn);
     
      // FEES 0.25%
      uint amount_Out = (_amountIn * 975)/1000;
      
      //SWAP OUT
     ETH_in ?
         (WETH_reserve -= amount_Out, WETH.transfer(msg.sender, amount_Out)):
         (ETH_reserve -= amount_Out, ETH.transfer(msg.sender, amount_Out));
     }
      
    function add_LIQUIDITY(uint _addETH, uint _addWETH) external{
        require(ETH.balanceOf(msg.sender) >= _addETH && WETH.balanceOf(msg.sender) >= _addWETH , "not enough balance");

        ETH.transferFrom(msg.sender, address(this), _addETH);
        ETH_reserve += _addETH;
        WETH.transferFrom(msg.sender, address(this), _addWETH);
        WETH_reserve += _addWETH;

        uint LP_tokens_tomint;
        total_LPtokens == 0 ? 
        ( LP_tokens_tomint = _addETH + _addWETH) :
        ( LP_tokens_tomint = (_addETH + _addWETH) * total_LPtokens / (ETH_reserve + WETH_reserve));

        require(LP_tokens_tomint > 0);
        _mint(msg.sender,LP_tokens_tomint);
       // here to transfer the lp tokens to the msg.sender, there should be a separate erc20 contract of this LP pair,
       // import here and use mint function from that contract/inheritance
    } 
       
    function remove_LIQUIDITY(uint _LPtokens) external{
        require(_LPtokens <= LPtoken_ofuser[msg.sender],"you dont have specified lptokens");

        _burn(msg.sender, _LPtokens);
        (uint _ETHout,uint _WETHout) = (
            (_LPtokens * ETH_reserve / total_LPtokens),
            (_LPtokens * WETH_reserve / total_LPtokens)
            );
        require( _ETHout > 0 && _WETHout > 0);

        ETH_reserve -= _ETHout;
        WETH_reserve -= _WETHout;
        ETH.transfer(msg.sender, _ETHout);
        WETH.transfer(msg.sender, _WETHout);
   }

}
