from .model import CropData

def calculateFinancials(data: CropData):
    totalIncome = data.quantitySold * data.salePricePerQuintal

    profit = totalIncome + data.governmentSubsidy - data.totalCost

    financialStability = (profit / data.totalCost * 100) if data.totalCost != 0 else 0

    cashFlow = (data.totalCost/ totalIncome * 100) if totalIncome != 0 else 0

    totalExpense = data.totalCost

    return {
        "totalIncome": totalIncome,
        "profit": profit,
        "financialStability": financialStability,
        "cashFlow": cashFlow,
        "totalExpense": totalExpense,
    }
