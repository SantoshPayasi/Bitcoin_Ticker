import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'coinList.dart';

void main() {
  runApp(BitCoinTicker());
}

class BitCoinTicker extends StatefulWidget {
  const BitCoinTicker({Key? key}) : super(key: key);

  @override
  State<BitCoinTicker> createState() => _BitCoinTickerState();
}


class _BitCoinTickerState extends State<BitCoinTicker> {
  int _selectedItem = 0;
  String _selectedInAndroid = currenciesList[0];
  bool isLoading = true;
  List<double> RateList = [];

 getCoinDetails() async {
   RateList.clear();
    final futures = cryptoList.map((element) async {
      final uri = Uri.parse(
          "https://rest.coinapi.io/v1/exchangerate/${element}/${_selectedInAndroid}");
      final headers = {'X-CoinAPI-Key': 'D1C2EB97-413A-47A8-A15E-DE37E5CF0CC6'};
      final response = await http.get(uri, headers: headers);
      return response;
    });
    final responses = await Future.wait(futures);
    for (var response in responses) {
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        double rate = jsonData['rate']; // Assuming the exchange rate is available under the 'rate' field in the API response
        RateList.add(rate);
      } else {
        // Handle API error if needed
        print("API Error: ${response.statusCode} - ${response.body}");
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getCoinDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bitcoin Ticker'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isLoading
                ? const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: CircularProgressIndicator())
                : Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        CryptoItems(
                            selectedInAndroid: _selectedInAndroid,
                            RateList: {'coinData': RateList[0], 'index': 0}),
                        CryptoItems(
                            selectedInAndroid: _selectedInAndroid,
                            RateList:  {'coinData': RateList[1], 'index': 1}),
                        CryptoItems(
                            selectedInAndroid: _selectedInAndroid,
                            RateList: {'coinData': RateList[2], 'index': 2}),
                      ],
                    ),
                  ),
            Container(
              height: 100,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              color: Colors.blueAccent,
              child: (Platform.isIOS)
                  ? CupertinoPicker(
                      backgroundColor: Colors.blueAccent,
                      diameterRatio: 1.0,
                      itemExtent: 32,
                      onSelectedItemChanged: (int value) {
                        print(value);
                        setState(() {
                          _selectedItem = value;
                        });
                      },
                      children: currenciesList
                          .map((e) => Text(
                                "${e}",
                                style: TextStyle(color: Colors.white),
                              ))
                          .toList(),
                    )
                  : DropdownButton(
                      dropdownColor: Colors.blue.shade300,
                      items: currenciesList
                          .map<DropdownMenuItem<String>>(
                              (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      '${e}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ))
                          .toList(),
                      value: _selectedInAndroid,
                      onChanged: (value) {
                        setState(() {
                          _selectedInAndroid = value!;
                          isLoading = true;
                        });
                        getCoinDetails();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class CryptoItems extends StatelessWidget {
  const CryptoItems({
    super.key,
    required String selectedInAndroid,
    required this.RateList,
  }) : _selectedInAndroid = selectedInAndroid;

  final String _selectedInAndroid;
  final Map<String, dynamic> RateList;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.blue,
      ),
      alignment: Alignment.center,
      height: 40,
      child: Card(
        color: Colors.blue,
        elevation: 0,
        child: Text('1 ${_selectedInAndroid} = ${RateList['coinData'].toInt()} ${cryptoList[RateList['index']]}', style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600
        ),),
      ),
    );
  }
}


