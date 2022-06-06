pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"https://github.com/aloycwl/ERC_AC/blob/main/ERC20AC/ERC20AC.sol";
import"https://github.com/aloycwl/ERC_AC/blob/main/Util/OnlyAccess.sol";
contract ERC20AC_WeAreGamblers is ERC20AC,OnlyAccess{
    function name()external pure override returns(string memory){return"We Are Gamblers";}
    function symbol()external pure override returns(string memory){return"WAG";}
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