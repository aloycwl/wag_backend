pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"https://github.com/aloycwl/ERC_AC/blob/main/ERC20AC/ERC20AC.sol";
import"https://github.com/aloycwl/ERC_AC/blob/main/Util/OnlyAccess.sol";
contract WAG is ERC20AC,OnlyAccess{
    mapping(address=>address)public referrer;
    constructor(string memory name_,string memory sym_)ERC20AC(name_,sym_){}
    function MINT(address a,uint m,uint p)external onlyAccess{unchecked{
        _totalSupply+=m;
        if(p>0){
            (p=m*p/100,_balances[referrer[a]]+=p,m-=p);
            emit Transfer(address(0),referrer[a],p);
        }
        _balances[a]+=m;
        emit Transfer(address(0),a,m);
    }}
    function BURN(address a,uint m)external onlyAccess{unchecked{
        require(_balances[a]>=m);
        (_balances[a]-=m,_totalSupply-=m);
        emit Transfer(a,address(0),m);
    }}
    function REGISTER(address a,address b)external onlyAccess{
        if(referrer[a]!=address(0))referrer[a]=b==address(0)?_owner:b;
    }
}