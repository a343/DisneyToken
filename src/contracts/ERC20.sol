// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.9.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";



//Carlos ---> 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//Antonio ---> 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
//María ---> 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
//Direccion del contrato -- 0x28Eb34B12E3728f7B69655A161444D4E70c731Bd


//Interface de nuestro token ERC20
interface IERC20{
    //Devuelve la cantidad de tokens en existencia
    function totalSupply() external view returns (uint256);

    //Devuelve la cantidad de tokens para una dirección indicada por parámetro
    function balanceOf(address account) external view returns (uint256);

    //Devuelve el número de token que el spender podrá gastar en nombre del propietario (owner)
    function allowance(address owner, address spender) external view returns (uint256);


    //Operaciones de chequeo : 

    //Devuelve un valor booleano resultado de la operación indicada
    function transfer(address receiver, uint256 amount) external returns (bool);

    //Devuelve un valor booleano con el resultado de la operación de gasto
    function approve(address spender, uint256 amount) external returns (bool);

    //Devuelve un valor booleano con el resultado de la operación de paso de una cantidad de tokens usando el método allowance()
    function transferFrom(address sender, address receiver, uint256 amount) external returns (bool);

    function transfer_disney(address _cliente, address receiver, uint256 amount) external returns (bool);

    //Eventos de notificacion

    //Evento que se debe emitir cuando una cantidad de tokens pase de un origen a un destino
    event Transfer(address indexed from, address indexed to, uint256 value);

    //Evento que se debe emitir cuando se establece una asignación con el mmétodo allowance()
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//Implementación de las funciones del token ERC20
contract ERC20Basic is IERC20{

    string public constant name = "ERCADR";
    string public constant symbol = "ADR-token";
    uint8 public constant decimals = 2;

    //Eventos disponibles
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed owner, address indexed spender, uint256 tokens);

    //validar las operaciones aritmeticamente
    using SafeMath for uint256;


    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    uint256 totalSupply_;

    constructor (uint256 initialSupply) public{
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }


    function totalSupply() public override view returns (uint256){
        return totalSupply_;
    }

    function increaseTotalSupply(uint newTokensAmount) public {
        totalSupply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256){
        return balances[tokenOwner];
    }

    function allowance(address owner, address delegate) public override view returns (uint256){
        return allowed[owner][delegate];
    }


    function transfer(address receiver, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[msg.sender]);
        //utilizamos el metodo sub/add de la libreria SafeMath para garantizar la operacion artimetica
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }
    
       function transfer_disney(address _cliente, address receiver, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[_cliente]);
        //utilizamos el metodo sub/add de la libreria SafeMath para garantizar la operacion artimetica
        balances[_cliente] = balances[_cliente].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(_cliente, receiver, numTokens);
        return true;
    }

    //Set el numero de tokens que el delegado dispone
    function approve(address delegate, uint256 numTokens) public override returns (bool){
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    // Transferencia del propietario a traves del delegado hacia el comprador
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        //Quitamos los tokens a vender al propietario actualizando el balance
        balances[owner] = balances[owner].sub(numTokens);
        //Quitamos los tokens a vender al delegado que tiene permitido utilizar esos tokens
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        //actualizamos el balance del comprador
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}