// mappings_pruned.dart

// List of Regions
const List<String> regions = ["Tigray", "Oromia", "SNNP"];

// Region → Zones
const Map<String, List<String>> regionZoneMapping = {
  "Tigray": [
    "West Tigray",
    "North Western Tigray",
    "South Tigray",
    "East Tigray",
    "Central Tigray",
    "Mekele Special Zone",
  ],
  "Oromia": [
    "North Shewa",
    "East Harerghe",
  ],
  "SNNP": [
    "Gedeo",
    "Siliti",
  ],
};

// Zone → Woredas
const Map<String, List<String>> zoneWoredaMapping = {
  "West Tigray": ["Humera Town"],
  "North Western Tigray": ["Tahtay-Koraro", "Tahtay-Adiyabo"],
  "South Tigray": ["Maychew Town", "Raya-Alamata"],
  "East Tigray": ["Adigrat"],
  "Central Tigray": ["Aksum"],
  "Mekele Special Zone": ["Mekele Town"],
  "North Shewa": ["Fiche City Administration"],
  "East Harerghe": ["Haromaya"],
  "Gedeo": ["Dilla City Administration"],
  "Siliti": ["Dalocha"],
};

// Woreda → Markets
const Map<String, List<String>> woredaMarketMapping = {
  "Humera Town": ["Humera"],
  "Tahtay-Koraro": ["Shire-Endaselassie"],
  "Tahtay-Adiyabo": ["Sheraro"],
  "Maychew Town": ["Maychew"],
  "Raya-Alamata": ["Alamata"],
  "Adigrat": ["Adigrat"],
  "Aksum": ["Aksum"],
  "Mekele Town": ["Mekele Town"],
  "Fiche City Administration": ["Fiche"],
  "Haromaya": ["Harar"],
  "Dilla City Administration": ["Dilla"],
  "Dalocha": ["Dalocha"],
};

// Market → Crops
const Map<String, List<String>> marketCropNameMapping = {
  "Humera": [
    "Teff",
    "Wheat",
  ],
  "Shire-Endaselassie": [
    "Teff",
    "Wheat",
    "Maize",
    "Garlic",
    "Onion",
    "Potato",
    "Tomato",
    "Red Pepper",
    "Sorghum",
    "Banana",
  ],
  "Maychew": [
    "Maize",
    "Teff",
    "Sorghum",
    "Red Pepper",
    "Garlic",
    "Onion",
    "Potato",
    "Tomato",
    "Mango",
    "Avocado",
    "Wheat",
    "Banana",
  ],
  "Sheraro": [
    "Teff",
    "Sorghum",
    "Maize",
    "Onion",
    "Garlic",
    "Potato",
    "Tomato",
    "Sesame",
    "Wheat",
    "Banana",
  ],
  "Adigrat": [
    "Teff",
    "Maize",
    "Wheat",
    "Red Pepper",
    "Garlic",
    "Onion",
    "Potato",
    "Tomato",
    "Banana",
  ],
  "Aksum": [
    "Maize",
    "Teff",
    "Red Pepper",
    "Garlic",
    "Onion",
    "Potato",
    "Tomato",
    "Mango",
    "Avocado",
    "Wheat",
    "Sorghum",
  ],
  "Mekele Town": [
    "Teff",
    "Wheat",
    "Maize",
    "Sorghum",
    "Red Pepper",
    "Garlic",
    "Onion",
    "Potato",
    "Tomato",
    "Mango",
    "Avocado",
    "Banana",
  ],
  "Fiche": [
    "Teff",
    "Maize",
    "Wheat",
  ],
  "Dilla": [
    "Maize",
    "Teff",
    "Wheat",
    "Banana",
    "Potato",
    "Onion",
    "Malt Barely",
  ],
  "Harar": [
    "Teff",
    "Wheat",
    "Maize",
  ],
  "Dalocha": [
    "Teff",
    "Wheat",
    "Maize",
    "Sorghum",
    "Red Pepper",
    "Malt Barely",
    "Local Rice",
    "Potato",
    "Onion",
    "Tomato",
    "Mango",
    "Avocado",
    "Garlic",
    "Banana",
    "Sesame",
  ],
  "Alamata": [
    "Sorghum",
    "Teff",
    "Maize",
    "Potato",
    "Tomato",
    "Onion",
    "Garlic",
    "Red Pepper",
  ],
};

// Crop → Varieties
const Map<String, List<String>> cropNameVarietyMapping = {
  "Teff": ["Mixed Teff", "White Teff", "Red Teff"],
  "Maize": ["White Maize"],
  "Wheat": ["White Wheat"],
  "Bean": ["White pea bean", "Red kidney bean", "Mixed Bean"],
  "Sesame": ["White Sesame", "Red Sesame", "Mixed Sesame"],
  "Onion": ["Onion"],
  "Tomato": ["Tomato"],
  "Avocado": ["Avocado"],
  "Potato": ["Potato"],
  "Garlic": ["Garlic"],
  "Red Pepper": ["Red Pepper"],
  "Banana": ["Raw Bananas", "Ripe bananas"],
  "Sorghum": ["Sorghum"],
  "Soybean": ["Soybean"],
  "Mango": ["Mango"],
  "Malt Barely": ["Malt Barely"],
  "Local Rice": ["Local Rice"],
  "Green Mung": ["Green Mung"],
  "Pineapple": ["Pineapple"],
};

const List<String> seasons  = ["bega", "kiramit", "belg", "tsedey"];