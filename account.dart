import 'package:flutter/material.dart';
import '../logic/auth_logic.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(text: 'Juan Dela Cruz');
  final TextEditingController _emailController = TextEditingController(text: 'juancruz@email.com');
  final TextEditingController _ageController = TextEditingController(text: '21');
  final TextEditingController _genderController = TextEditingController(text: 'Male');
  final TextEditingController _phoneController = TextEditingController(text: '09123456789');
  final TextEditingController _licenseController = TextEditingController(text: 'D123456789');
  final TextEditingController _emergencyController = TextEditingController(text: 'Mom - 0999988888');
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      // Capture the context before the async gap
      final BuildContext currentContext = context;
      
      // Simulate API call
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        
        setState(() {
          _isSaving = false;
          _isEditing = false;
        });

        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully!')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile picture
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFF018ABD),
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF018ABD),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Static Name & Email
                _buildInfoCard('Name', _nameController.text, Icons.person),
                const SizedBox(height: 12),
                _buildInfoCard('Email', _emailController.text, Icons.email),
                const SizedBox(height: 20),

                // Editable Fields
                if (_isEditing) ...[
                  const Text(
                    'Edit Profile Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF018ABD),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildEditableField('Name', _nameController, Icons.person, true),
                  _buildEditableField('Email', _emailController, Icons.email, true),
                  _buildEditableField('Age', _ageController, Icons.calendar_today, false, TextInputType.number),
                  _buildEditableField('Gender', _genderController, Icons.transgender, false),
                  _buildEditableField('Phone Number', _phoneController, Icons.phone, false, TextInputType.phone),
                  _buildEditableField('License No.', _licenseController, Icons.card_membership, false),
                  _buildEditableField('Emergency Contact', _emergencyController, Icons.contact_phone, false),
                ] else ...[
                  const Text(
                    'Profile Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF018ABD),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard('Age', _ageController.text, Icons.calendar_today),
                  _buildInfoCard('Gender', _genderController.text, Icons.transgender),
                  _buildInfoCard('Phone Number', _phoneController.text, Icons.phone),
                  _buildInfoCard('License No.', _licenseController.text, Icons.card_membership),
                  _buildInfoCard('Emergency Contact', _emergencyController.text, Icons.contact_phone),
                ],

                const SizedBox(height: 30),
                
                // Account Management Section
                const Text(
                  'Account Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF018ABD),
                  ),
                ),
                const SizedBox(height: 16),
                _buildManagementOption('Change Password', Icons.lock),
                const SizedBox(height: 12),
                _buildManagementOption('Privacy Settings', Icons.privacy_tip),
                const SizedBox(height: 12),
                _buildManagementOption('Delete Account', Icons.delete, isDestructive: true),

                const SizedBox(height: 30),
                
                // Save button when editing
                if (_isEditing) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF018ABD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // Logout button
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  AuthLogic().logout();
                                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF018ABD)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label, 
    TextEditingController controller, 
    IconData icon, 
    bool isRequired, 
    [TextInputType keyboardType = TextInputType.text]
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: isRequired ? (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        } : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF018ABD)),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildManagementOption(String title, IconData icon, {bool isDestructive = false}) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF018ABD)),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (isDestructive) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Delete account functionality coming soon')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Manage $title functionality coming soon')),
            );
          }
        },
      ),
    );
  }
}
