
import React, { createContext, useContext, useState, useEffect } from 'react';
import { adminApi } from '../services/api';

interface AuthUser {
  id: string;
  name: string;
  phone: string;
  role: string;
}

interface AuthContextType {
  user: AuthUser | null;
  isLoading: boolean;
  login: (phone: string, password: string) => Promise<void>;
  logout: () => void;
  refreshToken: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Check if user is already logged in
    const token = localStorage.getItem('access_token');
    const userData = localStorage.getItem('user_data');
    
    if (token && userData) {
      try {
        setUser(JSON.parse(userData));
      } catch (error) {
        console.error('Error parsing user data:', error);
        localStorage.removeItem('access_token');
        localStorage.removeItem('user_data');
      }
    }
    setIsLoading(false);
  }, []);

  const login = async (phone: string, password: string) => {
    setIsLoading(true);
    
    try {
      console.log('Starting login process...');
      const data = await adminApi.login(phone, password);
      
      // Store tokens
      localStorage.setItem('access_token', data.access_token);
      localStorage.setItem('refresh_token', data.refresh_token);
      
      // Mock user data (in real app, you'd get this from the backend)
      const userData = {
        id: '1',
        name: 'Admin User',
        phone: phone,
        role: 'Super Admin'
      };
      
      localStorage.setItem('user_data', JSON.stringify(userData));
      setUser(userData);
      
      console.log('Login successful, user data stored');
      // Navigation will be handled by the component that calls login
    } catch (error) {
      console.error('Login error in context:', error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = () => {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    localStorage.removeItem('user_data');
    setUser(null);
    // Navigation will be handled by the component that calls logout
    window.location.href = '/login';
  };

  const refreshToken = async () => {
    try {
      await adminApi.refreshToken();
    } catch (error) {
      console.error('Token refresh error:', error);
      logout();
    }
  };

  return (
    <AuthContext.Provider value={{ user, isLoading, login, logout, refreshToken }}>
      {children}
    </AuthContext.Provider>
  );
};
