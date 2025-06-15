
import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Checkbox } from '@/components/ui/checkbox';
import {
  Search,
  Filter,
  Download,
  Eye,
  MoreHorizontal,
  AlertTriangle,
  TrendingUp,
  TrendingDown,
  Phone,
  MapPin
} from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { adminApi, FarmerData, FarmersListResponse } from '../services/api';
import { useToast } from '@/hooks/use-toast';

const FarmersList: React.FC = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  
  const [farmersData, setFarmersData] = useState<FarmersListResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [regionFilter, setRegionFilter] = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');
  const [riskFilter, setRiskFilter] = useState('all');
  const [selectedFarmers, setSelectedFarmers] = useState<string[]>([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize] = useState(20);

  const regions = ['Oromia', 'Amhara', 'Tigray', 'SNNPR', 'Addis Ababa'];

  const fetchFarmers = async () => {
    try {
      setIsLoading(true);
      const filters = {
        page: currentPage,
        page_size: pageSize,
        ...(regionFilter !== 'all' && { region: regionFilter }),
        ...(statusFilter !== 'all' && { is_active: statusFilter === 'active' }),
        sort_by: 'engagement_score',
        sort_order: 'desc'
      };
      
      const data = await adminApi.getFarmers(filters);
      setFarmersData(data);
    } catch (error) {
      console.error('Error fetching farmers:', error);
      toast({
        title: 'Error',
        description: 'Failed to load farmers data. Please try again.',
        variant: 'destructive',
      });
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchFarmers();
  }, [currentPage, regionFilter, statusFilter, riskFilter]);

  const filteredFarmers = farmersData?.farmers?.filter((farmer) => {
    const matchesSearch = farmer.activity.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      farmer.activity.phone_number.includes(searchTerm) ||
      farmer.activity.location.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesRisk = riskFilter === 'all' || farmer.risk_level === riskFilter;

    return matchesSearch && matchesRisk;
  }) || [];

  const getRiskBadgeColor = (risk: string) => {
    switch (risk) {
      case 'low': return 'bg-green-100 text-green-800';
      case 'medium': return 'bg-yellow-100 text-yellow-800';
      case 'high': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getEngagementColor = (score: number) => {
    if (score >= 70) return 'text-green-600';
    if (score >= 40) return 'text-yellow-600';
    return 'text-red-600';
  };

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

  const formatLastActive = (dateString: string) => {
    const now = new Date();
    const lastActive = new Date(dateString);
    const diffTime = Math.abs(now.getTime() - lastActive.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays === 1) return '1 day ago';
    if (diffDays < 30) return `${diffDays} days ago`;
    return formatDate(dateString);
  };

  const toggleFarmerSelection = (farmerId: string) => {
    setSelectedFarmers(prev => 
      prev.includes(farmerId) 
        ? prev.filter(id => id !== farmerId)
        : [...prev, farmerId]
    );
  };

  const selectAllFarmers = () => {
    if (selectedFarmers.length === filteredFarmers.length) {
      setSelectedFarmers([]);
    } else {
      setSelectedFarmers(filteredFarmers.map(f => f.activity.user_id));
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-600 mx-auto"></div>
          <p className="mt-2 text-muted-foreground">Loading farmers...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Farmers Management</h1>
          <p className="text-muted-foreground">
            Manage and monitor farmer accounts and activities
          </p>
        </div>
        <Button>
          <Download className="w-4 h-4 mr-2" />
          Export Data
        </Button>
      </div>

      {/* Filters and Search */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Filters</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 md:grid-cols-5">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
              <Input
                placeholder="Search farmers..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>

            <Select value={regionFilter} onValueChange={setRegionFilter}>
              <SelectTrigger>
                <SelectValue placeholder="All Regions" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Regions</SelectItem>
                {regions.map(region => (
                  <SelectItem key={region} value={region}>{region}</SelectItem>
                ))}
              </SelectContent>
            </Select>

            <Select value={statusFilter} onValueChange={setStatusFilter}>
              <SelectTrigger>
                <SelectValue placeholder="All Status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Status</SelectItem>
                <SelectItem value="active">Active</SelectItem>
                <SelectItem value="inactive">Inactive</SelectItem>
              </SelectContent>
            </Select>

            <Select value={riskFilter} onValueChange={setRiskFilter}>
              <SelectTrigger>
                <SelectValue placeholder="All Risk Levels" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Risk Levels</SelectItem>
                <SelectItem value="low">Low Risk</SelectItem>
                <SelectItem value="medium">Medium Risk</SelectItem>
                <SelectItem value="high">High Risk</SelectItem>
              </SelectContent>
            </Select>

            <Button variant="outline" className="w-full">
              <Filter className="w-4 h-4 mr-2" />
              Advanced
            </Button>
          </div>

          {selectedFarmers.length > 0 && (
            <div className="mt-4 flex items-center gap-4">
              <span className="text-sm text-gray-600">
                {selectedFarmers.length} farmer(s) selected
              </span>
              <Button variant="outline" size="sm">
                Export Selected
              </Button>
              <Button variant="outline" size="sm">
                Send Notification
              </Button>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Farmers Table */}
      <Card>
        <CardHeader>
          <CardTitle>Farmers ({farmersData?.total_count || 0})</CardTitle>
          <CardDescription>
            Showing {filteredFarmers.length} of {farmersData?.total_count || 0} farmers
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="w-12">
                    <Checkbox
                      checked={selectedFarmers.length === filteredFarmers.length && filteredFarmers.length > 0}
                      onCheckedChange={selectAllFarmers}
                    />
                  </TableHead>
                  <TableHead>Farmer</TableHead>
                  <TableHead>Contact</TableHead>
                  <TableHead>Location</TableHead>
                  <TableHead>Last Active</TableHead>
                  <TableHead>Engagement</TableHead>
                  <TableHead>Risk Level</TableHead>
                  <TableHead>Profit</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="w-12"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredFarmers.map((farmer) => (
                  <TableRow 
                    key={farmer.activity.user_id}
                    className={farmer.needs_attention ? 'bg-red-50 border-red-200' : ''}
                  >
                    <TableCell>
                      <Checkbox
                        checked={selectedFarmers.includes(farmer.activity.user_id)}
                        onCheckedChange={() => toggleFarmerSelection(farmer.activity.user_id)}
                      />
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <div>
                          <div className="font-medium">{farmer.activity.name}</div>
                          <div className="text-sm text-gray-500">
                            ID: {farmer.activity.user_id}
                          </div>
                        </div>
                        {farmer.needs_attention && (
                          <AlertTriangle className="w-4 h-4 text-red-500" />
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <Phone className="w-4 h-4 text-gray-400" />
                        <span className="text-sm">{farmer.activity.phone_number}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <MapPin className="w-4 h-4 text-gray-400" />
                        <span className="text-sm">{farmer.activity.location}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <span className="text-sm">{formatLastActive(farmer.activity.last_login)}</span>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <span className={`font-medium ${getEngagementColor(farmer.engagement_score)}`}>
                          {farmer.engagement_score.toFixed(1)}
                        </span>
                        {farmer.engagement_score >= 70 ? (
                          <TrendingUp className="w-4 h-4 text-green-500" />
                        ) : (
                          <TrendingDown className="w-4 h-4 text-red-500" />
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge className={getRiskBadgeColor(farmer.risk_level)}>
                        {farmer.risk_level}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <span 
                        className={farmer.expenses?.total_profit && farmer.expenses.total_profit >= 0 ? 'text-green-600 font-medium' : 'text-red-600 font-medium'}
                      >
                        {farmer.expenses?.total_profit ? formatCurrency(farmer.expenses.total_profit) : 'N/A'}
                      </span>
                    </TableCell>
                    <TableCell>
                      <Badge variant={farmer.activity.is_active ? 'default' : 'secondary'}>
                        {farmer.activity.is_active ? 'active' : 'inactive'}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" className="h-8 w-8 p-0">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuLabel>Actions</DropdownMenuLabel>
                          <DropdownMenuItem
                            onClick={() => navigate(`/farmers/${farmer.activity.user_id}`)}
                          >
                            <Eye className="mr-2 h-4 w-4" />
                            View Details
                          </DropdownMenuItem>
                          <DropdownMenuItem>
                            <Download className="mr-2 h-4 w-4" />
                            Export Data
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem>
                            Send Notification
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
          
          {/* Pagination */}
          {farmersData && farmersData.total_pages > 1 && (
            <div className="flex justify-between items-center mt-4">
              <div className="text-sm text-gray-500">
                Page {farmersData.page} of {farmersData.total_pages}
              </div>
              <div className="flex gap-2">
                <Button 
                  variant="outline" 
                  size="sm"
                  disabled={farmersData.page <= 1}
                  onClick={() => setCurrentPage(prev => prev - 1)}
                >
                  Previous
                </Button>
                <Button 
                  variant="outline" 
                  size="sm"
                  disabled={farmersData.page >= farmersData.total_pages}
                  onClick={() => setCurrentPage(prev => prev + 1)}
                >
                  Next
                </Button>
              </div>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
};

export default FarmersList;
