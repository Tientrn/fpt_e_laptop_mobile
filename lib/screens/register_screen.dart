import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class RegisterStudentScreen extends StatefulWidget {
  const RegisterStudentScreen({super.key});

  @override
  State<RegisterStudentScreen> createState() => _RegisterStudentScreenState();
}

class _RegisterStudentScreenState extends State<RegisterStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _error;

  final _email = TextEditingController();
  final _name = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _dob = TextEditingController();
  final _studentCode = TextEditingController();
  final _identityCard = TextEditingController();
  final _enrollmentDate = TextEditingController();
  String _gender = 'male';
  File? _studentCardImage;
  File? _avatarImage;

  Future<void> _pickImage(bool isStudentCard) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 75,
    );
    if (picked != null) {
      setState(() {
        if (isStudentCard) {
          _studentCardImage = File(picked.path);
        } else {
          _avatarImage = File(picked.path);
        }
      });
    }
  }

  Widget _imagePreview(File? image, String label) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            image: image != null
                ? DecorationImage(image: FileImage(image), fit: BoxFit.cover)
                : null,
            color: Colors.grey.shade300,
          ),
          child: image == null
              ? const Icon(Icons.image, size: 40, color: Colors.white70)
              : null,
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70))
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _studentCardImage == null ||
        _avatarImage == null) {
      setState(() => _error = 'Please fill all fields and select both images.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await _apiService
          .registerStudent(
            email: _email.text,
            fullName: _name.text,
            password: _password.text,
            gender: _gender,
            dob: _dob.text,
            address: _address.text,
            phoneNumber: _phone.text,
            studentCode: _studentCode.text,
            identityCard: _identityCard.text,
            enrollmentDate: _enrollmentDate.text,
            studentCardImage: _studentCardImage!,
            avatarImage: _avatarImage!,
          )
          .timeout(const Duration(seconds: 20));

      setState(() => _isLoading = false);

      if (res['isSuccess'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Register success!'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      } else {
        setState(() => _error = res['message']);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString().contains('Timeout')
            ? 'Request timed out. Check your connection.'
            : 'Something went wrong: ${e.toString()}';
      });
    }
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType? type,
      String? Function(String?)? validator,
      bool readOnly = false,
      VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
        ),
        validator:
            validator ?? (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Register as Student',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 24),
                        if (_error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Group 1: Account Info
                        const Text("Thông tin tài khoản",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        _field('Full Name', _name),
                        _field('Email', _email,
                            type: TextInputType.emailAddress),
                        _field('Password', _password),
                        _field('Phone Number', _phone,
                            type: TextInputType.phone),
                        _field('Date of Birth', _dob, readOnly: true,
                            onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1960),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _dob.text =
                                "${picked.day}-${picked.month}-${picked.year}");
                          }
                        }),

                        const SizedBox(height: 24),

                        // Group 2: Student Info
                        const Text("Thông tin sinh viên",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        _field('Address', _address),
                        _field('Student Code', _studentCode, validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final regex = RegExp(r'^[A-Z]{2}\d{6}$');
                          if (!regex.hasMatch(v)) {
                            return 'Format: 2 letters + 6 digits (e.g., AB123456)';
                          }
                          return null;
                        }),
                        _field('Identity Card', _identityCard),
                        _field('Enrollment Date', _enrollmentDate,
                            readOnly: true, onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _enrollmentDate.text =
                                "${picked.day}-${picked.month}-${picked.year}");
                          }
                        }),
                        Row(
                          children: [
                            const Text('Gender:',
                                style: TextStyle(color: Colors.white)),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: _gender,
                              dropdownColor: Colors.black87,
                              style: const TextStyle(color: Colors.white),
                              onChanged: (val) =>
                                  setState(() => _gender = val!),
                              items: const [
                                DropdownMenuItem(
                                    value: 'male', child: Text('Male')),
                                DropdownMenuItem(
                                    value: 'female', child: Text('Female')),
                              ],
                            )
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Group 3: Image Upload
                        const Text("Ảnh đại diện & Thẻ sinh viên",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () => _pickImage(true),
                              child: _imagePreview(
                                  _studentCardImage, 'Student Card'),
                            ),
                            GestureDetector(
                              onTap: () => _pickImage(false),
                              child: _imagePreview(_avatarImage, 'Avatar'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF38BDF8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Register'),
                        ),

                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            '← Back to Sign In',
                            style: TextStyle(
                                color: Color(0xFFFBBF24),
                                decoration: TextDecoration.underline),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
