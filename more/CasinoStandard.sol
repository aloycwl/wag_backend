pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IWAG{
    function BURN(address,uint)external;
    function MINT(address,uint)external;
    function balanceOf(address)external view returns(uint256);
}
contract CS{
    IWAG internal iwag;
    address internal _owner;
    constructor(address a){
        iwag=IWAG(a);
        _owner=msg.sender;
    }
}