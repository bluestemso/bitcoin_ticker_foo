import 'package:bitcoin_tracker_foo/coin_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:intl/intl.dart';

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = 'USD';

  DropdownButton<String> androidDropdown() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (String currency in currenciesList) {
      dropdownItems.add(DropdownMenuItem(
        value: currency,
        child: Text(currency),
      ));
    }
    return DropdownButton<String>(
      value: selectedCurrency,
      items: dropdownItems,
      onChanged: (value) {
        setState(() {
          selectedCurrency = value!;
          getSpotPrice();
        });
      },
    );
  }

  CupertinoPicker iOSPicker() {
    List<Widget> pickerItems = [];
    for (String currency in currenciesList) {
      pickerItems.add(Text(currency));
    }
    return CupertinoPicker(
      backgroundColor: Colors.lightBlue,
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        setState(() {
          selectedCurrency = currenciesList[selectedIndex];
          getSpotPrice();
        });
      },
      children: pickerItems,
    );
  }

  double btcPrice = 0;
  double ethPrice = 0;
  double ltcPrice = 0;
  bool isLoading = true;

  void getSpotPrice() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // Get BTC price
      CoinData btcData = CoinData(
        assetIDBase: 'BTC',
        assetIDQuote: selectedCurrency,
      );
      double btcSpotPrice = await btcData.getExchangeRate();
      
      // Get ETH price
      CoinData ethData = CoinData(
        assetIDBase: 'ETH',
        assetIDQuote: selectedCurrency,
      );
      double ethSpotPrice = await ethData.getExchangeRate();
      
      // Get LTC price
      CoinData ltcData = CoinData(
        assetIDBase: 'LTC',
        assetIDQuote: selectedCurrency,
      );
      double ltcSpotPrice = await ltcData.getExchangeRate();
      
      setState(() {
        btcPrice = btcSpotPrice;
        ethPrice = ethSpotPrice;
        ltcPrice = ltcSpotPrice;
        isLoading = false;
      });
    } catch (e) {
      print('Error getting prices: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getSpotPrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CryptoCard(
                  cryptoName: 'BTC',
                  price: btcPrice,
                  selectedCurrency: selectedCurrency,
                  isLoading: isLoading,
                ),
                SizedBox(height: 15.0),
                CryptoCard(
                  cryptoName: 'ETH',
                  price: ethPrice,
                  selectedCurrency: selectedCurrency,
                  isLoading: isLoading,
                ),
                SizedBox(height: 15.0),
                CryptoCard(
                  cryptoName: 'LTC',
                  price: ltcPrice,
                  selectedCurrency: selectedCurrency,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: Platform.isIOS ? iOSPicker() : androidDropdown(),
          ),
        ],
      ),
    );
  }
}

class CryptoCard extends StatelessWidget {
  final String cryptoName;
  final double price;
  final String selectedCurrency;
  final bool isLoading;

  const CryptoCard({
    Key? key,
    required this.cryptoName,
    required this.price,
    required this.selectedCurrency,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lightBlueAccent,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
        child: Text(
          isLoading
              ? 'Loading...'
              : '1 $cryptoName = ${_formatPrice(price, selectedCurrency)}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price, String currencyCode) {
    // Create a NumberFormat instance for the selected currency
    final formatter = NumberFormat.currency(
      locale: 'en_US',  // Base locale for formatting
      symbol: '',       // We'll add the symbol separately
      decimalDigits: 2, // Show 2 decimal places
    );
    
    // Format the price with commas and decimal places
    String formattedPrice = formatter.format(price);
    
    // Get the currency symbol
    String currencySymbol = _getCurrencySymbol(currencyCode);
    
    return '$currencySymbol$formattedPrice $currencyCode';
  }
  
  String _getCurrencySymbol(String currencyCode) {
    // Common currency symbols
    Map<String, String> symbols = {
      'USD': '\$', 'EUR': '€', 'GBP': '£', 'JPY': '¥',
      'AUD': 'A\$', 'CAD': 'C\$', 'CHF': 'Fr', 'CNY': '¥',
      'HKD': 'HK\$', 'NZD': 'NZ\$', 'SEK': 'kr', 'NOK': 'kr',
      'BRL': 'R\$', 'RUB': '₽', 'INR': '₹', 'MXN': 'Mex\$',
      'ZAR': 'R', 'SGD': 'S\$', 'ILS': '₪', 'IDR': 'Rp',
      'PLN': 'zł', 'RON': 'lei',
    };
    
    return symbols[currencyCode] ?? currencyCode;
  }
}
