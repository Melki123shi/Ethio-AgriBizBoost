import axios, { AxiosInstance } from 'axios';

const API_BASE_URL = 'https://ethio-agribizboost.onrender.com';

export interface DashboardSummary {
  total_farmers: number;
  active_farmers: number;
  inactive_farmers: number;
  farmers_needing_attention: number;
  auth_usage: {
    total_logins: number;
    avg_logins_per_user: number;
  };
  expense_tracking_usage: {
    total_entries: number;
    avg_entries_per_user: number;
  };
  forecasting_usage: {
    total_predictions: number;
    avg_predictions_per_user: number;
  };
  health_assessment_usage: {
    total_assessments: number;
    avg_assessments_per_user: number;
  };
  recommendation_usage: {
    total_recommendations: number;
    avg_recommendations_per_user: number;
  };
  total_system_revenue: number;
  total_system_expenses: number;
  total_system_profit: number;
  daily_active_users: Array<{ date: string; count: number }>;
  regional_distribution: Record<string, number>;
  time_filter: string;
  generated_at: string;
}

export interface FarmerActivity {
  user_id: string;
  phone_number: string;
  name: string;
  last_login: string;
  total_logins: number;
  is_active: boolean;
  created_at: string;
  location: string;
}

export interface ExpenseMetrics {
  user_id: string;
  total_expenses: number;
  total_revenue: number;
  total_profit: number;
  expense_count: number;
  assessment_count: number;
  most_traded_goods: Array<{ name: string; count: number }>;
  financial_stability_avg: number;
  cash_flow_avg: number;
  last_activity: string;
}

export interface ForecastingMetrics {
  user_id: string;
  total_predictions: number;
  regions_queried: string[];
  crops_queried: string[];
  last_prediction: string;
  most_frequent_queries: Array<{ query: string; count: number }>;
}

export interface HealthAssessmentMetrics {
  user_id: string;
  total_assessments: number;
  crop_types_assessed: string[];
  average_profit_margin: number;
  total_subsidies: number;
  last_assessment: string;
}

export interface RecommendationMetrics {
  user_id: string;
  loan_advice_count: number;
  cost_cutting_count: number;
  last_recommendation: string;
  recommendation_topics: string[];
}

export interface FarmerData {
  activity: FarmerActivity;
  expenses?: ExpenseMetrics;
  forecasting?: ForecastingMetrics;
  health?: HealthAssessmentMetrics;
  recommendations?: RecommendationMetrics;
  engagement_score: number;
  risk_level: string;
  needs_attention: boolean;
}

export interface FarmersListResponse {
  farmers: FarmerData[];
  total_count: number;
  page: number;
  page_size: number;
  total_pages: number;
}

export interface ActivityLog {
  id: string;
  user_id: string;
  action: string;
  service: string;
  timestamp: string;
  details: {
    ip_address: string;
    user_agent?: string;
  };
  status: string;
}

export interface ActivityLogsResponse {
  logs: ActivityLog[];
  total_count: number;
  page: number;
  page_size: number;
}

export interface AdminUser {
  _id: { $oid: string };
  name: string;
  phone_number: string;
  is_active: boolean;
  is_admin: boolean;
  is_super_admin: boolean;
  permissions: string[];
  created_at: { $date: { $numberLong: string } };
  email?: string;
}

export interface CreateAdminRequest {
  name: string;
  phone_number: string;
  password: string;
  is_super_admin: boolean;
  permissions: string[];
}

export interface UpdateAdminRequest {
  name?: string;
  phone_number?: string;
  is_super_admin?: boolean;
  permissions?: string[];
  is_active?: boolean;
}

class AdminApiService {
  private apiClient: AxiosInstance;

  constructor() {
    this.apiClient = axios.create({
      baseURL: API_BASE_URL,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // Add CORS configuration
      withCredentials: false,
    });

    this.setupInterceptors();
  }

  private setupInterceptors() {
    this.apiClient.interceptors.request.use((config) => {
      const token = localStorage.getItem('access_token');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      console.log('Making API request to:', config.url);
      return config;
    });

    this.apiClient.interceptors.response.use(
      (response) => {
        console.log('API response received:', response.status);
        return response;
      },
      async (error) => {
        console.error('API Error:', error);
        
        // Handle CORS errors specifically
        if (error.code === 'ERR_NETWORK' || error.message.includes('NetworkError')) {
          console.error('CORS/Network Error detected');
          throw new Error('Network error: Unable to connect to the server. This might be a CORS issue.');
        }

        if (error.response?.status === 401) {
          const refreshToken = localStorage.getItem('refresh_token');
          if (refreshToken) {
            try {
              await this.refreshToken();
              return this.apiClient.request(error.config);
            } catch (refreshError) {
              localStorage.removeItem('access_token');
              localStorage.removeItem('refresh_token');
              localStorage.removeItem('user_data');
              window.location.href = '/login';
            }
          }
        }
        return Promise.reject(error);
      }
    );
  }

