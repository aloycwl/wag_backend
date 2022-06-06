pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"https://github.com/aloycwl/ERC_AC/blob/main/ERC20AC/ERC20AC.sol";
import"https://github.com/aloycwl/ERC_AC/blob/main/Util/OnlyAccess.sol";
contract ERC20AC_WeAreGamblers is ERC20AC,OnlyAccess{
    mapping(address=>address)public referrer;
    function name()external pure override returns(string memory){return"We Are Gamblers";}
    function symbol()external pure override returns(string memory){return"WAG";}
    function MINT(address a,uint m,uint p)external onlyAccess{unchecked{
        _totalSupply+=m;
        if(p>0){
            p=m*p/100;
            _balances[referrer[a]]+=p;
            m-=p;
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
    function transferFrom(address a,address b,uint c)public override returns(bool){unchecked{
        require(_balances[a]>=c);
        require(a==msg.sender||_allowances[a][b]>=c);
        (_balances[a]-=c,_balances[b]+=c);
        emit Transfer(a,b,c);
        return true;
    }}
}