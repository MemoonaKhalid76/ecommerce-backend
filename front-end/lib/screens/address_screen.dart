import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/address_service.dart';
import '../models/address_model.dart';
import 'order_success_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();

  bool isLoading = false;
  bool saveAddress = false;
  List<Address> savedAddresses = [];
  String? selectedAddressId;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isLoggedIn && auth.token != null) {
      try {
        final addresses = await AddressService.fetchAddresses(auth.token!);
        setState(() {
          savedAddresses = addresses;
        });
      } catch (e) {
        debugPrint('Failed to load addresses: $e');
      }
    }
  }

  void _fillAddress(Address address) {
    nameController.text = address.fullName;
    phoneController.text = address.phone;
    addressController.text = address.addressLine;
    cityController.text = address.city;
    setState(() {
      selectedAddressId = address.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Delivery Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 SAVED ADDRESSES SELECTOR
                if (auth.isLoggedIn && savedAddresses.isNotEmpty) ...[
                  const Text(
                    'Saved Addresses',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: savedAddresses.length,
                      itemBuilder: (context, index) {
                        final addr = savedAddresses[index];
                        final isSelected = selectedAddressId == addr.id;
                        return GestureDetector(
                          onTap: () => _fillAddress(addr),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 240,
                            margin: const EdgeInsets.only(right: 12, bottom: 4),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.white,
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isSelected 
                                  ? []
                                  : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 16, color: isSelected ? Colors.blue : Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        addr.fullName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold, 
                                          fontSize: 15,
                                          color: isSelected ? Colors.blue : Colors.black87
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isSelected) 
                                      const Icon(Icons.check_circle, size: 18, color: Colors.blue)
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  addr.phone,
                                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: Text(
                                    '${addr.addressLine}, ${addr.city}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                ],

                const Text(
                    'Enter Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                const SizedBox(height: 16),

                _buildTextField(nameController, 'Full Name', Icons.person_outline),
                const SizedBox(height: 16),
                _buildTextField(phoneController, 'Phone Number', Icons.phone_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildTextField(addressController, 'Address (Street, House No.)', Icons.home_outlined),
                const SizedBox(height: 16),
                _buildTextField(cityController, 'City', Icons.location_city_outlined),

                const SizedBox(height: 20),

                // 🔹 SAVE ADDRESS CHECKBOX
                if (auth.isLoggedIn)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: CheckboxListTile(
                      title: const Text('Save this address for future'),
                      value: saveAddress,
                      activeColor: Colors.black,
                      onChanged: (val) {
                        setState(() {
                          saveAddress = val!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),

                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: isLoading ? null : _submitOrder,
                    child: isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Confirm Order', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Future<void> _submitOrder() async {
     final cart = Provider.of<CartProvider>(context, listen: false);
     final auth = Provider.of<AuthProvider>(context, listen: false);

      if (!_formKey.currentState!.validate()) return;

      setState(() => isLoading = true);

      try {
        // 1. Save address if requested
        if (saveAddress && auth.token != null) {
           await AddressService.addAddress(auth.token!, {
            'fullName': nameController.text.trim(),
            'phone': phoneController.text.trim(),
            'addressLine': addressController.text.trim(),
            'city': cityController.text.trim(),
            'isDefault': false,
          });
        }

        // 2. Place Order
        await ApiService.placeOrder({
          "products": cart.items.values
              .map(
                (item) => {
                  "product": item.product.id,
                  "quantity": item.quantity,
                },
              )
              .toList(),
          "totalAmount": cart.totalAmount,
          "customerName": nameController.text.trim(),
          "customerPhone": phoneController.text.trim(),
          "customerAddress":
              '${addressController.text}, ${cityController.text}',
        }, token: auth.token);

        cart.clearCart();

        if (!mounted) return;
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const OrderSuccessScreen(),
          ),
          (route) => false,
        );

      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
  }
}