  async refreshToken(): Promise<void> {
    const refreshToken = localStorage.getItem('refresh_token');
    if (!refreshToken) {
      throw new Error('No refresh token available');
    }

    try {
      const { data } = await this.apiClient.post('/auth/refresh', {
        refresh_token: refreshToken,
      });

      localStorage.setItem('access_token', data.access_token);
      localStorage.setItem('refresh_token', data.refresh_token);
    } catch (error) {
      console.error('Token refresh failed:', error);
      throw error;
    }
  }

  async getDashboardSummary(timeFilter = 'all'): Promise<DashboardSummary> {
    try {
      const { data } = await this.apiClient.get('/admin/dashboard/summary', {
        params: { time_filter: timeFilter },
      });
      return data;
    } catch (error) {
      console.error('Error fetching dashboard summary:', error);
      throw error;
    }
  }

  async getFarmers(filters: {
    page?: number;
    page_size?: number;
    time_filter?: string;
    region?: string;
    is_active?: boolean;
    min_engagement_score?: number;
    sort_by?: string;
    sort_order?: string;
  }): Promise<FarmersListResponse> {
    try {
      const { data } = await this.apiClient.get('/admin/farmers', {
        params: filters,
      });
      return data;
    } catch (error) {
      console.error('Error fetching farmers:', error);
      throw error;
    }
  }

  async getFarmerDetails(farmerId: string, timeFilter = 'all'): Promise<FarmerData> {
    try {
      const { data } = await this.apiClient.get(`/admin/farmers/${farmerId}`, {
        params: { time_filter: timeFilter },
      });
      return data;
    } catch (error) {
      console.error('Error fetching farmer details:', error);
      throw error;
    }
  }

  async searchFarmers(query: string, limit = 10): Promise<{ results: any[]; count: number }> {
    try {
      const { data } = await this.apiClient.get('/admin/farmers/search', {
        params: { q: query, limit },
      });
      return data;
    } catch (error) {
      console.error('Error searching farmers:', error);
      throw error;
    }
  }

  async getFarmersNeedingAttention(page = 1, pageSize = 20): Promise<FarmersListResponse> {
    try {
      const { data } = await this.apiClient.get('/admin/farmers/needing-attention', {
        params: { page, page_size: pageSize },
      });
      return data;
    } catch (error) {
      console.error('Error fetching farmers needing attention:', error);
      throw error;
    }
  }

  async getServiceTrends(service: string, timeFilter = 'monthly'): Promise<any> {
    try {
      const { data } = await this.apiClient.get(`/admin/trends/${service}`, {
        params: { time_filter: timeFilter },
      });
      return data;
    } catch (error) {
      console.error('Error fetching service trends:', error);
      throw error;
    }
  }

  async getActivityLogs(filters: {
    page?: number;
    page_size?: number;
    action?: string;
    service?: string;
    start_date?: string;
    end_date?: string;
  }): Promise<ActivityLogsResponse> {
    try {
      const { data } = await this.apiClient.get('/admin/activity-logs', {
        params: filters,
      });
      return data;
    } catch (error) {
      console.error('Error fetching activity logs:', error);
      throw error;
    }
  }

  async exportFarmerData(farmerId: string): Promise<any> {
    try {
      const { data } = await this.apiClient.get(`/admin/farmers/${farmerId}/export`);
      return data;
    } catch (error) {
      console.error('Error exporting farmer data:', error);
      throw error;
    }
  }

  // Admin management endpoints
  async getAdminUsers(): Promise<AdminUser[]> {
    try {
      const { data } = await this.apiClient.get('/admin/users');
      return data;
    } catch (error) {
      console.error('Error fetching admin users:', error);
      throw error;
    }
  }

  async createAdminUser(adminData: CreateAdminRequest): Promise<AdminUser> {
    try {
      const { data } = await this.apiClient.post('/admin/users', adminData);
      return data;
    } catch (error) {
      console.error('Error creating admin user:', error);
      throw error;
    }
  }

  async updateAdminUser(adminId: string, updateData: UpdateAdminRequest): Promise<AdminUser> {
    try {
      const { data } = await this.apiClient.put(`/admin/users/${adminId}`, updateData);
      return data;
    } catch (error) {
      console.error('Error updating admin user:', error);
      throw error;
    }
  }

  async deleteAdminUser(adminId: string): Promise<void> {
    try {
      await this.apiClient.delete(`/admin/users/${adminId}`);
    } catch (error) {
      console.error('Error deleting admin user:', error);
      throw error;
    }
  }

  // Direct login method to handle CORS issues
  async login(phoneNumber: string, password: string): Promise<any> {
    try {
      console.log('Attempting login with:', phoneNumber);
      
      const response = await fetch(`${API_BASE_URL}/auth/login-with-json`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        mode: 'cors', // Explicitly set CORS mode
        body: JSON.stringify({
          phone_number: phoneNumber,
          password: password,
        }),
      });

      console.log('Login response status:', response.status);
      
      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.detail || `HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      console.log('Login successful');
      return data;
    } catch (error) {
      console.error('Login error details:', error);
      
      if (error instanceof TypeError && error.message.includes('fetch')) {
        throw new Error('Network error: Unable to connect to the server. Please check your internet connection or try again later.');
      }
      
      throw error;
    }
  }
}

export const adminApi = new AdminApiService();
