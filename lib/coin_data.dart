import 'dart:convert';
import 'package:http/http.dart' as http;

const List<String> currenciesList = [
  'AUD',
  'BRL',
  'CAD',
  'CNY',
  'EUR',
  'GBP',
  'HKD',
  'IDR',
  'ILS',
  'INR',
  'JPY',
  'MXN',
  'NOK',
  'NZD',
  'PLN',
  'RON',
  'RUB',
  'SEK',
  'SGD',
  'USD',
  'ZAR'
];

const List<String> cryptoList = [
  'BTC',
  'ETH',
  'LTC',
];

class CoinData {
  final String assetIDBase;
  final String assetIDQuote;

  CoinData({required this.assetIDBase, required this.assetIDQuote});

  Future<double> getExchangeRate() async {
    // Convert crypto symbols to CoinGecko format
    Map<String, String> cryptoIds = {
      'BTC': 'bitcoin',
      'ETH': 'ethereum',
      'LTC': 'litecoin',
    };

    String cryptoId = cryptoIds[assetIDBase.toUpperCase()] ?? 'bitcoin';
    String currency = assetIDQuote.toLowerCase();

    String url =
        'https://api.coingecko.com/api/v3/simple/price?ids=$cryptoId&vs_currencies=$currency';

    try {
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        return decodedData[cryptoId][currency].toDouble();
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
            'Failed to load exchange rate data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching exchange rate data: $e');
      throw Exception('Failed to load exchange rate data: $e');
    }
  }
}
