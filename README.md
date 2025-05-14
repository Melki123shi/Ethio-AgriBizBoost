# Ethio-AgriBoost

An AI-based Farmers as Small Business Advisor web application that offers business health assessment, financial forecasts, personalized recommendations, and compliance alerts.

## Introduction

Ethio-AgriBoost addresses the critical need for business management tools tailored specifically for small-scale farmers in Ethiopia. Many farmers lack access to financial expertise and business analytics that could significantly improve their profitability and sustainability. This application bridges that gap by providing AI-powered business insights, financial forecasting, and actionable recommendations that empower farmers to make data-driven decisions for their agricultural businesses.

## Features

### Business Health Assessment

- **Profitability Analysis**: Evaluates revenue streams and cost structures to determine overall profitability
- **Cash Flow Management**: Monitors cash inflows and outflows to identify liquidity issues
- **Financial Stability Metrics**: Assesses debt-to-asset ratios and other indicators of long-term financial health

### Financial Forecasting

- **Price & Demand Prediction**: Uses machine learning models to forecast market prices and demand for agricultural products
- **Revenue & Expense Forecasting**: Projects future financial performance based on historical data and market trends
- **Scenario Planning**: Allows farmers to test different business strategies and see potential outcomes

### Personalized Recommendations

- **Cost-Cutting Strategies**: Identifies areas where expenses can be reduced without impacting productivity
- **Higher Yield Crop Investments**: Suggests crop diversification or specialization based on market opportunities
- **Loan & Financing Advice**: Provides guidance on accessing appropriate financial services and managing debt

## Installation

### Prerequisites

- Python 3.8 or higher
- Flutter SDK (version 2.0+)
- Internet connection for model downloads

### Backend Setup

1. Clone the repository:

   ```
   git clone https://github.com/Melki123shi/Ethio-AgriBizBoost.git
   cd Ethio-AgriBizBoost/backend
   ```

2. Install required Python packages:

   ```
   pip install -r requirements.txt
   ```

3. Start the backend server:
   ```
   python main.py
   ```

### Frontend Setup

1. Navigate to the frontend directory:

   ```
   cd ../frontend
   ```

2. Get Flutter dependencies:

   ```
   flutter pub get
   ```

3. Run the application:
   ```
   flutter run
   ```
4. Adding Localization

Generate localization files for every feature by running the following command from the root directory:

```bash
dart run frontend/lib/l10n/generate_localizations.dart
```
## Usage

1. **Business Health Assessment**:

   - Input your farm's financial data (income, expenses, assets, liabilities)
   - Review the generated health metrics and identified areas of concern

2. **Financial Forecasting**:

   - Select crops and time periods for price and demand predictions
   - View projected revenue and expenses based on current operations

3. **Personalized Recommendations**:
   - Access tailored business advice based on your farm's specific financial profile
   - Explore suggested strategies for improving profitability and financial stability

## Technology Stack

- **Backend**: Python with FastAPI framework
- **Frontend**: Flutter for cross-platform mobile and web applications
- **Machine Learning**: CatBoost models for price, demand, and recommendation engines
- **Data Storage**: Local storage with future cloud integration

## Roadmap

- Integration with local weather data for improved forecasting
- Offline functionality for areas with limited connectivity
- Marketplace connections to facilitate direct sales
- Community features for knowledge sharing among farmers
- Multi-language support with additional local languages

## Contributing

Contributions to Ethio-AgriBoost are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Please ensure your code follows the project's coding standards and includes appropriate tests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

Project Link: [https://github.com/Melki123shi/Ethio-AgriBizBoost](https://github.com/Melki123shi/Ethio-AgriBizBoost)
