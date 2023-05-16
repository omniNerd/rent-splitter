import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  runApp(const RentSplitter());
}

class RentSplitter extends StatelessWidget {
  const RentSplitter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Rent Splitter'),
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: RentForm(),
        ),
      ),
    );
  }
}

class RentForm extends StatefulWidget {
  const RentForm({super.key});

  @override
  _RentFormState createState() => _RentFormState();
}

class _RentFormState extends State<RentForm> {
  final _formKey = GlobalKey<FormState>();
  double rent = 0;
  int people = 2;
  List<double> wages = List.filled(4, 0);
  List<double> rentShares = List.filled(4, 0);
  List<TextEditingController> controllers = List.generate(4, (index) => TextEditingController());

  late BannerAd _ad;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _ad = BannerAd(
      adUnitId: 'ca-app-pub-1758839910776370/2931898369', // Replace 'ad-unit-id' with your actual ad unit id.
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Ad failed to load with error: $error');
          ad.dispose();
        },
      ),
    );

    _ad.load();
  }

  @override
  void dispose() {
    _ad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_isAdLoaded)
            SizedBox(
              width: _ad.size.width.toDouble(),
              height: _ad.size.height.toDouble(),
              child: AdWidget(ad: _ad),
            ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Total Rent'),
            keyboardType: TextInputType.number,
            validator: (value) => value != null && value.isNotEmpty && double.tryParse(value) != null ? null : 'Please enter a valid number',
            onChanged: (value) => setState(() => rent = double.tryParse(value) ?? 0),
          ),
          DropdownButtonFormField<int>(
            value: people,
            decoration: const InputDecoration(labelText: 'Number of People'),
            items: [2, 3, 4].map((number) {
              return DropdownMenuItem(
                value: number,
                child: Text(number.toString()),
              );
            }).toList(),
            onChanged: (value) => setState(() => people = value ?? 2),
          ),
          ...List.generate(people, (index) => TextFormField(
            controller: controllers[index],
            decoration: InputDecoration(labelText: 'Hourly Wage for Person ${index + 1}'),
            keyboardType: TextInputType.number,
            validator: (value) => value != null && value.isNotEmpty && double.tryParse(value) != null ? null : 'Please enter a valid number',
            onChanged: (value) => setState(() => wages[index] = double.tryParse(value) ?? 
                        0),
          )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              child: const Text('Calculate'),
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  setState(() {
                    double totalWage = wages.sublist(0, people).reduce((value, element) => value + element);
                    for (int i = 0; i < people; i++) {
                      rentShares[i] = wages[i] / totalWage * rent;
                    }
                  });
                }
              },
            ),
          ),
          ...List.generate(people, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text('Rent for Person ${index + 1}: ${rentShares[index].toStringAsFixed(2)}'),
          )),
        ],
      ),
    );
  }
}

