from .model import CropData

def calculate_financials(data: CropData):
    revenue = data.quantity_sold * data.sale_price_per_quintal

    profit = revenue + data.government_subsidy - data.total_cost

    financial_stability = (profit / data.total_cost * 100) if data.total_cost != 0 else 0

    cash_flow = (data.total_cost/ revenue * 100) if revenue != 0 else 0

    return {
        "revenue": revenue,
        "profit": profit,
        "financial_stability": financial_stability,
        "cash_flow": cash_flow,
    }
