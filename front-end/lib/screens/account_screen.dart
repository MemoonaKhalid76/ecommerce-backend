import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'faq_screen.dart';
import 'request_otp_screen.dart';
import 'order_history_screen.dart';
import 'address_book_screen.dart';
import 'contact_us_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  void _requireLogin(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign in required'),
        content: const Text('Please sign in to access this feature.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RequestOtpScreen()),
              );
            },
            child: const Text('Sign In', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ================= PROFILE HEADER =================
          _buildProfileHeader(context, auth),
          
          const SizedBox(height: 30),
          
          // ================= SECTIONS =================
          const Text(
            'MY ACCOUNT',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 10),
          _buildMenuCard([
            _buildMenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'My Orders',
              onTap: () {
                if (!auth.isLoggedIn) {
                  _requireLogin(context);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                  );
                }
              },
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Shipping Addresses',
              onTap: () {
                if (!auth.isLoggedIn) {
                  _requireLogin(context);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddressBookScreen()),
                  );
                }
              },
            ),
          ]),

          const SizedBox(height: 30),
          
          const Text(
            'SUPPORT',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 10),
          _buildMenuCard([
            _buildMenuItem(
              icon: Icons.headset_mic_outlined,
              title: 'Contact Us',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                );
              },
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'FAQs',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FaqScreen()),
                );
              },
            ),
          ]),

          const SizedBox(height: 30),

          // ================= LOGOUT BUTTON =================
          if (auth.isLoggedIn)
            _buildLogoutButton(context, auth),
            
          const SizedBox(height: 40),
          
          // ================= SOCIAL LINKS =================
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(Icons.facebook, Colors.blue, 'https://facebook.com'),
              const SizedBox(width: 20),
              _buildSocialButton(Icons.camera_alt, Colors.pink, 'https://instagram.com'),
              const SizedBox(width: 20),
              _buildSocialButton(Icons.alternate_email, Colors.lightBlue, 'https://twitter.com'),
            ],
          ),
          
          const SizedBox(height: 30),

          Center(
            child: Text(
              'App Version 1.0.0',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          )
        ],
      ),
    );
  }



  Widget _buildProfileHeader(BuildContext context, AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue.shade100, width: 2),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.blue.shade50,
              child: Icon(
                Icons.person,
                size: 36,
                color: Colors.blue.shade600,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.isLoggedIn 
                    ? (auth.user != null && auth.user!['name'] != null ? 'Hi, ${auth.user!['name']}' : 'Welcome Back!') 
                    : 'Welcome, Guest',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                if (auth.isLoggedIn && auth.user != null && auth.user!['email'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      auth.user!['email'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 8),
                if (!auth.isLoggedIn)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RequestOtpScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Login / Sign up',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  Text(
                    'Thanks for being with us.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 60);
  }
  
  Widget _buildLogoutButton(BuildContext context, AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF5F5),
          foregroundColor: Colors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () async {
           final shouldLogout = await showDialog<bool>(
             context: context,
             builder: (c) => AlertDialog(
               title: const Text('Logout'),
               content: const Text('Are you sure you want to logout?'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
               actions: [
                 TextButton(
                   onPressed: () => Navigator.pop(c, false),
                   child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                 ),
                 TextButton(
                   onPressed: () => Navigator.pop(c, true),
                   child: const Text('Logout', style: TextStyle(color: Colors.red)),
                 ),
               ],
             ),
           );

           if (shouldLogout == true) {
             await auth.logout();
           }
        },
        child: const Text(
          'Log Out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  
  // Social Helper
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  Widget _buildSocialButton(IconData icon, Color color, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
