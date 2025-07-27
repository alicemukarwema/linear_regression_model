class PredictionInput {
 String region;
   String soilType;
   String crop;
   double rainfall;
  double temperature;
   bool fertilizerUsed;
  bool irrigationUsed;
   String weatherCondition;
   int daysToHarvest;

  PredictionInput({
    required this.region,
    required this.soilType,
    required this.crop,
    required this.rainfall,
    required this.temperature,
    required this.fertilizerUsed,
    required this.irrigationUsed,
    required this.weatherCondition,
    required this.daysToHarvest,
  });

  Map<String, dynamic> toJson() {
    return {
      'Region': region,
      'Soil_Type': soilType,
      'Crop': crop,
      'Rainfall_mm': rainfall,
      'Temperature_Celsius': temperature,
      'Fertilizer_Used': fertilizerUsed,
      'Irrigation_Used': irrigationUsed,
      'Weather_Condition': weatherCondition,
      'Days_to_Harvest': daysToHarvest,
    };
  }
}