//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.4 <0.9.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract Disney{
    
    
    //------------------------------------------DECLARACIONES INICIALES----------------------------------------
    //Instancia del contrato token
    ERC20Basic private token;
    
    //Direccion de Disney
    address payable public owner;
  
    //Constructor
    constructor () public{
        token = new ERC20Basic(100000);
        owner = msg.sender;
    }
    
    //Estructura de datos para almacenar los datos de los clientes
    
    struct cliente{
        uint tokens_comprados;
        string [] atracciones_disfrutadas;
        
    }
    
    //Mpaping para el registro de clientes
    mapping (address => cliente ) public clientes;
    
    
    //---------------------------------------------GESTION DE TOKENS-------------------------------------------------
    
    //Funcion para establecer el precio del TOKENS
    function costeTokenAcomprar(uint _numToken) internal pure returns (uint){
        //Conversion de token a Ethers 1 Token --> 1 ether
        return _numToken*(getPrecioToken());
    }
    
    //Funcion para comprar tokens en Disney
    function compraToken (uint _numTokens) public payable {
         
        //coste de los tokens a comprar
        uint coste = costeTokenAcomprar(_numTokens);
   
        //evaluacion del dinero que el cliente paga por los tokens
        require(msg.value >= coste, "No tienes suficiente ehters para comprar tantos tokens");
        //Cambio a devolver al cliente 
        uint returnValue = msg.value - coste;
        //Disney devuelve el cambio al cliente
        msg.sender.transfer(returnValue);
        //Obtener num token disponible
        uint balance = balanceOf();
        require(_numTokens <= balance, "Compra un numero menor de tokens");
        //Se transfiere el numero de tokens al cliente
        token.transfer(msg.sender, _numTokens);
        //Registro de tokens tokens_comprados
        clientes[msg.sender].tokens_comprados = _numTokens;
        
        
    }
 
    //Return the token price
    function getPrecioToken() public pure returns (uint){
        return 1 ether;
    }

    //Balance de tokens del contrato dinsey
    function balanceOf() public view returns (uint){
        return token.balanceOf(address(this));
    }
    
    // devolver mi numero de tokens
    function getMisTokens() public view returns (uint){
        return token.balanceOf(msg.sender);
    }
    
    //generar mas tokens para dinsey
    function generaToken(uint _numTokens) public only(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }
    
    
    //modificador para controlar las funciones ejecutrables por dinsey
    modifier only(address _direccion){
        require(_direccion == owner, "No tienes permisos para ejecutar esta funcion");
        _;
    }
    
      //---------------------------------------------GESTION DE dinsey-------------------------------------------------
        
    //Eventos
    
    event nueva_atraccion(string, uint);
     event nueva_comida(string, uint);
    event baja_atraccion(string);
      event baja_comida(string);
    event disfruta_atraccion(string,uint, address);
