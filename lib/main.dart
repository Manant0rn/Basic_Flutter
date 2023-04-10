import 'dart:convert';

import 'package:flutter/material.dart';
import 'foodmenu.dart';
import 'moneybox.dart';
import 'package:http/http.dart' as http;
import 'ExchangeRate.dart';

void main() {
  var app = Myapp();
  runApp(app);
}

//สร้าง Widget แบบคงที่
class Myapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My App",
      home: MyHomepage(),
      theme: ThemeData(primarySwatch: Colors.red),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomepage extends StatefulWidget {
  @override
  State<MyHomepage> createState() => _MyHomepageState();
}

class _MyHomepageState extends State<MyHomepage> {
  late ExchangeRate _dataFromAPI;

  String txt_number = "";
  double amount = 1;

  void _handleSubmitted(String value) {
    setState(() {
      txt_number = value;
    });
  }

  @override
  void initState() {
    super.initState();
    print("เรียกใช้งาน initstate");
    GetExchangeRate();
  }

  Future<ExchangeRate> GetExchangeRate() async {
    print("ดึงข้อมูลสกุลเงินมาใช้งาน");
    var url = Uri.parse('https://api.exchangerate-api.com/v4/latest/THB');
    var response = await http.get(url);
    _dataFromAPI = exchangeRateFromJson(response.body);
    return _dataFromAPI;
  }

  @override
  Widget build(BuildContext context) {
    print("เรียกใช้งาน Build");

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Hello Flutter โปรแกรมคำนวณสกุลเงิน",
            style: TextStyle(
                fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(children: [
          FutureBuilder(
            future: GetExchangeRate(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                var result = snapshot.data;
                return Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    moneybox("THB (ค่าเริ่มต้น)", amount, Colors.lightBlue, 120),
                    const SizedBox(
                      height: 5,
                    ),
                    moneybox("EUR", amount*result.rates["EUR"], Colors.green, 120),
                    const SizedBox(
                      height: 5,
                    ),
                    moneybox("USD", amount*result.rates["USD"], Colors.red, 120),
                    const SizedBox(
                      height: 5,
                    )
                  ],
                );
              }
              return LinearProgressIndicator();
            },
          ),
          const SizedBox(height: 30,),
          TextField(
            onChanged: _handleSubmitted,
            keyboardType: TextInputType.number,
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                amount = double.parse(txt_number);
              });
            },
            child: const Text("คำนวณสกุลเงิน"),
          )
        ]));
  }
}
