import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'result_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String baseUrl = "https://linear-regression-model-gjes.onrender.com";
  final String predictEndpoint = "/predict";
  
  final _formKey = GlobalKey<FormState>();
  String? _region;
  String? _soilType;
  String? _crop;
  double? _rainfall;
  double? _temperature;
  bool _fertilizerUsed = false;
  bool _irrigationUsed = false;
  String? _weatherCondition;
  int? _daysToHarvest;
  
  bool _isLoading = false;

  final List<String> regions = ["North", "South", "East", "West"];
  final List<String> soilTypes = ["Sandy", "Clay", "Loam", "Silt"];
  final List<String> crops = ["Cotton", "Rice", "Barley", "Soybean", "Wheat"];
  final List<String> weatherConditions = ["Sunny", "Cloudy", "Rainy"];

  Future<void> _predictYield() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$predictEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "Region": _region,
          "Soil_Type": _soilType,
          "Crop": _crop,
          "Rainfall_mm": _rainfall,
          "Temperature_Celsius": _temperature,
          "Fertilizer_Used": _fertilizerUsed,
          "Irrigation_Used": _irrigationUsed,
          "Weather_Condition": _weatherCondition,
          "Days_to_Harvest": _daysToHarvest,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              predictionResult: responseData['predicted_yield'],
              inputValues: {
                'Region': _region,
                'Soil Type': _soilType,
                'Crop': _crop,
                'Rainfall (mm)': _rainfall,
                'Temperature (°C)': _temperature,
                'Fertilizer Used': _fertilizerUsed ? 'Yes' : 'No',
                'Irrigation Used': _irrigationUsed ? 'Yes' : 'No',
                'Weather Condition': _weatherCondition,
                'Days to Harvest': _daysToHarvest,
              },
            ),
          ),
        );
      } else {
        throw Exception(responseData['detail'] ?? 'Failed to get prediction');
      }
    } catch (e) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            errorMessage: e.toString(),
            inputValues: {
              'Region': _region,
              'Soil Type': _soilType,
              'Crop': _crop,
              // Include other fields...
            },
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crop Yield Prediction")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Region Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Region *"),
                items: regions.map((region) => DropdownMenuItem(
                  value: region,
                  child: Text(region),
                )).toList(),
                onChanged: (value) => setState(() => _region = value),
                validator: (value) => value == null ? "Please select region" : null,
              ),
              SizedBox(height: 15),
              
              // Soil Type Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Soil Type *"),
                items: soilTypes.map((soil) => DropdownMenuItem(
                  value: soil,
                  child: Text(soil),
                )).toList(),
                onChanged: (value) => setState(() => _soilType = value),
                validator: (value) => value == null ? "Please select soil type" : null,
              ),
              SizedBox(height: 15),
              
              // Crop Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Crop *"),
                items: crops.map((crop) => DropdownMenuItem(
                  value: crop,
                  child: Text(crop),
                )).toList(),
                onChanged: (value) => setState(() => _crop = value),
                validator: (value) => value == null ? "Please select crop" : null,
              ),
              SizedBox(height: 15),
              
              // Rainfall Input
              TextFormField(
                decoration: InputDecoration(labelText: "Rainfall (mm) *"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter rainfall";
                  final num = double.tryParse(value);
                  if (num == null) return "Enter valid number";
                  if (num < 0 || num > 2000) return "Must be between 0-2000";
                  return null;
                },
                onSaved: (value) => _rainfall = double.parse(value!),
              ),
              SizedBox(height: 15),
              
              // Temperature Input
              TextFormField(
                decoration: InputDecoration(labelText: "Temperature (°C) *"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter temperature";
                  final num = double.tryParse(value);
                  if (num == null) return "Enter valid number";
                  if (num < -20 || num > 50) return "Must be between -20 and 50";
                  return null;
                },
                onSaved: (value) => _temperature = double.parse(value!),
              ),
              SizedBox(height: 15),
              
              // Fertilizer Switch
              SwitchListTile(
                title: Text("Fertilizer Used"),
                value: _fertilizerUsed,
                onChanged: (value) => setState(() => _fertilizerUsed = value),
              ),
              
              // Irrigation Switch
              SwitchListTile(
                title: Text("Irrigation Used"),
                value: _irrigationUsed,
                onChanged: (value) => setState(() => _irrigationUsed = value),
              ),
              SizedBox(height: 15),
              
              // Weather Condition Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Weather Condition *"),
                items: weatherConditions.map((weather) => DropdownMenuItem(
                  value: weather,
                  child: Text(weather),
                )).toList(),
                onChanged: (value) => setState(() => _weatherCondition = value),
                validator: (value) => value == null ? "Please select weather" : null,
              ),
              SizedBox(height: 15),
              
              // Days to Harvest Input
              TextFormField(
                decoration: InputDecoration(labelText: "Days to Harvest *"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter days";
                  final num = int.tryParse(value);
                  if (num == null) return "Enter valid number";
                  if (num < 1 || num > 365) return "Must be 1-365";
                  return null;
                },
                onSaved: (value) => _daysToHarvest = int.parse(value!),
              ),
              SizedBox(height: 25),
              
              // Predict Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _predictYield,
                  child: _isLoading 
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("PREDICT YIELD", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}