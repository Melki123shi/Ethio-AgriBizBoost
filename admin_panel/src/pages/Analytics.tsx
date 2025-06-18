
import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { BarChart3, TrendingUp, Download, RefreshCw, Users, DollarSign } from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar, PieChart, Pie, Cell, AreaChart, Area } from 'recharts';
import { adminApi, DashboardSummary } from '../services/api';
import { useToast } from '@/hooks/use-toast';

const Analytics: React.FC = () => {
  const [timeFilter, setTimeFilter] = useState('monthly');
  const [dashboardData, setDashboardData] = useState<DashboardSummary | null>(null);
  const [serviceTrends, setServiceTrends] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const { toast } = useToast();

  const fetchAnalyticsData = async () => {
    try {
      setIsLoading(true);
      console.log('Fetching analytics data...');
      
      // Fetch dashboard summary
      const summaryData = await adminApi.getDashboardSummary(timeFilter);
      setDashboardData(summaryData);
      console.log('Dashboard data fetched:', summaryData);

      // Fetch service trends for different services
      const services = ['expense_tracking', 'forecasting', 'health_assessment', 'recommendation'];
      const trendsPromises = services.map(service => 
        adminApi.getServiceTrends(service, timeFilter).catch(error => {
          console.warn(`Failed to fetch trends for ${service}:`, error);
          return null;
        })
      );
      
      const trendsResults = await Promise.all(trendsPromises);
      const validTrends = trendsResults.filter(trend => trend !== null);
      setServiceTrends(validTrends);
      console.log('Service trends fetched:', validTrends);

    } catch (error) {
      console.error('Error fetching analytics data:', error);
      toast({
        title: 'Error',
        description: 'Failed to load analytics data. Please try again.',
        variant: 'destructive',
      });
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchAnalyticsData();
  }, [timeFilter]);

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-ET', {
      style: 'currency',
      currency: 'ETB',
      minimumFractionDigits: 0,
    }).format(amount);
  };

  const calculatePercentageChange = (current: number, previous: number) => {
    if (previous === 0) return 0;
    return ((current - previous) / previous) * 100;
  };

  // Transform regional distribution data for charts
  const regionalPerformanceData = dashboardData?.regional_distribution 
    ? Object.entries(dashboardData.regional_distribution).map(([region, count]) => ({
        region,
        farmers: count,
        // Mock additional data since API doesn't provide revenue/profit per region
        revenue: count * 620, // Estimated revenue per farmer
        avgProfit: Math.floor(Math.random() * 200) + 600, // Mock avg profit
      }))
    : [];

  // Transform daily active users for charts
  const userRetentionData = dashboardData?.daily_active_users?.slice(-4).map((day, index) => ({
    week: `Week ${index + 1}`,
    new: Math.floor(day.count * 0.2), // Estimated new users
    returning: Math.floor(day.count * 0.8), // Estimated returning users
    total: day.count,
  })) || [];

  // Create financial trends from dashboard data
  const financialTrends = dashboardData ? [
    {
      month: 'Current Period',
      revenue: dashboardData.total_system_revenue,
      expenses: dashboardData.total_system_expenses,
      profit: dashboardData.total_system_profit,
    }
  ] : [];

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-600 mx-auto"></div>
          <p className="mt-2 text-muted-foreground">Loading analytics...</p>
        </div>
      </div>
    );
  }

  if (!dashboardData) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <div className="text-center">
          <p className="text-muted-foreground">No analytics data available</p>
          <Button onClick={fetchAnalyticsData} className="mt-4">
            <RefreshCw className="w-4 h-4 mr-2" />
            Retry
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Analytics & Reports</h1>
          <p className="text-muted-foreground">
            Comprehensive insights into platform performance and farmer activities
          </p>
        </div>
        <div className="flex gap-2">
          <Select value={timeFilter} onValueChange={setTimeFilter}>
            <SelectTrigger className="w-32">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="daily">Daily</SelectItem>
              <SelectItem value="weekly">Weekly</SelectItem>
              <SelectItem value="monthly">Monthly</SelectItem>
              <SelectItem value="yearly">Yearly</SelectItem>
            </SelectContent>
          </Select>
          <Button variant="outline" size="sm" onClick={fetchAnalyticsData}>
            <RefreshCw className="w-4 h-4 mr-2" />
            Refresh
          </Button>
          <Button size="sm">
            <Download className="w-4 h-4 mr-2" />
            Export Report
          </Button>
        </div>
      </div>

      {/* Key Metrics */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total API Calls</CardTitle>
            <BarChart3 className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {(dashboardData.auth_usage.total_logins + 
                dashboardData.expense_tracking_usage.total_entries + 
                dashboardData.forecasting_usage.total_predictions + 
                dashboardData.health_assessment_usage.total_assessments + 
                dashboardData.recommendation_usage.total_recommendations).toLocaleString()}
            </div>
            <p className="text-xs text-muted-foreground">
              <span className="text-green-600 flex items-center">
                <TrendingUp className="w-3 h-3 mr-1" />
                All service calls combined
              </span>
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Farmers</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{dashboardData.active_farmers.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground">
              <span className="text-green-600 flex items-center">
                <TrendingUp className="w-3 h-3 mr-1" />
                {((dashboardData.active_farmers / dashboardData.total_farmers) * 100).toFixed(1)}% of total farmers
              </span>
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Platform Revenue</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(dashboardData.total_system_revenue)}</div>
            <p className="text-xs text-muted-foreground">
              <span className="text-green-600 flex items-center">
                <TrendingUp className="w-3 h-3 mr-1" />
                Profit: {formatCurrency(dashboardData.total_system_profit)}
              </span>
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Farmers Needing Attention</CardTitle>
            <BarChart3 className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{dashboardData.farmers_needing_attention}</div>
            <p className="text-xs text-muted-foreground">
              <span className="text-red-600 flex items-center">
                <TrendingUp className="w-3 h-3 mr-1" />
                {((dashboardData.farmers_needing_attention / dashboardData.total_farmers) * 100).toFixed(1)}% of total
              </span>
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Service Usage Analytics */}
      <Card>
        <CardHeader>
          <CardTitle>Service Usage Overview</CardTitle>
          <CardDescription>API usage by service type</CardDescription>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={400}>
            <BarChart data={[
              { service: 'Auth', usage: dashboardData.auth_usage.total_logins },
              { service: 'Expense Tracking', usage: dashboardData.expense_tracking_usage.total_entries },
              { service: 'Forecasting', usage: dashboardData.forecasting_usage.total_predictions },
              { service: 'Health Assessment', usage: dashboardData.health_assessment_usage.total_assessments },
              { service: 'Recommendations', usage: dashboardData.recommendation_usage.total_recommendations },
            ]}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="service" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="usage" fill="#22c55e" />
            </BarChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      {/* Financial Dashboard */}
      <div className="grid gap-6 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Financial Overview</CardTitle>
            <CardDescription>Current period financial metrics</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex justify-between items-center">
                <span className="text-sm text-muted-foreground">Total Revenue</span>
                <span className="font-bold text-green-600">{formatCurrency(dashboardData.total_system_revenue)}</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-sm text-muted-foreground">Total Expenses</span>
                <span className="font-bold text-red-600">{formatCurrency(dashboardData.total_system_expenses)}</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-sm text-muted-foreground">Net Profit</span>
                <span className="font-bold text-blue-600">{formatCurrency(dashboardData.total_system_profit)}</span>
              </div>
              <div className="pt-4 border-t">
                <span className="text-sm text-muted-foreground">Profit Margin</span>
                <span className="font-bold text-lg ml-2">
                  {((dashboardData.total_system_profit / dashboardData.total_system_revenue) * 100).toFixed(1)}%
                </span>
              </div>
            </div>
          </CardContent>
        </Card>

        {userRetentionData.length > 0 && (
          <Card>
            <CardHeader>
              <CardTitle>User Activity Trend</CardTitle>
              <CardDescription>Recent daily active users</CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <LineChart data={dashboardData.daily_active_users.slice(-7)}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" tickFormatter={(value) => new Date(value).toLocaleDateString()} />
                  <YAxis />
                  <Tooltip labelFormatter={(value) => new Date(value).toLocaleDateString()} />
                  <Line type="monotone" dataKey="count" stroke="#22c55e" strokeWidth={2} name="Active Users" />
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        )}
      </div>

      {/* Regional Performance */}
      {regionalPerformanceData.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Regional Distribution</CardTitle>
            <CardDescription>Farmer distribution by region</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b">
                    <th className="text-left p-2">Region</th>
                    <th className="text-right p-2">Farmers</th>
                    <th className="text-right p-2">Percentage</th>
                    <th className="text-center p-2">Status</th>
                  </tr>
                </thead>
                <tbody>
                  {regionalPerformanceData.map((region) => (
                    <tr key={region.region} className="border-b">
                      <td className="p-2 font-medium">{region.region}</td>
                      <td className="text-right p-2">{region.farmers.toLocaleString()}</td>
                      <td className="text-right p-2">
                        {((region.farmers / dashboardData.total_farmers) * 100).toFixed(1)}%
                      </td>
                      <td className="text-center p-2">
                        <Badge 
                          variant={region.farmers > 300 ? 'default' : region.farmers > 200 ? 'secondary' : 'outline'}
                          className={region.farmers > 300 ? 'bg-green-100 text-green-800' : ''}
                        >
                          {region.farmers > 300 ? 'High' : region.farmers > 200 ? 'Medium' : 'Low'}
                        </Badge>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
};

export default Analytics;
