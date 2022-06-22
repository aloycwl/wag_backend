pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface I20{
    function BURN(address,uint)external;
    function MINT(address,uint)external;
    function balanceOf(address)external view returns(uint256);
}
contract CS{
    address internal _owner;
    constructor(){
        _owner=msg.sender;
    }
}