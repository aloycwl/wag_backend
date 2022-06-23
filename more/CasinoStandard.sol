pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface I20{
    function balanceOf(address)external view returns(uint256);
    function transferFrom(address,address,uint)external;
}
contract CS{
    address internal _owner;
    event Fee(address indexed conAddr,uint value); 
    constructor(){
        _owner=msg.sender;
    }
    function cashout(address a,uint b)public{
        require(msg.sender==_owner);
        I20(a).transferFrom(a,msg.sender,b);
        emit Fee(a,b);
    }
}