from .model import CropData, AssessmentResult


def calculateFinancials(data: CropData) -> AssessmentResult:
    total_income = data.quantitySold * data.salePricePerQuintal
    profit = total_income + data.governmentSubsidy - data.totalCost
    financial_stability = (profit / data.totalCost * 100) if data.totalCost != 0 else 0
    cash_flow = (data.totalCost / total_income * 100) if total_income != 0 else 0
    total_expense = data.totalCost

    return AssessmentResult(
        **data.dict(),
        financialStability=financial_stability,
        cashFlow=cash_flow,
    )


def makeRecommendations(data: CropData) -> dict:
    result = calculateFinancials(data)

    if result.financialStability >= 50 and result.cashFlow <= 50:
        recommendation = (
            "Your financial stability is in a strong position, and your cash flow indicates healthy business operations. "
            "At this stage, it would be beneficial to reinvest your profits into expanding your business, optimizing production, or improving efficiency. "
            "Since you are not heavily reliant on external funding, maintaining a financial buffer for unexpected costs is advisable. "
            "Additionally, exploring new opportunities such as expanding your market reach or diversifying your product line could further strengthen your position."
        )
    else:
        recommendation = (
            "Your financial stability and cash flow are currently not at an optimal level, which may pose challenges in sustaining operations. "
            "It would be wise to explore funding options, such as applying for a business loan or seeking government grants, to support your financial needs. "
            "Additionally, focusing on cost-cutting measures, improving operational efficiency, and increasing revenue streams through better pricing strategies or higher sales volumes "
            "can help stabilize your finances. Careful financial planning and seeking expert advice could also contribute to long-term business sustainability."
        )

    return {
        "recommendation": recommendation,
    }
