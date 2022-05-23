pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"https://github.com/aloycwl/ERC_AC/blob/main/ERC20AC/ERC20AC.sol";
contract ERC20AC_WeAreGamblers is ERC20AC{
    mapping(address=>bool)private _access;
    modifier onlyAccess(){require(_access[msg.sender]);_;}
    constructor(){_access[msg.sender]=true;}
    function name()external pure override returns(string memory){return"We Are Gamblers";}
    function symbol()external pure override returns(string memory){return"WAG";}
    function ACCESS(address a,bool b)external onlyAccess{
        if(!b)delete _access[a];
        else _access[a]=true;
    }
    function MINT(address a,uint256 m)external onlyAccess{unchecked{
        (_totalSupply+=m,_balances[a]+=m);
        emit Transfer(address(0),a,m);
    }}
    function BURN(address a,uint256 m)external onlyAccess{unchecked{
        require(_balances[a]>=m);
        (_balances[a]-=m,_totalSupply-=m);
        emit Transfer(a,address(0),m);
    }}
}