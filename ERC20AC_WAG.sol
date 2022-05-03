pragma solidity^0.8.13;//SPDX-License-Identifier:None
contract ERC20AC_WeAreGamblers{
    event Transfer(address indexed from,address indexed to,uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
    mapping(address=>uint256)private _balances;
    mapping(address=>bool)private _access;
    uint256 private _totalSupply;
    modifier onlyAccess(){require(_access[msg.sender]);_;}
    constructor(){_access[msg.sender]=true;}
    function name()external pure returns(string memory){return"We Are Gamblers";}
    function symbol()external pure returns(string memory){return"WAG";}
    function decimals()external pure returns(uint8){return 18;}
    function totalSupply()external view returns(uint256){return _totalSupply;}
    function balanceOf(address account)external view returns(uint256){return _balances[account];}
    function transfer(address to,uint256 amount)external returns(bool){
        transferFrom(msg.sender,to,amount);
        return true;
    }
    function allowance(address owner,address spender)external pure returns(uint256){
        require(owner!=spender);
        return 0;
    }
    function approve(address spender,uint256 amount)external returns(bool b){
        emit Approval(msg.sender,spender,amount);
        return true;
    }
    function transferFrom(address from,address to,uint256 amount)public returns(bool b){unchecked{
        require(_balances[from]>=amount&&(from==msg.sender||_access[msg.sender]==true));
        _balances[from]-=amount;
        _balances[to]+=amount;
        emit Transfer(from,to,amount);
        return true;
    }}
    function ACCESS(address a,bool b)external onlyAccess{
        if(!b)delete _access[a];
        else _access[a]=true;
    }
    function MINT(address a,uint256 m)external onlyAccess{unchecked{
        m*=1e18;
        _totalSupply+=m;
        _balances[a]+=m;
        emit Transfer(address(0),a,m);
    }}
    function BURN(address a,uint256 m)external onlyAccess{unchecked{
        m*=1e18;
        require(_balances[a]>=m);
        _balances[a]-=m;
        _totalSupply-=m;
        emit Transfer(a,address(0),m);
    }}
}
