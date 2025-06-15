
import React from 'react';
import { useParams } from 'react-router-dom';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
  User,
  Phone,
  MapPin,
  Calendar,
  Activity,
  DollarSign,
  TrendingUp,
  Eye,
  MessageSquare,
  Download,
  AlertTriangle
} from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar, PieChart, Pie, Cell } from 'recharts';

// Mock detailed farmer data
const farmerData = {
  id: '1',
  name: 'Abebe Kebede',
  phone: '+251912345678',
  location: 'Oromia, Arsi Zone',
  registrationDate: '2023-06-15',
  lastActive: '2024-01-14T08:30:00Z',
  totalLogins: 45,
  engagementScore: 78.5,
  riskLevel: 'low',
  status: 'active',
  expenses: {
    totalExpenses: 45000,
    totalRevenue: 78000,
    totalProfit: 33000,
    expenseCount: 124,
    assessmentCount: 8,
    mostTradedGoods: [
      { name: 'Wheat', count: 45 },
      { name: 'Teff', count: 38 },
      { name: 'Barley', count: 22 }
    ],
    financialStability: 72.5,
    cashFlow: 68.3,
    monthlyTrends: [
      { month: 'Jul', expenses: 5000, revenue: 8000, profit: 3000 },
      { month: 'Aug', expenses: 6000, revenue: 9000, profit: 3000 },
      { month: 'Sep', expenses: 7000, revenue: 10000, profit: 3000 },
      { month: 'Oct', expenses: 8000, revenue: 12000, profit: 4000 },
      { month: 'Nov', expenses: 9000, revenue: 15000, profit: 6000 },
      { month: 'Dec', expenses: 10000, revenue: 24000, profit: 14000 }
    ]
  },
  forecasting: {
    totalPredictions: 28,
    regionsQueried: ['Oromia', 'Amhara'],
    cropsQueried: ['Wheat', 'Teff', 'Maize'],
    mostFrequentQueries: [
      { query: 'Oromia_Wheat', count: 12 },
      { query: 'Oromia_Teff', count: 8 },
      { query: 'Amhara_Wheat', count: 5 },
      { query: 'Oromia_Maize', count: 3 }
    ],
    predictionAccuracy: 85.7
  },
  health: {
    totalAssessments: 15,
    cropTypesAssessed: ['Wheat', 'Teff'],
    averageProfitMargin: 42.3,
    totalSubsidies: 12000,
    assessmentHistory: [
      { date: '2024-01-10', crop: 'Wheat', profitMargin: 45.2, subsidies: 2000 },
      { date: '2024-01-05', crop: 'Teff', profitMargin: 38.1, subsidies: 1500 },
      { date: '2023-12-28', crop: 'Wheat', profitMargin: 42.8, subsidies: 1800 }
    ]
  },
  recommendations: {
    loanAdviceCount: 3,
    costCuttingCount: 5,
    topics: ['loan_advice', 'cost_cutting_strategies'],
    recentRecommendations: [
      { date: '2024-01-08', type: 'Cost Cutting', description: 'Optimize fertilizer usage for Wheat production' },
      { date: '2024-01-05', type: 'Loan Advice', description: 'Consider micro-credit for equipment upgrade' },
      { date: '2023-12-30', type: 'Cost Cutting', description: 'Bulk purchasing recommendation for seeds' }
    ]
  }
};

