pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface I20{
    function balanceOf(address)external view returns(uint256);
    function transferFrom(address,address,uint)external;

}
contract CS{
    address internal _owner;
    constructor(){
        _owner=msg.sender;
    }
}