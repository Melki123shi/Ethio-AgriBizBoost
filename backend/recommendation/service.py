from .model import AssessmentResult
from health_assessment.service import calculateFinancials

def makeRecommendations(data: AssessmentResult):

    assessment_result = calculateFinancials(data)

    if isinstance(assessment_result, dict):
        assessment_result = AssessmentResult(**assessment_result)

    financial_stability = assessment_result.financialStability

    cash_flow = assessment_result.cashFlow

    if financial_stability >= 50 and cash_flow <= 50:
        return (
            "Your financial stability is in a strong position, and your cash flow indicates healthy business operations. "
            "At this stage, it would be beneficial to reinvest your profits into expanding your business, optimizing production, or improving efficiency. "
            "Since you are not heavily reliant on external funding, maintaining a financial buffer for unexpected costs is advisable. "
            "Additionally, exploring new opportunities such as expanding your market reach or diversifying your product line could further strengthen your position."
        )
    else:
        return (
            "Your financial stability and cash flow are currently not at an optimal level, which may pose challenges in sustaining operations. "
            "It would be wise to explore funding options, such as applying for a business loan or seeking government grants, to support your financial needs. "
            "Additionally, focusing on cost-cutting measures, improving operational efficiency, and increasing revenue streams through better pricing strategies or higher sales volumes "
            "can help stabilize your finances. Careful financial planning and seeking expert advice could also contribute to long-term business sustainability."
        )
