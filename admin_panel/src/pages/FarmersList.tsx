import React, { useState, useEffect, useMemo } from "react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Checkbox } from "@/components/ui/checkbox";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
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
  MapPin,
  FileSpreadsheet,
  Menu,
} from "lucide-react";
import { useNavigate } from "react-router-dom";
import { adminApi, FarmerData, FarmersListResponse } from "../services/api";
import { useToast } from "@/hooks/use-toast";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";

const FarmersList: React.FC = () => {
  const navigate = useNavigate();
  const { toast } = useToast();

  const [farmersData, setFarmersData] = useState<FarmersListResponse | null>(
    null
  );
  const [isLoading, setIsLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const [regionFilter, setRegionFilter] = useState("all");
  const [statusFilter, setStatusFilter] = useState("all");
  const [riskFilter, setRiskFilter] = useState("all");
  const [selectedFarmers, setSelectedFarmers] = useState<string[]>([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize] = useState(20);

  const regions = ["Oromia", "Amhara", "Tigray", "SNNPR", "Addis Ababa"];

  const fetchFarmers = async () => {
    try {
      setIsLoading(true);
      // For initial load, fetch all farmers without filters
      // The filtering will be done client-side
      const filters = {
        page: currentPage,
        page_size: pageSize,
        sort_by: "engagement_score",
        sort_order: "desc",
      };

      const data = await adminApi.getFarmers(filters);
      setFarmersData(data);
    } catch (error) {
      console.error("Error fetching farmers:", error);
      toast({
        title: "Error",
        description: "Failed to load farmers data. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchFarmers();
  }, [currentPage]); // Only refetch when page changes

  // Memoized filtered farmers for better performance
  const filteredFarmers = useMemo(() => {
    if (!farmersData?.farmers) return [];

    return farmersData.farmers.filter((farmer) => {
      // Search filter
      const matchesSearch =
        searchTerm === "" ||
        (farmer.activity.name?.toLowerCase() || "").includes(
          searchTerm.toLowerCase()
        ) ||
        (farmer.activity.phone_number || "").includes(searchTerm) ||
        (farmer.activity.location?.toLowerCase() || "").includes(
          searchTerm.toLowerCase()
        );

      // Region filter
      const matchesRegion =
        regionFilter === "all" ||
        (farmer.activity.location || "")
          .toLowerCase()
          .includes(regionFilter.toLowerCase());

      // Status filter
      const matchesStatus =
        statusFilter === "all" ||
        (statusFilter === "active"
          ? farmer.activity.is_active
          : !farmer.activity.is_active);

      // Risk filter
      const matchesRisk =
        riskFilter === "all" || farmer.risk_level === riskFilter;

      return matchesSearch && matchesRegion && matchesStatus && matchesRisk;
    });
  }, [
    farmersData?.farmers,
    searchTerm,
    regionFilter,
    statusFilter,
    riskFilter,
  ]);

  const getRiskBadgeColor = (risk: string) => {
    switch (risk) {
      case "low":
        return "bg-green-100 text-green-800";
      case "medium":
        return "bg-yellow-100 text-yellow-800";
      case "high":
        return "bg-red-100 text-red-800";
      default:
        return "bg-gray-100 text-gray-800";
    }
  };

  const getEngagementColor = (score: number) => {
    if (score >= 70) return "text-green-600";
    if (score >= 40) return "text-yellow-600";
    return "text-red-600";
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("en-ET", {
      style: "currency",
      currency: "ETB",
      minimumFractionDigits: 0,
    }).format(amount);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString();
  };

  const formatLastActive = (dateString: string) => {
    if (!dateString) return "Never";

    const now = new Date();
    const lastActive = new Date(dateString);
    const diffTime = Math.abs(now.getTime() - lastActive.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    if (diffDays === 1) return "1 day ago";
    if (diffDays < 30) return `${diffDays} days ago`;
    return formatDate(dateString);
  };

  const toggleFarmerSelection = (farmerId: string) => {
    setSelectedFarmers((prev) =>
      prev.includes(farmerId)
        ? prev.filter((id) => id !== farmerId)
        : [...prev, farmerId]
    );
  };

  const selectAllFarmers = () => {
    if (selectedFarmers.length === filteredFarmers.length) {
      setSelectedFarmers([]);
    } else {
      setSelectedFarmers(filteredFarmers.map((f) => f.activity.user_id));
    }
  };

  // Reset filters
  const resetFilters = () => {
    setSearchTerm("");
    setRegionFilter("all");
    setStatusFilter("all");
    setRiskFilter("all");
  };

  // Export to CSV/Excel function
  const exportToExcel = (
    farmers: FarmerData[],
    filename: string = "farmers_export"
  ) => {
    // Prepare the data for CSV
    const csvData = farmers.map((farmer) => ({
      ID: farmer.activity.user_id,
      Name: farmer.activity.name || "Unknown",
      "Phone Number": farmer.activity.phone_number || "N/A",
      Location: farmer.activity.location || "Unknown",
      Status: farmer.activity.is_active ? "Active" : "Inactive",
      "Last Login": farmer.activity.last_login
        ? formatDate(farmer.activity.last_login)
        : "Never",
      "Total Logins": farmer.activity.total_logins || 0,
      "Registration Date": farmer.activity.created_at
        ? formatDate(farmer.activity.created_at)
        : "Unknown",
      "Engagement Score": farmer.engagement_score.toFixed(2),
      "Risk Level": farmer.risk_level,
      "Total Revenue (ETB)": farmer.expenses?.total_revenue || 0,
      "Total Expenses (ETB)": farmer.expenses?.total_expenses || 0,
      "Total Profit (ETB)": farmer.expenses?.total_profit || 0,
      "Total Transactions": farmer.expenses?.expense_count || 0,
      "Total Assessments": farmer.expenses?.assessment_count || 0,
      "Financial Stability": farmer.expenses?.financial_stability_avg || 0,
      "Cash Flow Average": farmer.expenses?.cash_flow_avg || 0,
      "Needs Attention": farmer.needs_attention ? "Yes" : "No",
    }));

    // Convert to CSV format
    const headers = Object.keys(csvData[0]);
    const csvContent = [
      headers.join(","),
      ...csvData.map((row) =>
        headers
          .map((header) => {
            const value = row[header as keyof typeof row];
            // Handle values that might contain commas
            return typeof value === "string" && value.includes(",")
              ? `"${value}"`
              : value;
          })
          .join(",")
      ),
    ].join("\n");

    // Create blob and download
    const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
    const link = document.createElement("a");
    const url = URL.createObjectURL(blob);

    link.setAttribute("href", url);
    link.setAttribute(
      "download",
      `${filename}_${new Date().toISOString().split("T")[0]}.csv`
    );
    link.style.visibility = "hidden";

    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    toast({
      title: "Export Successful",
      description: `Exported ${farmers.length} farmer records to Excel`,
    });
  };

  const handleExportAll = () => {
    if (farmersData?.farmers && farmersData.farmers.length > 0) {
      exportToExcel(farmersData.farmers, "all_farmers");
    } else {
      toast({
        title: "No Data",
        description: "No farmers data available to export",
        variant: "destructive",
      });
    }
  };

  const handleExportSelected = () => {
    const selectedFarmersData = filteredFarmers.filter((farmer) =>
      selectedFarmers.includes(farmer.activity.user_id)
    );

    if (selectedFarmersData.length > 0) {
      exportToExcel(selectedFarmersData, "selected_farmers");
    } else {
      toast({
        title: "No Selection",
        description: "Please select farmers to export",
        variant: "destructive",
      });
    }
  };

  const handleExportFiltered = () => {
    if (filteredFarmers.length > 0) {
      exportToExcel(filteredFarmers, "filtered_farmers");
    } else {
      toast({
        title: "No Data",
        description: "No filtered data available to export",
        variant: "destructive",
      });
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

  // Mobile filter sheet content
  const MobileFilters = () => (
    <div className="space-y-4">
      <div>
        <label className="text-sm font-medium mb-2 block">Region</label>
        <Select value={regionFilter} onValueChange={setRegionFilter}>
          <SelectTrigger className="w-full">
            <SelectValue placeholder="All Regions" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Regions</SelectItem>
            {regions.map((region) => (
              <SelectItem key={region} value={region}>
                {region}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <div>
        <label className="text-sm font-medium mb-2 block">Status</label>
        <Select value={statusFilter} onValueChange={setStatusFilter}>
          <SelectTrigger className="w-full">
            <SelectValue placeholder="All Status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Status</SelectItem>
            <SelectItem value="active">Active</SelectItem>
            <SelectItem value="inactive">Inactive</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <div>
        <label className="text-sm font-medium mb-2 block">Risk Level</label>
        <Select value={riskFilter} onValueChange={setRiskFilter}>
          <SelectTrigger className="w-full">
            <SelectValue placeholder="All Risk Levels" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Risk Levels</SelectItem>
            <SelectItem value="low">Low Risk</SelectItem>
            <SelectItem value="medium">Medium Risk</SelectItem>
            <SelectItem value="high">High Risk</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <Button variant="outline" onClick={resetFilters} className="w-full">
        Reset Filters
      </Button>
    </div>
  );

  // Show active filters
  const hasActiveFilters =
    searchTerm ||
    regionFilter !== "all" ||
    statusFilter !== "all" ||
    riskFilter !== "all";

  return (
    <TooltipProvider>
      <div className="space-y-4 md:space-y-6 p-4 md:p-0">
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
          <div>
            <h1 className="text-2xl md:text-3xl font-bold tracking-tight">
              Farmers Management
            </h1>
            <p className="text-sm md:text-base text-muted-foreground">
              Manage and monitor farmer accounts and activities
            </p>
          </div>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button className="w-full sm:w-auto">
                <FileSpreadsheet className="w-4 h-4 mr-2" />
                Export Data
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-56">
              <DropdownMenuLabel>Export Options</DropdownMenuLabel>
              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={handleExportAll}>
                <Download className="mr-2 h-4 w-4" />
                Export All Farmers
              </DropdownMenuItem>
              <DropdownMenuItem onClick={handleExportFiltered}>
                <Filter className="mr-2 h-4 w-4" />
                Export Filtered Results
              </DropdownMenuItem>
              {selectedFarmers.length > 0 && (
                <DropdownMenuItem onClick={handleExportSelected}>
                  <Checkbox className="mr-2 h-4 w-4" checked={true} />
                  Export Selected ({selectedFarmers.length})
                </DropdownMenuItem>
              )}
            </DropdownMenuContent>
          </DropdownMenu>
        </div>

        {/* Filters and Search */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle className="text-lg">Filters</CardTitle>
              {/* Mobile filter toggle */}
              <Sheet>
                <SheetTrigger asChild>
                  <Button variant="outline" size="sm" className="md:hidden">
                    <Menu className="h-4 w-4 mr-2" />
                    Filters
                  </Button>
                </SheetTrigger>
                <SheetContent side="right" className="w-[300px] sm:w-[400px]">
                  <SheetHeader>
                    <SheetTitle>Filter Options</SheetTitle>
                    <SheetDescription>
                      Apply filters to narrow down the farmers list
                    </SheetDescription>
                  </SheetHeader>
                  <div className="mt-6">
                    <MobileFilters />
                  </div>
                </SheetContent>
              </Sheet>
            </div>
          </CardHeader>
          <CardContent>
            {/* Search bar - always visible */}
            <div className="relative mb-4">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
              <Input
                placeholder="Search farmers..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 w-full"
              />
            </div>

            {/* Desktop filters */}
            <div className="hidden md:grid gap-4 md:grid-cols-4 lg:grid-cols-5">
              <Select value={regionFilter} onValueChange={setRegionFilter}>
                <SelectTrigger>
                  <SelectValue placeholder="All Regions" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Regions</SelectItem>
                  {regions.map((region) => (
                    <SelectItem key={region} value={region}>
                      {region}
                    </SelectItem>
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

              <Button
                variant="outline"
                className="w-full"
                onClick={resetFilters}
              >
                <Filter className="w-4 h-4 mr-2" />
                Reset Filters
              </Button>
            </div>

            {/* Active filters indicator */}
            {hasActiveFilters && (
              <div className="mt-4 flex items-center gap-2 text-sm text-muted-foreground">
                <Filter className="w-4 h-4" />
                <span>Active filters: {filteredFarmers.length} results</span>
              </div>
            )}

            {selectedFarmers.length > 0 && (
              <div className="mt-4 flex flex-col sm:flex-row items-start sm:items-center gap-2 sm:gap-4">
                <span className="text-sm text-gray-600">
                  {selectedFarmers.length} farmer(s) selected
                </span>
                <div className="flex gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={handleExportSelected}
                  >
                    Export Selected
                  </Button>
                  <Button variant="outline" size="sm">
                    Send Notification
                  </Button>
                </div>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Farmers Table */}
        <Card>
          <CardHeader>
            <CardTitle className="text-base md:text-lg">
              Farmers ({farmersData?.total_count || 0})
            </CardTitle>
            <CardDescription className="text-sm">
              Showing {filteredFarmers.length} of{" "}
              {farmersData?.total_count || 0} farmers
            </CardDescription>
          </CardHeader>
          <CardContent className="p-0 md:p-6">
            {filteredFarmers.length === 0 ? (
              <div className="text-center py-12">
                <p className="text-muted-foreground">
                  No farmers found matching your filters.
                </p>
                {hasActiveFilters && (
                  <Button
                    variant="link"
                    onClick={resetFilters}
                    className="mt-2"
                  >
                    Clear filters
                  </Button>
                )}
              </div>
            ) : (
              <>
                {/* Mobile view - Cards */}
                <div className="md:hidden space-y-4 p-4">
                  {filteredFarmers.map((farmer) => (
                    <Card
                      key={farmer.activity.user_id}
                      className={
                        farmer.needs_attention ? "border-red-200 bg-red-50" : ""
                      }
                    >
                      <CardContent className="p-4">
                        <div className="flex items-start justify-between mb-3">
                          <div className="flex items-center gap-2 min-w-0">
                            <Checkbox
                              checked={selectedFarmers.includes(
                                farmer.activity.user_id
                              )}
                              onCheckedChange={() =>
                                toggleFarmerSelection(farmer.activity.user_id)
                              }
                            />
                            <div className="min-w-0">
                              <Tooltip>
                                <TooltipTrigger asChild>
                                  <div className="font-medium truncate">
                                    {farmer.activity.name || "Unknown Farmer"}
                                  </div>
                                </TooltipTrigger>
                                <TooltipContent>
                                  <p>
                                    {farmer.activity.name || "Unknown Farmer"}
                                  </p>
                                </TooltipContent>
                              </Tooltip>
                              <div className="text-xs text-gray-500 truncate">
                                ID: {farmer.activity.user_id}
                              </div>
                            </div>
                          </div>
                          {farmer.needs_attention && (
                            <AlertTriangle className="w-4 h-4 text-red-500 flex-shrink-0" />
                          )}
                        </div>

                        <div className="space-y-2 text-sm">
                          <div className="flex items-center gap-2">
                            <Phone className="w-3 h-3 text-gray-400 flex-shrink-0" />
                            <span className="truncate">
                              {farmer.activity.phone_number || "N/A"}
                            </span>
                          </div>
                          <div className="flex items-center gap-2">
                            <MapPin className="w-3 h-3 text-gray-400 flex-shrink-0" />
                            <Tooltip>
                              <TooltipTrigger asChild>
                                <span className="truncate">
                                  {farmer.activity.location ||
                                    "Unknown Location"}
                                </span>
                              </TooltipTrigger>
                              <TooltipContent>
                                <p>
                                  {farmer.activity.location ||
                                    "Unknown Location"}
                                </p>
                              </TooltipContent>
                            </Tooltip>
                          </div>
                          <div className="flex items-center gap-2 justify-between">
                            <span className="text-gray-600">Engagement:</span>
                            <span
                              className={`font-medium ${getEngagementColor(
                                farmer.engagement_score
                              )}`}
                            >
                              {farmer.engagement_score.toFixed(1)}%
                            </span>
                          </div>
                          <div className="flex items-center gap-2 justify-between">
                            <span className="text-gray-600">Status:</span>
                            <Badge
                              variant={
                                farmer.activity.is_active
                                  ? "default"
                                  : "secondary"
                              }
                              className="text-xs"
                            >
                              {farmer.activity.is_active
                                ? "active"
                                : "inactive"}
                            </Badge>
                          </div>
                          <div className="flex items-center gap-2 justify-between">
                            <span className="text-gray-600">Risk:</span>
                            <Badge
                              className={`${getRiskBadgeColor(
                                farmer.risk_level
                              )} text-xs`}
                            >
                              {farmer.risk_level}
                            </Badge>
                          </div>
                        </div>

                        <div className="mt-3 pt-3 border-t">
                          <Button
                            variant="outline"
                            size="sm"
                            className="w-full"
                            onClick={() =>
                              navigate(`/farmers/${farmer.activity.user_id}`)
                            }
                          >
                            <Eye className="mr-2 h-4 w-4" />
                            View Details
                          </Button>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>

                {/* Desktop view - Table */}
                <div className="hidden md:block rounded-md border">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead className="w-12">
                          <Checkbox
                            checked={
                              selectedFarmers.length ===
                                filteredFarmers.length &&
                              filteredFarmers.length > 0
                            }
                            onCheckedChange={selectAllFarmers}
                          />
                        </TableHead>
                        <TableHead className="w-[200px]">Farmer</TableHead>
                        <TableHead className="w-[150px]">Contact</TableHead>
                        <TableHead className="w-[150px]">Location</TableHead>
                        <TableHead className="w-[120px]">Last Active</TableHead>
                        <TableHead className="w-[120px]">Engagement</TableHead>
                        <TableHead className="w-[100px]">Risk Level</TableHead>
                        <TableHead className="w-[120px]">Profit</TableHead>
                        <TableHead className="w-[100px]">Status</TableHead>
                        <TableHead className="w-12"></TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {filteredFarmers.map((farmer) => (
                        <TableRow
                          key={farmer.activity.user_id}
                          className={
                            farmer.needs_attention
                              ? "bg-red-50 border-red-200"
                              : ""
                          }
                        >
                          <TableCell>
                            <Checkbox
                              checked={selectedFarmers.includes(
                                farmer.activity.user_id
                              )}
                              onCheckedChange={() =>
                                toggleFarmerSelection(farmer.activity.user_id)
                              }
                            />
                          </TableCell>
                          <TableCell>
                            <div className="flex items-center gap-2 min-w-0">
                              <div className="min-w-0">
                                <Tooltip>
                                  <TooltipTrigger asChild>
                                    <div className="font-medium truncate max-w-[150px]">
                                      {farmer.activity.name || "Unknown Farmer"}
                                    </div>
                                  </TooltipTrigger>
                                  <TooltipContent>
                                    <p>
                                      {farmer.activity.name || "Unknown Farmer"}
                                    </p>
                                  </TooltipContent>
                                </Tooltip>
                                <div className="text-sm text-gray-500 truncate max-w-[150px]">
                                  ID: {farmer.activity.user_id}
                                </div>
                              </div>
                              {farmer.needs_attention && (
                                <AlertTriangle className="w-4 h-4 text-red-500 flex-shrink-0" />
                              )}
                            </div>
                          </TableCell>
                          <TableCell>
                            <div className="flex items-center gap-2">
                              <Phone className="w-4 h-4 text-gray-400 flex-shrink-0" />
                              <span className="text-sm truncate max-w-[100px]">
                                {farmer.activity.phone_number || "N/A"}
                              </span>
                            </div>
                          </TableCell>
                          <TableCell>
                            <div className="flex items-center gap-2">
                              <MapPin className="w-4 h-4 text-gray-400 flex-shrink-0" />
                              <Tooltip>
                                <TooltipTrigger asChild>
                                  <span className="text-sm truncate max-w-[100px] block">
                                    {farmer.activity.location ||
                                      "Unknown Location"}
                                  </span>
                                </TooltipTrigger>
                                <TooltipContent>
                                  <p>
                                    {farmer.activity.location ||
                                      "Unknown Location"}
                                  </p>
                                </TooltipContent>
                              </Tooltip>
                            </div>
                          </TableCell>
                          <TableCell>
                            <span className="text-sm">
                              {formatLastActive(farmer.activity.last_login)}
                            </span>
                          </TableCell>
                          <TableCell>
                            <div className="flex items-center gap-2">
                              <span
                                className={`font-medium ${getEngagementColor(
                                  farmer.engagement_score
                                )}`}
                              >
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
                            <Badge
                              className={getRiskBadgeColor(farmer.risk_level)}
                            >
                              {farmer.risk_level}
                            </Badge>
                          </TableCell>
                          <TableCell>
                            <Tooltip>
                              <TooltipTrigger asChild>
                                <span
                                  className={`truncate block max-w-[100px] ${
                                    farmer.expenses?.total_profit &&
                                    farmer.expenses.total_profit >= 0
                                      ? "text-green-600 font-medium"
                                      : "text-red-600 font-medium"
                                  }`}
                                >
                                  {farmer.expenses?.total_profit
                                    ? formatCurrency(
                                        farmer.expenses.total_profit
                                      )
                                    : "N/A"}
                                </span>
                              </TooltipTrigger>
                              <TooltipContent>
                                <p>
                                  {farmer.expenses?.total_profit
                                    ? formatCurrency(
                                        farmer.expenses.total_profit
                                      )
                                    : "No data available"}
                                </p>
                              </TooltipContent>
                            </Tooltip>
                          </TableCell>
                          <TableCell>
                            <Badge
                              variant={
                                farmer.activity.is_active
                                  ? "default"
                                  : "secondary"
                              }
                            >
                              {farmer.activity.is_active
                                ? "active"
                                : "inactive"}
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
                                  onClick={() =>
                                    navigate(
                                      `/farmers/${farmer.activity.user_id}`
                                    )
                                  }
                                >
                                  <Eye className="mr-2 h-4 w-4" />
                                  View Details
                                </DropdownMenuItem>
                                <DropdownMenuItem
                                  onClick={() =>
                                    exportToExcel(
                                      [farmer],
                                      `farmer_${farmer.activity.user_id}`
                                    )
                                  }
                                >
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
              </>
            )}

            {/* Pagination */}
            {farmersData && farmersData.total_pages > 1 && (
              <div className="flex flex-col sm:flex-row justify-between items-center gap-4 mt-4 px-4 md:px-0">
                <div className="text-sm text-gray-500">
                  Page {farmersData.page} of {farmersData.total_pages}
                </div>
                <div className="flex gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={farmersData.page <= 1}
                    onClick={() => setCurrentPage((prev) => prev - 1)}
                  >
                    Previous
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={farmersData.page >= farmersData.total_pages}
                    onClick={() => setCurrentPage((prev) => prev + 1)}
                  >
                    Next
                  </Button>
                </div>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </TooltipProvider>
  );
};

export default FarmersList;
