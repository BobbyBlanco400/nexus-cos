export interface User {
  _id: string;
  username: string;
  email: string;
  password: string;
  role: 'user' | 'creator' | 'admin';
  profile?: {
    bio?: string;
    avatar?: string;
    settings?: Record<string, any>;
  };
  createdAt: Date;
  updatedAt: Date;
}

export interface AuthRequest extends Request {
  user?: User;
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
}