const FarmerDetails: React.FC = () => {
  const { id } = useParams();

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-ET', {
      style: 'currency',
      currency: 'ETB',
      minimumFractionDigits: 0,
    }).format(amount);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString();
  };

  const getRiskBadgeColor = (risk: string) => {
    switch (risk) {
      case 'low': return 'bg-green-100 text-green-800';
      case 'medium': return 'bg-yellow-100 text-yellow-800';
      case 'high': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const pieColors = ['#22c55e', '#3b82f6', '#f59e0b', '#ef4444'];

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-start">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">{farmerData.name}</h1>
          <p className="text-muted-foreground">Farmer ID: {farmerData.id}</p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline">
            <MessageSquare className="w-4 h-4 mr-2" />
            Send Message
          </Button>
          <Button variant="outline">
            <Download className="w-4 h-4 mr-2" />
            Export Data
          </Button>
        </div>
      </div>

      {/* Profile Overview */}
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Contact Info</CardTitle>
            <Phone className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-lg font-bold">{farmerData.phone}</div>
            <p className="text-xs text-muted-foreground flex items-center mt-1">
              <MapPin className="w-3 h-3 mr-1" />
              {farmerData.location}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Account Status</CardTitle>
            <Activity className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="flex items-center gap-2">
              <Badge variant={farmerData.status === 'active' ? 'default' : 'secondary'}>
                {farmerData.status}
              </Badge>
              <Badge className={getRiskBadgeColor(farmerData.riskLevel)}>
                {farmerData.riskLevel} risk
              </Badge>
            </div>
            <p className="text-xs text-muted-foreground mt-1">
              {farmerData.totalLogins} total logins
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Engagement Score</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">
              {farmerData.engagementScore}%
            </div>
            <p className="text-xs text-muted-foreground">
              Above average performance
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Profit</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">
              {formatCurrency(farmerData.expenses.totalProfit)}
            </div>
            <p className="text-xs text-muted-foreground">
              From {farmerData.expenses.expenseCount} transactions
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Detailed Tabs */}
      <Tabs defaultValue="expenses" className="space-y-4">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="expenses">Expense Tracking</TabsTrigger>
          <TabsTrigger value="forecasting">Forecasting</TabsTrigger>
          <TabsTrigger value="health">Health Assessment</TabsTrigger>
          <TabsTrigger value="recommendations">Recommendations</TabsTrigger>
        </TabsList>

        <TabsContent value="expenses" className="space-y-4">
          <div className="grid gap-6 md:grid-cols-3">
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Financial Overview</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex justify-between">
                  <span className="text-sm">Total Revenue:</span>
                  <span className="font-medium text-green-600">
                    {formatCurrency(farmerData.expenses.totalRevenue)}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm">Total Expenses:</span>
                  <span className="font-medium text-red-600">
                    {formatCurrency(farmerData.expenses.totalExpenses)}
                  </span>
                </div>
                <div className="flex justify-between border-t pt-2">
                  <span className="text-sm font-medium">Net Profit:</span>
                  <span className="font-bold text-green-600">
                    {formatCurrency(farmerData.expenses.totalProfit)}
                  </span>
                </div>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span>Financial Stability:</span>
                    <span>{farmerData.expenses.financialStability}%</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div 
                      className="bg-green-600 h-2 rounded-full" 
                      style={{ width: `${farmerData.expenses.financialStability}%` }}
                    ></div>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Most Traded Goods</CardTitle>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={200}>
                  <PieChart>
                    <Pie
                      data={farmerData.expenses.mostTradedGoods}
                      cx="50%"
                      cy="50%"
                      labelLine={false}
                      label={({ name, count }) => `${name} (${count})`}
                      outerRadius={60}
                      fill="#8884d8"
                      dataKey="count"
                    >
                      {farmerData.expenses.mostTradedGoods.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={pieColors[index % pieColors.length]} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Monthly Trends</CardTitle>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={200}>
                  <LineChart data={farmerData.expenses.monthlyTrends}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="month" />
                    <YAxis />
                    <Tooltip formatter={(value) => formatCurrency(Number(value))} />
                    <Line type="monotone" dataKey="profit" stroke="#22c55e" strokeWidth={2} />
                  </LineChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="forecasting" className="space-y-4">
          <div className="grid gap-6 md:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Prediction Statistics</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div className="text-center p-4 bg-blue-50 rounded-lg">
                    <div className="text-2xl font-bold text-blue-600">
                      {farmerData.forecasting.totalPredictions}
                    </div>
                    <div className="text-sm text-blue-600">Total Predictions</div>
                  </div>
                  <div className="text-center p-4 bg-green-50 rounded-lg">
                    <div className="text-2xl font-bold text-green-600">
                      {farmerData.forecasting.predictionAccuracy}%
                    </div>
                    <div className="text-sm text-green-600">Accuracy Rate</div>
                  </div>
                </div>
                <div className="space-y-2">
                  <div className="text-sm font-medium">Regions Queried:</div>
                  <div className="flex gap-2">
                    {farmerData.forecasting.regionsQueried.map((region) => (
                      <Badge key={region} variant="outline">{region}</Badge>
                    ))}
                  </div>
                </div>
                <div className="space-y-2">
                  <div className="text-sm font-medium">Crops Queried:</div>
                  <div className="flex gap-2">
                    {farmerData.forecasting.cropsQueried.map((crop) => (
                      <Badge key={crop} variant="outline">{crop}</Badge>
                    ))}
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Frequent Queries</CardTitle>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={250}>
                  <BarChart data={farmerData.forecasting.mostFrequentQueries}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="query" angle={-45} textAnchor="end" height={100} />
                    <YAxis />
                    <Tooltip />
                    <Bar dataKey="count" fill="#3b82f6" />
                  </BarChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="health" className="space-y-4">
          <div className="grid gap-6 md:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Assessment Overview</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div className="text-center p-4 bg-green-50 rounded-lg">
                    <div className="text-2xl font-bold text-green-600">
                      {farmerData.health.totalAssessments}
                    </div>
                    <div className="text-sm text-green-600">Total Assessments</div>
                  </div>
                  <div className="text-center p-4 bg-blue-50 rounded-lg">
                    <div className="text-2xl font-bold text-blue-600">
                      {farmerData.health.averageProfitMargin}%
                    </div>
                    <div className="text-sm text-blue-600">Avg. Profit Margin</div>
                  </div>
                </div>
                <div className="space-y-2">
                  <div className="flex justify-between">
                    <span className="text-sm">Total Subsidies:</span>
                    <span className="font-medium text-green-600">
                      {formatCurrency(farmerData.health.totalSubsidies)}
                    </span>
                  </div>
                  <div className="text-sm font-medium">Crops Assessed:</div>
                  <div className="flex gap-2">
                    {farmerData.health.cropTypesAssessed.map((crop) => (
                      <Badge key={crop} variant="outline">{crop}</Badge>
                    ))}
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Recent Assessments</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {farmerData.health.assessmentHistory.map((assessment, index) => (
                    <div key={index} className="p-3 border rounded-lg">
                      <div className="flex justify-between items-start">
                        <div>
                          <div className="font-medium">{assessment.crop}</div>
                          <div className="text-sm text-gray-500">
                            {formatDate(assessment.date)}
                          </div>
                        </div>
                        <div className="text-right">
                          <div className="text-green-600 font-medium">
                            {assessment.profitMargin}% margin
                          </div>
                          <div className="text-sm text-gray-500">
                            {formatCurrency(assessment.subsidies)} subsidies
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="recommendations" className="space-y-4">
          <div className="grid gap-6 md:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Recommendation Summary</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div className="text-center p-4 bg-orange-50 rounded-lg">
                    <div className="text-2xl font-bold text-orange-600">
                      {farmerData.recommendations.loanAdviceCount}
                    </div>
                    <div className="text-sm text-orange-600">Loan Advice</div>
                  </div>
                  <div className="text-center p-4 bg-purple-50 rounded-lg">
                    <div className="text-2xl font-bold text-purple-600">
                      {farmerData.recommendations.costCuttingCount}
                    </div>
                    <div className="text-sm text-purple-600">Cost Cutting</div>
                  </div>
                </div>
                <div className="space-y-2">
                  <div className="text-sm font-medium">Recommendation Topics:</div>
                  <div className="flex gap-2">
                    {farmerData.recommendations.topics.map((topic) => (
                      <Badge key={topic} variant="outline">
                        {topic.replace('_', ' ')}
                      </Badge>
                    ))}
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Recent Recommendations</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {farmerData.recommendations.recentRecommendations.map((rec, index) => (
                    <div key={index} className="p-3 border rounded-lg">
                      <div className="flex justify-between items-start mb-2">
                        <Badge variant="outline">{rec.type}</Badge>
                        <span className="text-sm text-gray-500">
                          {formatDate(rec.date)}
                        </span>
                      </div>
                      <p className="text-sm">{rec.description}</p>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
};

export default FarmerDetails;
