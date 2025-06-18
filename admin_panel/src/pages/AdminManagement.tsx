
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
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { Switch } from '@/components/ui/switch';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Search,
  UserPlus,
  MoreHorizontal,
  Edit,
  Trash2,
  Shield,
  Users,
  Crown,
  Settings,
  Activity
} from 'lucide-react';
import { adminApi, AdminUser } from '../services/api';
import { useToast } from '@/hooks/use-toast';

const AdminManagement: React.FC = () => {
  const [adminUsers, setAdminUsers] = useState<AdminUser[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [editingAdmin, setEditingAdmin] = useState<AdminUser | null>(null);
  const { toast } = useToast();

  const [newAdmin, setNewAdmin] = useState({
    name: '',
    phone_number: '',
    password: '',
    is_super_admin: false,
    permissions: [] as string[]
  });

  const fetchAdminUsers = async () => {
    try {
      setIsLoading(true);
      const users = await adminApi.getAdminUsers();
      setAdminUsers(users);
    } catch (error) {
      console.error('Error fetching admin users:', error);
      toast({
        title: 'Error',
        description: 'Failed to load admin users. Please try again.',
        variant: 'destructive',
      });
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchAdminUsers();
  }, []);

  const filteredAdmins = adminUsers.filter((admin) =>
    admin.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    admin.phone_number.includes(searchTerm)
  );

  const handleCreateAdmin = async () => {
    try {
      await adminApi.createAdminUser(newAdmin);
      toast({
        title: 'Success',
        description: 'Admin user created successfully.',
      });
      setIsCreateDialogOpen(false);
      setNewAdmin({
        name: '',
        phone_number: '',
        password: '',
        is_super_admin: false,
        permissions: []
      });
      fetchAdminUsers();
    } catch (error) {
      console.error('Error creating admin:', error);
      toast({
        title: 'Error',
        description: 'Failed to create admin user. Please try again.',
        variant: 'destructive',
      });
    }
  };

  const handleUpdateAdmin = async () => {
    if (!editingAdmin) return;

    try {
      await adminApi.updateAdminUser(editingAdmin._id.$oid, {
        name: editingAdmin.name,
        phone_number: editingAdmin.phone_number,
        is_super_admin: editingAdmin.is_super_admin,
        permissions: editingAdmin.permissions,
        is_active: editingAdmin.is_active
      });
      toast({
        title: 'Success',
        description: 'Admin user updated successfully.',
      });
      setIsEditDialogOpen(false);
      setEditingAdmin(null);
      fetchAdminUsers();
    } catch (error) {
      console.error('Error updating admin:', error);
      toast({
        title: 'Error',
        description: 'Failed to update admin user. Please try again.',
        variant: 'destructive',
      });
    }
  };

  const handleDeleteAdmin = async (adminId: string) => {
    try {
      await adminApi.deleteAdminUser(adminId);
      toast({
        title: 'Success',
        description: 'Admin user deleted successfully.',
      });
      fetchAdminUsers();
    } catch (error) {
      console.error('Error deleting admin:', error);
      toast({
        title: 'Error',
        description: 'Failed to delete admin user. Please try again.',
        variant: 'destructive',
      });
    }
  };

  const formatDate = (timestamp: { $date: { $numberLong: string } }) => {
    return new Date(parseInt(timestamp.$date.$numberLong)).toLocaleDateString();
  };

  const getAdminStats = () => {
    const totalAdmins = adminUsers.length;
    const activeAdmins = adminUsers.filter(admin => admin.is_active).length;
    const superAdmins = adminUsers.filter(admin => admin.is_super_admin).length;
    const regionalAdmins = adminUsers.filter(admin => !admin.is_super_admin && admin.is_admin).length;

    return { totalAdmins, activeAdmins, superAdmins, regionalAdmins };
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-600 mx-auto"></div>
          <p className="mt-2 text-muted-foreground">Loading admin users...</p>
        </div>
      </div>
    );
  }

  const stats = getAdminStats();

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Admin Management</h1>
          <p className="text-muted-foreground">
            Manage admin users and their permissions
          </p>
        </div>
        <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
          <DialogTrigger asChild>
            <Button>
              <UserPlus className="w-4 h-4 mr-2" />
              Add Admin
            </Button>
          </DialogTrigger>
          <DialogContent className="sm:max-w-[425px]">
            <DialogHeader>
              <DialogTitle>Create New Admin</DialogTitle>
              <DialogDescription>
                Add a new administrator to the system.
              </DialogDescription>
            </DialogHeader>
            <div className="grid gap-4 py-4">
              <div className="grid grid-cols-4 items-center gap-4">
                <Label htmlFor="name" className="text-right">
                  Name
                </Label>
                <Input
                  id="name"
                  value={newAdmin.name}
                  onChange={(e) => setNewAdmin({ ...newAdmin, name: e.target.value })}
                  className="col-span-3"
                />
              </div>
              <div className="grid grid-cols-4 items-center gap-4">
                <Label htmlFor="phone" className="text-right">
                  Phone
                </Label>
                <Input
                  id="phone"
                  value={newAdmin.phone_number}
                  onChange={(e) => setNewAdmin({ ...newAdmin, phone_number: e.target.value })}
                  className="col-span-3"
                />
              </div>
              <div className="grid grid-cols-4 items-center gap-4">
                <Label htmlFor="password" className="text-right">
                  Password
                </Label>
                <Input
                  id="password"
                  type="password"
                  value={newAdmin.password}
                  onChange={(e) => setNewAdmin({ ...newAdmin, password: e.target.value })}
                  className="col-span-3"
                />
              </div>
              <div className="grid grid-cols-4 items-center gap-4">
                <Label htmlFor="super-admin" className="text-right">
                  Super Admin
                </Label>
                <Switch
                  id="super-admin"
                  checked={newAdmin.is_super_admin}
                  onCheckedChange={(checked) => setNewAdmin({ ...newAdmin, is_super_admin: checked })}
                />
              </div>
            </div>
            <DialogFooter>
              <Button type="submit" onClick={handleCreateAdmin}>
                Create Admin
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>

      {/* Admin Stats */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Admins</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.totalAdmins}</div>
            <p className="text-xs text-muted-foreground">
              {stats.activeAdmins} active
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Super Admins</CardTitle>
            <Crown className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.superAdmins}</div>
            <p className="text-xs text-muted-foreground">
              Full access
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Regional Admins</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.regionalAdmins}</div>
            <p className="text-xs text-muted-foreground">
              Regional access
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Support Staff</CardTitle>
            <Settings className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">0</div>
            <p className="text-xs text-muted-foreground">
              Support access
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Admin Users Table */}
      <Card>
        <CardHeader>
          <div className="flex justify-between items-center">
            <div>
              <CardTitle>Admin Users</CardTitle>
              <CardDescription>
                Manage administrator accounts and permissions
              </CardDescription>
            </div>
            <div className="relative w-64">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
              <Input
                placeholder="Search admins..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>Phone</TableHead>
                  <TableHead>Role</TableHead>
                  <TableHead>Created</TableHead>
                  <TableHead>Last Login</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="w-12"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredAdmins.map((admin) => (
                  <TableRow key={admin._id.$oid}>
                    <TableCell>
                      <div>
                        <div className="font-medium">{admin.name}</div>
                        <div className="text-sm text-gray-500">
                          ID: {admin._id.$oid.slice(-8)}
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>{admin.phone_number}</TableCell>
                    <TableCell>
                      <Badge variant={admin.is_super_admin ? 'default' : 'secondary'}>
                        {admin.is_super_admin ? 'Super Admin' : 'Regional Admin'}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      {formatDate(admin.created_at)}
                    </TableCell>
                    <TableCell>
                      <span className="text-sm text-gray-500">No data</span>
                    </TableCell>
                    <TableCell>
                      <Badge variant={admin.is_active ? 'default' : 'secondary'}>
                        {admin.is_active ? 'active' : 'inactive'}
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
                            onClick={() => {
                              setEditingAdmin(admin);
                              setIsEditDialogOpen(true);
                            }}
                          >
                            <Edit className="mr-2 h-4 w-4" />
                            Edit
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem
                            onClick={() => handleDeleteAdmin(admin._id.$oid)}
                            className="text-red-600"
                          >
                            <Trash2 className="mr-2 h-4 w-4" />
                            Delete
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>

      {/* Edit Admin Dialog */}
      <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
        <DialogContent className="sm:max-w-[425px]">
          <DialogHeader>
            <DialogTitle>Edit Admin User</DialogTitle>
            <DialogDescription>
              Update administrator information and permissions.
            </DialogDescription>
          </DialogHeader>
          {editingAdmin && (
            <div className="grid gap-4 py-4">
              <div className="grid grid-cols-4 items-center gap-4">
                <Label htmlFor="edit-name" className="text-right">
                  Name
                </Label>
                <Input
                  id="edit-name"
                  value={editingAdmin.name}
                  onChange={(e) => setEditingAdmin({ ...editingAdmin, name: e.target.value })}
                  className="col-span-3"
                />
              </div>
              <div className="grid grid-cols-4 items-center gap-4">
                <Label htmlFor="edit-phone" className="text-right">
                  Phone
                </Label>
                <Input
                  id="edit-phone"
                  value={editingAdmin.phone_number}
                  onChange={(e) => setEditingAdmin({ ...editingAdmin, phone_number: e.target.value })}
                  className="col-span-3"
                />
              </div>
              <div className="grid grid-cols-4 items-center gap-4">
                <Label htmlFor="edit-super-admin" className="text-right">
                  Super Admin
                </Label>
                <Switch
                  id="edit-super-admin"
                  checked={editingAdmin.is_super_admin}
                  onCheckedChange={(checked) => setEditingAdmin({ ...editingAdmin, is_super_admin: checked })}
                />
              </div>
              <div className="grid grid-cols-4 items-center gap-4">
                <Label htmlFor="edit-active" className="text-right">
                  Active
                </Label>
                <Switch
                  id="edit-active"
                  checked={editingAdmin.is_active}
                  onCheckedChange={(checked) => setEditingAdmin({ ...editingAdmin, is_active: checked })}
                />
              </div>
            </div>
          )}
          <DialogFooter>
            <Button type="submit" onClick={handleUpdateAdmin}>
              Update Admin
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default AdminManagement;
