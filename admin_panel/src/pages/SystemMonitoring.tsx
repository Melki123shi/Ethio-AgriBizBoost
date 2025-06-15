
import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import {
  Server,
  Database,
  HardDrive,
  Activity,
  AlertTriangle,
  CheckCircle,
  XCircle,
  Clock,
  TrendingUp,
  TrendingDown,
  RefreshCw,
  Settings
} from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, AreaChart, Area } from 'recharts';
import { adminApi, ActivityLogsResponse } from '../services/api';
import { useToast } from '@/hooks/use-toast';

interface SystemMetric {
  name: string;
  value: string;
  status: 'healthy' | 'warning' | 'critical';
  icon: React.ComponentType<any>;
}

const SystemMonitoring: React.FC = () => {
  const [activityLogs, setActivityLogs] = useState<ActivityLogsResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const { toast } = useToast();

  const fetchSystemData = async () => {
    try {
      setIsLoading(true);
      const logsData = await adminApi.getActivityLogs({
        page: 1,
        page_size: 50,
      });
      setActivityLogs(logsData);
    } catch (error) {
      console.error('Error fetching system data:', error);
      toast({
        title: 'Error',
        description: 'Failed to load system monitoring data. Please try again.',
        variant: 'destructive',
      });
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchSystemData();
  }, []);

  // System metrics would come from your monitoring API
  const systemMetrics: SystemMetric[] = [
    {
      name: 'API Response Time',
      value: 'Loading...',
      status: 'healthy',
      icon: Activity,
    },
    {
      name: 'Database Status',
      value: 'Loading...',
      status: 'healthy',
      icon: Database,
    },
    {
      name: 'Memory Usage',
      value: 'Loading...',
      status: 'healthy',
      icon: HardDrive,
    },
    {
      name: 'Active Connections',
      value: 'Loading...',
      status: 'healthy',
      icon: Server,
    },
  ];

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-600 mx-auto"></div>
          <p className="mt-2 text-muted-foreground">Loading system monitoring...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">System Monitoring</h1>
          <p className="text-muted-foreground">
            Monitor system health and performance metrics
          </p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" size="sm" onClick={fetchSystemData}>
            <RefreshCw className="w-4 h-4 mr-2" />
            Refresh
          </Button>
          <Button size="sm">
            <Settings className="w-4 h-4 mr-2" />
            Configure
          </Button>
        </div>
      </div>

      {/* System Health Overview */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {systemMetrics.map((metric) => {
          const Icon = metric.icon;
          return (
            <Card key={metric.name}>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">{metric.name}</CardTitle>
                <Icon className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{metric.value}</div>
                <div className="flex items-center space-x-1 mt-1">
                  {metric.status === 'healthy' && (
                    <CheckCircle className="w-3 h-3 text-green-500" />
                  )}
                  {metric.status === 'warning' && (
                    <AlertTriangle className="w-3 h-3 text-yellow-500" />
                  )}
                  {metric.status === 'critical' && (
                    <XCircle className="w-3 h-3 text-red-500" />
                  )}
                  <span className={`text-xs ${
                    metric.status === 'healthy' ? 'text-green-600' :
                    metric.status === 'warning' ? 'text-yellow-600' : 'text-red-600'
                  }`}>
                    {metric.status}
                  </span>
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>

      {/* Activity Logs */}
      <Card>
        <CardHeader>
          <CardTitle>Recent Activity Logs</CardTitle>
          <CardDescription>
            Latest system activities and user actions
          </CardDescription>
        </CardHeader>
        <CardContent>
          {!activityLogs || activityLogs.logs.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12">
              <Activity className="h-8 w-8 text-muted-foreground mb-2" />
              <p className="text-muted-foreground">No activity logs available</p>
              <p className="text-sm text-muted-foreground">Activity logs will appear here when users interact with the system</p>
            </div>
          ) : (
            <div className="space-y-4">
              {activityLogs.logs.slice(0, 10).map((log) => (
                <div key={log.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                  <div className="flex items-center space-x-3">
                    <div className="flex-shrink-0">
                      <Activity className="w-4 h-4 text-blue-500" />
                    </div>
                    <div>
                      <p className="text-sm font-medium">
                        {log.action} in {log.service}
                      </p>
                      <p className="text-xs text-gray-500">
                        User ID: {log.user_id} • IP: {log.details.ip_address}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center space-x-2">
                    <Badge variant={log.status === 'success' ? 'default' : 'destructive'}>
                      {log.status}
                    </Badge>
                    <span className="text-xs text-gray-500">
                      {new Date(log.timestamp).toLocaleString()}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
};

export default SystemMonitoring;
