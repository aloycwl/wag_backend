pragma solidity>0.8.0;//SPDX-License-Identifier:None

contract OnlyAccess {

    mapping(address=>uint)public _access;

    modifier onlyAccess(){
        require(_access[msg.sender]==1);
        _;
    }

    constructor(){
        _access[msg.sender]=1;
    }

    function ACCESS(address a,uint b)external onlyAccess{
        if(b==0)delete _access[a];
        else _access[a]=1;
    }

}