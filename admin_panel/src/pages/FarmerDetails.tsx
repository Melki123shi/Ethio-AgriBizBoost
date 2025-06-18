import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
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
  AlertTriangle,
  ArrowLeft,
  RefreshCw,
} from "lucide-react";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
} from "recharts";
import { adminApi, FarmerData } from "../services/api";
import { useToast } from "@/hooks/use-toast";
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
import { FileSpreadsheet, FileText, FileJson } from "lucide-react";

const FarmerDetails: React.FC = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { toast } = useToast();

  const [farmerData, setFarmerData] = useState<FarmerData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [timeFilter, setTimeFilter] = useState("all");

  const fetchFarmerDetails = async () => {
    if (!id) return;

    try {
      setIsLoading(true);
      const data = await adminApi.getFarmerDetails(id, timeFilter);
      setFarmerData(data);
    } catch (error) {
      console.error("Error fetching farmer details:", error);
      toast({
        title: "Error",
        description: "Failed to load farmer details. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchFarmerDetails();
  }, [id, timeFilter]);

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

  const formatDateTime = (dateString: string) => {
    return new Date(dateString).toLocaleString();
  };

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

  const pieColors = ["#22c55e", "#3b82f6", "#f59e0b", "#ef4444", "#8b5cf6"];

  // Export farmer data to different formats
  const prepareExportData = () => {
    if (!farmerData) return null;

    return {
      // Basic Information
      "Farmer ID": farmerData.activity.user_id,
      Name: farmerData.activity.name || "Unknown",
      "Phone Number": farmerData.activity.phone_number || "N/A",
      Location: farmerData.activity.location || "Unknown",
      Status: farmerData.activity.is_active ? "Active" : "Inactive",
      "Registration Date": formatDate(farmerData.activity.created_at),
      "Last Login": farmerData.activity.last_login
        ? formatDateTime(farmerData.activity.last_login)
        : "Never",
      "Total Logins": farmerData.activity.total_logins || 0,

      // Performance Metrics
      "Engagement Score": farmerData.engagement_score.toFixed(2) + "%",
      "Risk Level": farmerData.risk_level,
      "Needs Attention": farmerData.needs_attention ? "Yes" : "No",

      // Financial Summary
      "Total Revenue (ETB)": farmerData.expenses?.total_revenue || 0,
      "Total Expenses (ETB)": farmerData.expenses?.total_expenses || 0,
      "Total Profit (ETB)": farmerData.expenses?.total_profit || 0,
      "Total Transactions": farmerData.expenses?.expense_count || 0,
      "Financial Stability":
        (farmerData.expenses?.financial_stability_avg || 0).toFixed(2) + "%",
      "Cash Flow Average (ETB)": farmerData.expenses?.cash_flow_avg || 0,
      "Last Activity": farmerData.expenses?.last_activity
        ? formatDate(farmerData.expenses.last_activity)
        : "No recent activity",

      // Health Assessment Data
      "Total Assessments": farmerData.health?.total_assessments || 0,
      "Average Profit Margin":
        (farmerData.health?.average_profit_margin || 0).toFixed(2) + "%",
      "Total Subsidies (ETB)": farmerData.health?.total_subsidies || 0,
      "Crops Assessed":
        farmerData.health?.crop_types_assessed?.join(", ") || "None",
      "Last Assessment": farmerData.health?.last_assessment
        ? formatDate(farmerData.health.last_assessment)
        : "No assessments",

      // Forecasting Data
      "Total Predictions": farmerData.forecasting?.total_predictions || 0,
      "Regions Queried":
        farmerData.forecasting?.regions_queried?.join(", ") || "None",
      "Crops Queried":
        farmerData.forecasting?.crops_queried?.join(", ") || "None",
      "Last Prediction": farmerData.forecasting?.last_prediction
        ? formatDate(farmerData.forecasting.last_prediction)
        : "No predictions",

      // Recommendation Data
      "Loan Advice Count": farmerData.recommendations?.loan_advice_count || 0,
      "Cost Cutting Count": farmerData.recommendations?.cost_cutting_count || 0,
      "Total Recommendations":
        (farmerData.recommendations?.loan_advice_count || 0) +
        (farmerData.recommendations?.cost_cutting_count || 0),
      "Recommendation Topics":
        farmerData.recommendations?.recommendation_topics?.join(", ") || "None",
      "Last Recommendation": farmerData.recommendations?.last_recommendation
        ? formatDate(farmerData.recommendations.last_recommendation)
        : "No recommendations",

      // Time Filter Applied
      "Data Time Period":
        timeFilter === "all"
          ? "All Time"
          : timeFilter === "yearly"
          ? "This Year"
          : timeFilter === "monthly"
          ? "This Month"
          : "This Week",
      "Export Date": new Date().toLocaleString(),
    };
  };

  // Export to CSV/Excel
  const exportToCSV = () => {
    if (!farmerData) {
      toast({
        title: "Error",
        description: "No farmer data available to export",
        variant: "destructive",
      });
      return;
    }

    try {
      // Prepare comprehensive farmer data for export
      const exportData = {
        // Basic Information
        "Farmer ID": farmerData.activity.user_id,
        Name: farmerData.activity.name || "Unknown",
        "Phone Number": farmerData.activity.phone_number || "N/A",
        Location: farmerData.activity.location || "Unknown",
        Status: farmerData.activity.is_active ? "Active" : "Inactive",
        "Registration Date": formatDate(farmerData.activity.created_at),
        "Last Login": farmerData.activity.last_login
          ? formatDateTime(farmerData.activity.last_login)
          : "Never",
        "Total Logins": farmerData.activity.total_logins || 0,

        // Performance Metrics
        "Engagement Score": farmerData.engagement_score.toFixed(2) + "%",
        "Risk Level": farmerData.risk_level,
        "Needs Attention": farmerData.needs_attention ? "Yes" : "No",

        // Financial Summary
        "Total Revenue (ETB)": farmerData.expenses?.total_revenue || 0,
        "Total Expenses (ETB)": farmerData.expenses?.total_expenses || 0,
        "Total Profit (ETB)": farmerData.expenses?.total_profit || 0,
        "Total Transactions": farmerData.expenses?.expense_count || 0,
        "Financial Stability":
          (farmerData.expenses?.financial_stability_avg || 0).toFixed(2) + "%",
        "Cash Flow Average (ETB)": farmerData.expenses?.cash_flow_avg || 0,
        "Last Activity": farmerData.expenses?.last_activity
          ? formatDate(farmerData.expenses.last_activity)
          : "No recent activity",

        // Health Assessment Data
        "Total Assessments": farmerData.health?.total_assessments || 0,
        "Average Profit Margin":
          (farmerData.health?.average_profit_margin || 0).toFixed(2) + "%",
        "Total Subsidies (ETB)": farmerData.health?.total_subsidies || 0,
        "Crops Assessed":
          farmerData.health?.crop_types_assessed?.join(", ") || "None",
        "Last Assessment": farmerData.health?.last_assessment
          ? formatDate(farmerData.health.last_assessment)
          : "No assessments",

        // Forecasting Data
        "Total Predictions": farmerData.forecasting?.total_predictions || 0,
        "Regions Queried":
          farmerData.forecasting?.regions_queried?.join(", ") || "None",
        "Crops Queried":
          farmerData.forecasting?.crops_queried?.join(", ") || "None",
        "Last Prediction": farmerData.forecasting?.last_prediction
          ? formatDate(farmerData.forecasting.last_prediction)
          : "No predictions",

        // Recommendation Data
        "Loan Advice Count": farmerData.recommendations?.loan_advice_count || 0,
        "Cost Cutting Count":
          farmerData.recommendations?.cost_cutting_count || 0,
        "Total Recommendations":
          (farmerData.recommendations?.loan_advice_count || 0) +
          (farmerData.recommendations?.cost_cutting_count || 0),
        "Recommendation Topics":
          farmerData.recommendations?.recommendation_topics?.join(", ") ||
          "None",
        "Last Recommendation": farmerData.recommendations?.last_recommendation
          ? formatDate(farmerData.recommendations.last_recommendation)
          : "No recommendations",

        // Time Filter Applied
        "Data Time Period":
          timeFilter === "all"
            ? "All Time"
            : timeFilter === "yearly"
            ? "This Year"
            : timeFilter === "monthly"
            ? "This Month"
            : "This Week",
        "Export Date": new Date().toLocaleString(),
      };

      // Most Traded Goods
      if (
        farmerData.expenses?.most_traded_goods &&
        farmerData.expenses.most_traded_goods.length > 0
      ) {
        farmerData.expenses.most_traded_goods.forEach((good, index) => {
          exportData[
            `Most Traded Good ${index + 1}`
          ] = `${good.name} (${good.count} times)`;
        });
      }

      // Most Frequent Queries
      if (
        farmerData.forecasting?.most_frequent_queries &&
        farmerData.forecasting.most_frequent_queries.length > 0
      ) {
        farmerData.forecasting.most_frequent_queries.forEach((query, index) => {
          exportData[
            `Frequent Query ${index + 1}`
          ] = `${query.query} (${query.count} times)`;
        });
      }

      // Convert to CSV format
      const headers = Object.keys(exportData);
      const values = Object.values(exportData);

      // Create CSV content
      const csvContent = [
        headers.join(","),
        values
          .map((value) => {
            // Handle values that might contain commas
            const stringValue = String(value);
            return stringValue.includes(",") ? `"${stringValue}"` : stringValue;
          })
          .join(","),
      ].join("\n");

      // Create additional sheets data (for comprehensive export)
      let fullCsvContent = "FARMER DETAILED REPORT\n\n" + csvContent;

      // Add transaction history if available (mock for now)
      fullCsvContent += "\n\nTRANSACTION HISTORY\n";
      fullCsvContent += "Date,Type,Amount,Description\n";
      fullCsvContent +=
        "Note: Detailed transaction history would be included here\n";

      // Add assessment history if available
      fullCsvContent += "\n\nASSESSMENT HISTORY\n";
      fullCsvContent += "Date,Crop Type,Profit Margin,Subsidies\n";
      fullCsvContent +=
        "Note: Detailed assessment history would be included here\n";

      // Create blob and download
      const blob = new Blob([fullCsvContent], {
        type: "text/csv;charset=utf-8;",
      });
      const link = document.createElement("a");
      const url = URL.createObjectURL(blob);

      const fileName = `farmer_${
        farmerData.activity.name?.replace(/\s+/g, "_") ||
        farmerData.activity.user_id
      }_${new Date().toISOString().split("T")[0]}.csv`;

      link.setAttribute("href", url);
      link.setAttribute("download", fileName);
      link.style.visibility = "hidden";

      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      toast({
        title: "Export Successful",
        description: `Farmer data exported to ${fileName}`,
      });
    } catch (error) {
      console.error("Error exporting farmer data:", error);
      toast({
        title: "Export Failed",
        description: "Failed to export farmer data. Please try again.",
        variant: "destructive",
      });
    }
  };

  // Export to JSON format
  const exportToJSON = () => {
    const exportData = prepareExportData();
    if (!exportData || !farmerData) {
      toast({
        title: "Error",
        description: "No farmer data available to export",
        variant: "destructive",
      });
      return;
    }

    try {
      // Prepare comprehensive JSON data including raw data
      const jsonData = {
        exportInfo: {
          exportDate: new Date().toISOString(),
          timeFilter: timeFilter,
          farmerName: farmerData.activity.name || "Unknown",
          farmerId: farmerData.activity.user_id,
        },
        summary: exportData,
        rawData: {
          activity: farmerData.activity,
          expenses: farmerData.expenses,
          forecasting: farmerData.forecasting,
          health: farmerData.health,
          recommendations: farmerData.recommendations,
          metrics: {
            engagementScore: farmerData.engagement_score,
            riskLevel: farmerData.risk_level,
            needsAttention: farmerData.needs_attention,
          },
        },
      };

      const jsonString = JSON.stringify(jsonData, null, 2);
      const blob = new Blob([jsonString], { type: "application/json" });
      const link = document.createElement("a");
      const url = URL.createObjectURL(blob);

      const fileName = `farmer_${
        farmerData.activity.name?.replace(/\s+/g, "_") ||
        farmerData.activity.user_id
      }_${new Date().toISOString().split("T")[0]}.json`;

      link.setAttribute("href", url);
      link.setAttribute("download", fileName);
      link.style.visibility = "hidden";

      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      toast({
        title: "Export Successful",
        description: `Farmer data exported to ${fileName}`,
      });
    } catch (error) {
      console.error("Error exporting farmer data as JSON:", error);
      toast({
        title: "Export Failed",
        description: "Failed to export farmer data. Please try again.",
        variant: "destructive",
      });
    }
  };

  // Export detailed report with analytics
  const exportDetailedReport = () => {
    if (!farmerData) {
      toast({
        title: "Error",
        description: "No farmer data available to export",
        variant: "destructive",
      });
      return;
    }

    try {
      // Create a detailed report in CSV format with multiple sections
      let report = "ETHIO-AGRIBIZBOOST FARMER DETAILED REPORT\n";
      report += "=".repeat(60) + "\n\n";

      // Header Information
      report += "Report Generated: " + new Date().toLocaleString() + "\n";
      report +=
        "Time Period: " +
        (timeFilter === "all"
          ? "All Time"
          : timeFilter === "yearly"
          ? "This Year"
          : timeFilter === "monthly"
          ? "This Month"
          : "This Week") +
        "\n\n";

      // Basic Information Section
      report += "FARMER INFORMATION\n";
      report += "-".repeat(40) + "\n";
      report += `Farmer ID: ${farmerData.activity.user_id}\n`;
      report += `Name: ${farmerData.activity.name || "Unknown"}\n`;
      report += `Phone: ${farmerData.activity.phone_number || "N/A"}\n`;
      report += `Location: ${farmerData.activity.location || "Unknown"}\n`;
      report += `Status: ${
        farmerData.activity.is_active ? "Active" : "Inactive"
      }\n`;
      report += `Registration Date: ${formatDate(
        farmerData.activity.created_at
      )}\n`;
      report += `Last Login: ${
        farmerData.activity.last_login
          ? formatDateTime(farmerData.activity.last_login)
          : "Never"
      }\n`;
      report += `Total Logins: ${farmerData.activity.total_logins}\n\n`;

      // Performance Metrics
      report += "PERFORMANCE METRICS\n";
      report += "-".repeat(40) + "\n";
      report += `Engagement Score: ${farmerData.engagement_score.toFixed(
        2
      )}%\n`;
      report += `Risk Level: ${farmerData.risk_level}\n`;
      report += `Needs Attention: ${
        farmerData.needs_attention ? "Yes" : "No"
      }\n\n`;

      // Financial Summary
      report += "FINANCIAL SUMMARY\n";
      report += "-".repeat(40) + "\n";
      report += `Total Revenue: ${formatCurrency(
        farmerData.expenses?.total_revenue || 0
      )}\n`;
      report += `Total Expenses: ${formatCurrency(
        farmerData.expenses?.total_expenses || 0
      )}\n`;
      report += `Total Profit: ${formatCurrency(
        farmerData.expenses?.total_profit || 0
      )}\n`;
      report += `Total Transactions: ${
        farmerData.expenses?.expense_count || 0
      }\n`;
      report += `Financial Stability: ${(
        farmerData.expenses?.financial_stability_avg || 0
      ).toFixed(2)}%\n`;
      report += `Cash Flow Average: ${formatCurrency(
        farmerData.expenses?.cash_flow_avg || 0
      )}\n\n`;

      // Most Traded Goods
      if (
        farmerData.expenses?.most_traded_goods &&
        farmerData.expenses.most_traded_goods.length > 0
      ) {
        report += "MOST TRADED GOODS\n";
        report += "-".repeat(40) + "\n";
        farmerData.expenses.most_traded_goods.forEach((good, index) => {
          report += `${index + 1}. ${good.name}: ${good.count} transactions\n`;
        });
        report += "\n";
      }

      // Health Assessment Summary
      report += "HEALTH ASSESSMENT SUMMARY\n";
      report += "-".repeat(40) + "\n";
      report += `Total Assessments: ${
        farmerData.health?.total_assessments || 0
      }\n`;
      report += `Average Profit Margin: ${(
        farmerData.health?.average_profit_margin || 0
      ).toFixed(2)}%\n`;
      report += `Total Subsidies: ${formatCurrency(
        farmerData.health?.total_subsidies || 0
      )}\n`;
      report += `Crops Assessed: ${
        farmerData.health?.crop_types_assessed?.join(", ") || "None"
      }\n\n`;

      // Forecasting Activity
      report += "FORECASTING ACTIVITY\n";
      report += "-".repeat(40) + "\n";
      report += `Total Predictions: ${
        farmerData.forecasting?.total_predictions || 0
      }\n`;
      report += `Regions Queried: ${
        farmerData.forecasting?.regions_queried?.join(", ") || "None"
      }\n`;
      report += `Crops Queried: ${
        farmerData.forecasting?.crops_queried?.join(", ") || "None"
      }\n\n`;

      // Recommendations Summary
      report += "RECOMMENDATIONS SUMMARY\n";
      report += "-".repeat(40) + "\n";
      report += `Loan Advice Count: ${
        farmerData.recommendations?.loan_advice_count || 0
      }\n`;
      report += `Cost Cutting Count: ${
        farmerData.recommendations?.cost_cutting_count || 0
      }\n`;
      report += `Topics: ${
        farmerData.recommendations?.recommendation_topics?.join(", ") || "None"
      }\n\n`;

      // Footer
      report += "=".repeat(60) + "\n";
      report += "End of Report\n";

      // Create blob and download
      const blob = new Blob([report], { type: "text/plain;charset=utf-8;" });
      const link = document.createElement("a");
      const url = URL.createObjectURL(blob);

      const fileName = `farmer_detailed_report_${
        farmerData.activity.name?.replace(/\s+/g, "_") ||
        farmerData.activity.user_id
      }_${new Date().toISOString().split("T")[0]}.txt`;

      link.setAttribute("href", url);
      link.setAttribute("download", fileName);
      link.style.visibility = "hidden";

      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      toast({
        title: "Export Successful",
        description: `Detailed report exported to ${fileName}`,
      });
    } catch (error) {
      console.error("Error exporting detailed report:", error);
      toast({
        title: "Export Failed",
        description: "Failed to export detailed report. Please try again.",
        variant: "destructive",
      });
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-600 mx-auto"></div>
          <p className="mt-2 text-muted-foreground">
            Loading farmer details...
          </p>
        </div>
      </div>
    );
  }

  if (!farmerData) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <div className="text-center">
          <AlertTriangle className="h-8 w-8 text-red-500 mx-auto mb-2" />
          <p className="text-muted-foreground">Failed to load farmer data</p>
          <Button onClick={fetchFarmerDetails} className="mt-4">
            <RefreshCw className="w-4 h-4 mr-2" />
            Retry
          </Button>
        </div>
      </div>
    );
  }

  // Prepare data for charts
  const monthlyTrends =
    farmerData.expenses?.most_traded_goods?.map((good, index) => ({
      name: good.name,
      count: good.count,
      color: pieColors[index % pieColors.length],
    })) || [];

  const mostFrequentQueries =
    farmerData.forecasting?.most_frequent_queries || [];

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-start">
        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => navigate("/farmers")}
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Farmers
          </Button>
          <div>
            <h1 className="text-3xl font-bold tracking-tight">
              {farmerData.activity.name || "Unknown Farmer"}
            </h1>
            <p className="text-muted-foreground">
              Farmer ID: {farmerData.activity.user_id}
            </p>
          </div>
        </div>
        <div className="flex gap-2">
          <Button variant="outline">
            <MessageSquare className="w-4 h-4 mr-2" />
            Send Message
          </Button>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline">
                <FileSpreadsheet className="w-4 h-4 mr-2" />
                Export Data
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-56">
              <DropdownMenuLabel>Export Options</DropdownMenuLabel>
              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={exportToCSV}>
                <FileSpreadsheet className="mr-2 h-4 w-4" />
                Export to Excel (CSV)
              </DropdownMenuItem>
              <DropdownMenuItem onClick={exportToJSON}>
                <FileJson className="mr-2 h-4 w-4" />
                Export as JSON
              </DropdownMenuItem>
              <DropdownMenuItem onClick={exportDetailedReport}>
                <FileText className="mr-2 h-4 w-4" />
                Export Detailed Report
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>

      {/* Alert if farmer needs attention */}
      {farmerData.needs_attention && (
        <Card className="border-red-200 bg-red-50">
          <CardHeader className="pb-3">
            <div className="flex items-center gap-2">
              <AlertTriangle className="w-5 h-5 text-red-500" />
              <CardTitle className="text-lg text-red-700">
                Attention Required
              </CardTitle>
            </div>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-red-600">
              This farmer requires attention due to low engagement or financial
              instability.
            </p>
          </CardContent>
        </Card>
      )}

      {/* Profile Overview */}
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Contact Info</CardTitle>
            <Phone className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-lg font-bold">
              {farmerData.activity.phone_number || "N/A"}
            </div>
            <p className="text-xs text-muted-foreground flex items-center mt-1">
              <MapPin className="w-3 h-3 mr-1" />
              {farmerData.activity.location || "Unknown Location"}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Account Status
            </CardTitle>
            <Activity className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="flex items-center gap-2">
              <Badge
                variant={
                  farmerData.activity.is_active ? "default" : "secondary"
                }
              >
                {farmerData.activity.is_active ? "Active" : "Inactive"}
              </Badge>
              <Badge className={getRiskBadgeColor(farmerData.risk_level)}>
                {farmerData.risk_level} risk
              </Badge>
            </div>
            <p className="text-xs text-muted-foreground mt-1">
              {farmerData.activity.total_logins} total logins
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Engagement Score
            </CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">
              {farmerData.engagement_score.toFixed(1)}%
            </div>
            <p className="text-xs text-muted-foreground">
              {farmerData.engagement_score >= 70
                ? "Above average"
                : farmerData.engagement_score >= 40
                ? "Average"
                : "Below average"}{" "}
              performance
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Profit</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div
              className={`text-2xl font-bold ${
                (farmerData.expenses?.total_profit || 0) >= 0
                  ? "text-green-600"
                  : "text-red-600"
              }`}
            >
              {formatCurrency(farmerData.expenses?.total_profit || 0)}
            </div>
            <p className="text-xs text-muted-foreground">
              From {farmerData.expenses?.expense_count || 0} transactions
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Time Filter */}
      <div className="flex justify-between items-center">
        <h2 className="text-xl font-semibold">Detailed Analytics</h2>
        <Select value={timeFilter} onValueChange={setTimeFilter}>
          <SelectTrigger className="w-[180px]">
            <SelectValue placeholder="Time Period" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Time</SelectItem>
            <SelectItem value="yearly">This Year</SelectItem>
            <SelectItem value="monthly">This Month</SelectItem>
            <SelectItem value="weekly">This Week</SelectItem>
          </SelectContent>
        </Select>
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
                    {formatCurrency(farmerData.expenses?.total_revenue || 0)}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm">Total Expenses:</span>
                  <span className="font-medium text-red-600">
                    {formatCurrency(farmerData.expenses?.total_expenses || 0)}
                  </span>
                </div>
                <div className="flex justify-between border-t pt-2">
                  <span className="text-sm font-medium">Net Profit:</span>
                  <span
                    className={`font-bold ${
                      (farmerData.expenses?.total_profit || 0) >= 0
                        ? "text-green-600"
                        : "text-red-600"
                    }`}
                  >
                    {formatCurrency(farmerData.expenses?.total_profit || 0)}
                  </span>
                </div>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span>Financial Stability:</span>
                    <span>
                      {farmerData.expenses?.financial_stability_avg?.toFixed(
                        1
                      ) || 0}
                      %
                    </span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div
                      className="bg-green-600 h-2 rounded-full"
                      style={{
                        width: `${
                          farmerData.expenses?.financial_stability_avg || 0
                        }%`,
                      }}
                    ></div>
                  </div>
                </div>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span>Cash Flow Average:</span>
                    <span>
                      {formatCurrency(farmerData.expenses?.cash_flow_avg || 0)}
                    </span>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Most Traded Goods</CardTitle>
              </CardHeader>
              <CardContent>
                {monthlyTrends.length > 0 ? (
                  <ResponsiveContainer width="100%" height={200}>
                    <PieChart>
                      <Pie
                        data={monthlyTrends}
                        cx="50%"
                        cy="50%"
                        labelLine={false}
                        label={({ name, count }) => `${name} (${count})`}
                        outerRadius={60}
                        fill="#8884d8"
                        dataKey="count"
                      >
                        {monthlyTrends.map((entry, index) => (
                          <Cell key={`cell-${index}`} fill={entry.color} />
                        ))}
                      </Pie>
                      <Tooltip />
                    </PieChart>
                  </ResponsiveContainer>
                ) : (
                  <div className="flex items-center justify-center h-[200px] text-gray-500">
                    No trading data available
                  </div>
                )}
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Activity Summary</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex justify-between text-sm">
                  <span>Total Assessments:</span>
                  <span className="font-medium">
                    {farmerData.expenses?.assessment_count || 0}
                  </span>
                </div>
                <div className="flex justify-between text-sm">
                  <span>Last Activity:</span>
                  <span className="font-medium">
                    {farmerData.expenses?.last_activity
                      ? formatDate(farmerData.expenses.last_activity)
                      : "No recent activity"}
                  </span>
                </div>
                <div className="flex justify-between text-sm">
                  <span>Registration Date:</span>
                  <span className="font-medium">
                    {formatDate(farmerData.activity.created_at)}
                  </span>
                </div>
                <div className="flex justify-between text-sm">
                  <span>Last Login:</span>
                  <span className="font-medium">
                    {farmerData.activity.last_login
                      ? formatDateTime(farmerData.activity.last_login)
                      : "Never"}
                  </span>
                </div>
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
                      {farmerData.forecasting?.total_predictions || 0}
                    </div>
                    <div className="text-sm text-blue-600">
                      Total Predictions
                    </div>
                  </div>
                  <div className="text-center p-4 bg-green-50 rounded-lg">
                    <div className="text-2xl font-bold text-green-600">
                      {farmerData.forecasting?.regions_queried?.length || 0}
                    </div>
                    <div className="text-sm text-green-600">
                      Regions Queried
                    </div>
                  </div>
                </div>
                <div className="space-y-2">
                  <div className="text-sm font-medium">Regions Queried:</div>
                  <div className="flex gap-2 flex-wrap">
                    {farmerData.forecasting?.regions_queried?.map((region) => (
                      <Badge key={region} variant="outline">
                        {region}
                      </Badge>
                    )) || (
                      <span className="text-gray-500 text-sm">
                        No regions queried
                      </span>
                    )}
                  </div>
                </div>
                <div className="space-y-2">
                  <div className="text-sm font-medium">Crops Queried:</div>
                  <div className="flex gap-2 flex-wrap">
                    {farmerData.forecasting?.crops_queried?.map((crop) => (
                      <Badge key={crop} variant="outline">
                        {crop}
                      </Badge>
                    )) || (
                      <span className="text-gray-500 text-sm">
                        No crops queried
                      </span>
                    )}
                  </div>
                </div>
                <div className="text-sm">
                  <span className="text-gray-600">Last Prediction: </span>
                  <span className="font-medium">
                    {farmerData.forecasting?.last_prediction
                      ? formatDate(farmerData.forecasting.last_prediction)
                      : "No predictions yet"}
                  </span>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Frequent Queries</CardTitle>
              </CardHeader>
              <CardContent>
                {mostFrequentQueries.length > 0 ? (
                  <ResponsiveContainer width="100%" height={250}>
                    <BarChart data={mostFrequentQueries}>
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis
                        dataKey="query"
                        angle={-45}
                        textAnchor="end"
                        height={100}
                      />
                      <YAxis />
                      <Tooltip />
                      <Bar dataKey="count" fill="#3b82f6" />
                    </BarChart>
                  </ResponsiveContainer>
                ) : (
                  <div className="flex items-center justify-center h-[250px] text-gray-500">
                    No query data available
                  </div>
                )}
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
                      {farmerData.health?.total_assessments || 0}
                    </div>
                    <div className="text-sm text-green-600">
                      Total Assessments
                    </div>
                  </div>
                  <div className="text-center p-4 bg-blue-50 rounded-lg">
                    <div className="text-2xl font-bold text-blue-600">
                      {farmerData.health?.average_profit_margin?.toFixed(1) ||
                        0}
                      %
                    </div>
                    <div className="text-sm text-blue-600">
                      Avg. Profit Margin
                    </div>
                  </div>
                </div>
                <div className="space-y-2">
                  <div className="flex justify-between">
                    <span className="text-sm">Total Subsidies:</span>
                    <span className="font-medium text-green-600">
                      {formatCurrency(farmerData.health?.total_subsidies || 0)}
                    </span>
                  </div>
                  <div className="text-sm font-medium">Crops Assessed:</div>
                  <div className="flex gap-2 flex-wrap">
                    {farmerData.health?.crop_types_assessed?.map((crop) => (
                      <Badge key={crop} variant="outline">
                        {crop}
                      </Badge>
                    )) || (
                      <span className="text-gray-500 text-sm">
                        No crops assessed
                      </span>
                    )}
                  </div>
                  <div className="text-sm">
                    <span className="text-gray-600">Last Assessment: </span>
                    <span className="font-medium">
                      {farmerData.health?.last_assessment
                        ? formatDate(farmerData.health.last_assessment)
                        : "No assessments yet"}
                    </span>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg">
                  Health Assessment Status
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {farmerData.health &&
                  farmerData.health.total_assessments > 0 ? (
                    <div className="space-y-3">
                      <div className="p-3 border rounded-lg">
                        <div className="flex justify-between items-center">
                          <span className="text-sm text-gray-600">
                            Average Profit Margin
                          </span>
                          <Badge variant="outline" className="text-green-600">
                            {farmerData.health.average_profit_margin?.toFixed(
                              1
                            ) || 0}
                            %
                          </Badge>
                        </div>
                      </div>
                      <div className="p-3 border rounded-lg">
                        <div className="flex justify-between items-center">
                          <span className="text-sm text-gray-600">
                            Total Subsidies Received
                          </span>
                          <span className="font-medium">
                            {formatCurrency(
                              farmerData.health.total_subsidies || 0
                            )}
                          </span>
                        </div>
                      </div>
                      <div className="p-3 border rounded-lg">
                        <div className="flex justify-between items-center">
                          <span className="text-sm text-gray-600">
                            Assessment Frequency
                          </span>
                          <span className="font-medium">
                            {farmerData.health.total_assessments} assessments
                          </span>
                        </div>
                      </div>
                    </div>
                  ) : (
                    <div className="text-center py-8 text-gray-500">
                      No health assessments recorded yet
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="recommendations" className="space-y-4">
          <div className="grid gap-6 md:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">
                  Recommendation Summary
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div className="text-center p-4 bg-orange-50 rounded-lg">
                    <div className="text-2xl font-bold text-orange-600">
                      {farmerData.recommendations?.loan_advice_count || 0}
                    </div>
                    <div className="text-sm text-orange-600">Loan Advice</div>
                  </div>
                  <div className="text-center p-4 bg-purple-50 rounded-lg">
                    <div className="text-2xl font-bold text-purple-600">
                      {farmerData.recommendations?.cost_cutting_count || 0}
                    </div>
                    <div className="text-sm text-purple-600">Cost Cutting</div>
                  </div>
                </div>
                <div className="space-y-2">
                  <div className="text-sm font-medium">
                    Recommendation Topics:
                  </div>
                  <div className="flex gap-2 flex-wrap">
                    {farmerData.recommendations?.recommendation_topics?.map(
                      (topic) => (
                        <Badge key={topic} variant="outline">
                          {topic.replace("_", " ")}
                        </Badge>
                      )
                    ) || (
                      <span className="text-gray-500 text-sm">
                        No recommendations yet
                      </span>
                    )}
                  </div>
                  <div className="text-sm">
                    <span className="text-gray-600">Last Recommendation: </span>
                    <span className="font-medium">
                      {farmerData.recommendations?.last_recommendation
                        ? formatDate(
                            farmerData.recommendations.last_recommendation
                          )
                        : "No recommendations yet"}
                    </span>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Recommendation Status</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {(farmerData.recommendations?.loan_advice_count || 0) +
                    (farmerData.recommendations?.cost_cutting_count || 0) >
                  0 ? (
                    <div className="space-y-3">
                      <div className="p-3 border rounded-lg">
                        <div className="flex justify-between items-center">
                          <span className="text-sm">Total Recommendations</span>
                          <span className="font-medium">
                            {(farmerData.recommendations?.loan_advice_count ||
                              0) +
                              (farmerData.recommendations?.cost_cutting_count ||
                                0)}
                          </span>
                        </div>
                      </div>
                      <div className="p-3 border rounded-lg">
                        <div className="flex justify-between items-center">
                          <span className="text-sm">Most Common Type</span>
                          <Badge variant="outline">
                            {(farmerData.recommendations?.cost_cutting_count ||
                              0) >=
                            (farmerData.recommendations?.loan_advice_count || 0)
                              ? "Cost Cutting"
                              : "Loan Advice"}
                          </Badge>
                        </div>
                      </div>
                      {farmerData.recommendations?.recommendation_topics &&
                        farmerData.recommendations.recommendation_topics
                          .length > 0 && (
                          <div className="p-3 border rounded-lg">
                            <div className="text-sm text-gray-600 mb-2">
                              Topics Covered:
                            </div>
                            <div className="flex gap-2 flex-wrap">
                              {farmerData.recommendations.recommendation_topics.map(
                                (topic) => (
                                  <Badge
                                    key={topic}
                                    variant="secondary"
                                    className="text-xs"
                                  >
                                    {topic.replace(/_/g, " ")}
                                  </Badge>
                                )
                              )}
                            </div>
                          </div>
                        )}
                    </div>
                  ) : (
                    <div className="text-center py-8 text-gray-500">
                      No recommendations provided yet
                    </div>
                  )}
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