event disfruta_comida(string,uint, address);
    
    struct atraccion{
        string nombre_atraccion;
        uint precio_atraccion;
        bool estado_atraccion;
    }
    
    struct comida{
        string nombre_comida;
        uint precio_comida;
        bool estado_comida;
        
    }
    //Mapping para relacionar nombre de atracion con su estructura de datos
    mapping (string => atraccion) public mappingAtracciones;
     //Mapping para relacionar nombre de comida con su estructura de datos
    mapping (string => comida) public mappingComidas;
    //almacenar el nombre de las atracciones
    string[] atracciones;
    string[] comidas;
    //mappgin para relacionar una identidad(cliente) con su historial en Disney
    mapping (address => string[]) historialAtracciones;
    mapping (address => string[]) historiaComidas;

    //funcion para crear atracciones , solo dinsey podra crearlas
    function nuevaAtraccion(string memory _nombreAtraccion, uint _precio) public only(msg.sender){
        // creacion atraccion en Disney
      mappingAtracciones[_nombreAtraccion] = atraccion(_nombreAtraccion, _precio, true);
      atracciones.push(_nombreAtraccion);
      //emisison evento nuevoa atracciones
      emit nueva_atraccion(_nombreAtraccion, _precio);
      
        
    }
    
    //Crear nuevos menus para la comida en Disney (solo ejecutable por Disney)
    function crearMenus(string memory _nombreMenu, uint _precio) public only(msg.sender){
             // creacion comida en Disney
      mappingComidas[_nombreMenu] = comida(_nombreMenu, _precio, true);
     comidas.push(_nombreMenu);
      //emisison evento nuevoa atracciones
      emit nueva_comida(_nombreMenu, _precio);  
    }
    
    function bajaComida(string memory _nombreComida) public only(msg.sender){
        require(mappingComidas[_nombreComida].estado_comida  == true, "La comida no existe o ya esta dada de baja");

        //Cambiamos el estado de la atracciones
         mappingComidas[_nombreComida].estado_comida = false;
         //Emision del evento
         emit baja_comida(_nombreComida);
    }
      
    function bajaAtraccion(string memory _nombreAtraccion) public only(msg.sender){
        require(mappingAtracciones[_nombreAtraccion].estado_atraccion  == true, "La atraccion no existe o ya esta dada de baja");

        //Cambiamos el estado de la atracciones
         mappingAtracciones[_nombreAtraccion].estado_atraccion = false;
         //Emision del evento
         emit baja_atraccion(_nombreAtraccion);
    }
        
    function atraccionesDisponibles() public view returns(string [] memory){
        
        return atracciones;
    }
    
      function comidasDisponibles() public view returns(string [] memory){
        
        return comidas;
    }
    
    //Funcion para subirse a la atraccion y pagar
    function subirseAtraccion(string memory _nombreAtraccion) public {
        //precio de la atraccion
        uint tokens_atraccion =  mappingAtracciones[_nombreAtraccion].precio_atraccion;
    //verifica el estado de la atraccion
            require(mappingAtracciones[_nombreAtraccion].estado_atraccion  == true, "La atraccion no esta disponible");
            //Verificar el numero de tokens que tiene el cliente para subirse a la atraccion
            require(tokens_atraccion <= getMisTokens(), "No tienes suficientes tokens para montar en la atraccion");
            //cliente paga la atraccion
            token.transfer_disney(msg.sender, address(this),tokens_atraccion );
            //almacenar en el historialAtracciones
            historialAtracciones[msg.sender].push(_nombreAtraccion);
            emit disfruta_atraccion(_nombreAtraccion,tokens_atraccion, msg.sender);

        
    }
    
    //Funcion para subirse a la atraccion y pagar
    function comprarComida(string memory _nombreComida) public {
        //precio de la atraccion
        uint tokens_comida =  mappingComidas[_nombreComida].precio_comida;
    //verifica el estado de la atraccion
            require( mappingComidas[_nombreComida].estado_comida  == true, "La comida no esta disponible");
            //Verificar el numero de tokens que tiene el cliente para subirse a la atraccion
            require(tokens_comida <= getMisTokens(), "No tienes suficientes tokens para montar en la atraccion");
            //cliente paga la atraccion
            token.transfer_disney(msg.sender, address(this),tokens_comida );
            //almacenar en el historialAtracciones
            historiaComidas[msg.sender].push(_nombreComida);
            emit disfruta_comida(_nombreComida,tokens_comida, msg.sender);

        
    }
    
    function historialAtraccionesDisfrutadas() public view returns(string[] memory){
        return historialAtracciones[msg.sender];
    }
     function historialComidasDisfrutadas() public view returns(string[] memory){
        return historiaComidas[msg.sender];
    }
    
    function devolverTokens(uint _numTokens) public payable{
        //el numero de tokens a deolver es positivo
        require(_numTokens>0, "Por favor, introduce una cantidad positiva de tokens");
        //El usuario debe tener el num de tokens que desea devolver 
        require(_numTokens <= getMisTokens(), "No tiene los tokens que desea devolver");
        //el cliente devuelve los tokens
        token.transfer_disney(msg.sender, address(this), _numTokens);
        //devolucion de los ethers al cliente
        msg.sender.transfer(costeTokenAcomprar(_numTokens));

        
    }
    
}