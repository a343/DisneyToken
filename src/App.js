import logo from "./logo.svg";
import "./App.css";
import React from "react";
import web3 from "./web3";
import disney from "./disney";
import Select from 'react-select'

class App extends React.Component {

  constructor(props) {
    super(props);
    this.state = { atraccionesDisponibles: "", value: "", numTokens: 0, rideSelected: "", dropDownOpt: [], message: "", precioToken: 0 };
  }

  buyTokens = async (event) => {
    event.preventDefault();
    const accounts = await web3.eth.getAccounts();
    const data = new FormData(event.target);
    const tokens = data.get('numToken');

    disney.methods.compraToken(tokens).send({
      from: accounts[0],
      value: web3.utils.toWei(tokens, 'ether') //Suponemos que los ethers dados son los mismos que los tokens

    }).then(async (res) => {
      console.log('Success', res);
      await this.loadNumTokens();

    })
      .catch(err => {
        console.log(err);
        this.setState({ message: err.message });
      })

  };


  onChange(event) {
    console.log('Ride selected : ', event.value);
    this.setState({ rideSelected: event.value });
  }

  onClick = async () => {
    const accounts = await web3.eth.getAccounts();

    disney.methods.subirseAtraccion(this.state.rideSelected).send({
      from: accounts[0],
      gasLimit: '0x3d0900',
    }).then(async (res) => {
      console.log('Success', res);
      this.setState({ message: "Disfruta de " + this.state.rideSelected });

      await this.loadNumTokens();

    })
      .catch(err => {
        console.log(err)
        this.setState({ message: err.message });

      });

  };

  addRides = async (event) => {
    event.preventDefault();
    const accounts = await web3.eth.getAccounts();

    const data = new FormData(event.target);
    var rideName = data.get('rideName');
    var price = data.get('price');
    disney.methods.nuevaAtraccion(rideName, data.get('price')).send({
      from: accounts[0],
      gasLimit: '0x3d0900',
    }).then(async (res) => {
      console.log('Success', res);
      await this.loadAvailableRides();

    })
      .catch(err => {
        console.log(err);
        this.setState({ message: err.message});
      })

  };



  async componentDidMount() {
    const precioToken  =  await disney.methods.getPrecioToken().call();

    this.setState({precioToken :  web3.utils.fromWei(precioToken, 'ether')});

    await this.loadAvailableRides();

    await this.loadNumTokens();

  }

  async loadNumTokens() {
    const numTokens = await disney.methods.getMisTokens().call();
    this.setState({ numTokens });
  }

  async loadAvailableRides() {
    const atraccionesDisponibles = await disney.methods.atraccionesDisponibles().call();
    this.setState({ atraccionesDisponibles });

    const dropDownValue = atraccionesDisponibles.map((response) => ({
      "value": response,
      "label": response
    }));

    this.setState({ dropDownValue });
  }

  render() {
    return (

      <div>
        <h2>Disney Contract</h2>
        <form onSubmit={this.addRides}>
          <h4>Add new rides</h4>
          <div>
            <p> <label htmlFor="rideName">Please, enter the new ride </label>
              <input id="rideName" name="rideName" type="string" /></p>
            <p> <label htmlFor="price">Please, enter the price </label>
              <input id="price" name="price" type="number" /></p>
          </div>
          <button>Add ride</button>
        </form>
        <p>You have:  {this.state.numTokens} tokens</p>
        <form onSubmit={this.buyTokens}>
          <h4>Do you want to buy some tokens? The token price is : {this.state.precioToken} ethers </h4>
          <div>
            <label htmlFor="numToken">Please, enter the amount of token to buy </label>
            <input id="numToken" name="numToken" type="number" />
          </div>
          <button>Buy</button>
        </form>

        <hr />

        <div>
          <h4>Ready to enjoy the rides? Select the one you want to enjoy</h4>
          <Select
            options={this.state.dropDownValue}
            onChange={this.onChange.bind(this)}
          />

        </div>
        <button onClick={this.onClick}>Ènjoy the ride!</button>
        <h1>{this.state.message}</h1>

      </div>
    );
  }
}
export default App;