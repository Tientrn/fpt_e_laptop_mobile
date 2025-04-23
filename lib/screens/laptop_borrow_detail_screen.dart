import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/feedback_borrow_model.dart';
import '../../models/donate_item_model.dart';
import '../../services/api_service.dart';
import '../widgets/homepage/custom_header.dart';
import '../widgets/homepage/custom_footer.dart';

class LaptopBorrowDetailScreen extends StatefulWidget {
  const LaptopBorrowDetailScreen({super.key});

  @override
  State<LaptopBorrowDetailScreen> createState() =>
      _LaptopBorrowDetailScreenState();
}

class _LaptopBorrowDetailScreenState extends State<LaptopBorrowDetailScreen> {
  final ApiService _apiService = ApiService();
  List<FeedbackBorrow> _feedbacks = [];
  List<String> _imageUrls = [];
  bool _isLoading = true;
  String? _mainImage;
  int? selectedMajorId;
  List<Map<String, dynamic>> majors = [];
  bool _showAllFeedbacks = false;
  DonateItem? _donateItem;

  double get averageRating {
    if (_feedbacks.isEmpty) return 0;
    double totalRating = _feedbacks.fold(0, (sum, fb) => sum + fb.rating);
    return totalRating / _feedbacks.length;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) return;

    final int itemId = args['itemId'] ?? 0;
    _mainImage = args['itemImage'];

    try {
      List<FeedbackBorrow> allFeedbacks = await _apiService.fetchFeedbacks();
      List<String> images = await _apiService.fetchItemImages(itemId);
      if (_mainImage != null && !_imageUrls.contains(_mainImage)) {
        images.insert(0, _mainImage!);
      }

      // Fetch detailed donate item data
      DonateItem donateItem = await ApiService.fetchDonateItemById(itemId);

      List<Map<String, dynamic>> allMajors = await _apiService.fetchMajors();

      if (mounted) {
        setState(() {
          majors = allMajors;
          _feedbacks = allFeedbacks.where((fb) => fb.itemId == itemId).toList();
          _imageUrls = images.isNotEmpty
              ? images
              : [_mainImage ?? "https://via.placeholder.com/250"];
          _donateItem = donateItem;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print("❌ Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text("Error Loading Data"),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              ),
            ),
          ),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            "No laptop data available!",
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    final laptop = args;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CustomHeader(
            showBackButton: true,
            title: _donateItem?.itemName ?? "${laptop['itemName']}"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.network(
                    _mainImage ?? "https://via.placeholder.com/250",
                    width: double.infinity,
                    height: 270,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (_imageUrls.isNotEmpty) ...[
                SizedBox(
                  height: 70,
                  child: Center(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: _imageUrls.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _mainImage = _imageUrls[index];
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            transform: Matrix4.identity()
                              ..scale(
                                  _mainImage == _imageUrls[index] ? 1.08 : 1.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _mainImage == _imageUrls[index]
                                    ? const Color(0xFF42A5F5)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _imageUrls[index],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      _buildSectionTitle(
                          "Basic Information", Icons.info_outline),
                      _buildInfoSection(
                          "CPU", _donateItem?.cpu ?? laptop['cpu']),
                      _buildInfoSection(
                          "RAM", _donateItem?.ram ?? laptop['ram']),
                      _buildInfoSection(
                          "Storage", _donateItem?.storage ?? laptop['storage']),
                      _buildInfoSection("Screen Size",
                          "${_donateItem?.screenSize ?? laptop['screenSize']} inch"),
                      _buildInfoSection(
                          "Condition",
                          _donateItem?.conditionItem ??
                              laptop['conditionItem']),
                      _buildInfoSection(
                        "Status",
                        (_donateItem?.status ?? laptop['status']) == "Available"
                            ? "Available"
                            : "Not Available",
                        icon: (_donateItem?.status ?? laptop['status']) ==
                                "Available"
                            ? Icons.check
                            : Icons.close,
                      ),

                      // Design Specifications
                      if (_donateItem != null &&
                          (_donateItem!.model.isNotEmpty ||
                              _donateItem!.color.isNotEmpty ||
                              _donateItem!.productionYear > 0))
                        _buildSectionTitle("Design", Icons.design_services),

                      if (_donateItem?.model.isNotEmpty ?? false)
                        _buildInfoSection("Model", _donateItem!.model),

                      if (_donateItem?.color.isNotEmpty ?? false)
                        _buildInfoSection("Color", _donateItem!.color),

                      if (_donateItem?.productionYear != null &&
                          _donateItem!.productionYear > 0)
                        _buildInfoSection("Production Year",
                            _donateItem!.productionYear.toString()),

                      // Additional Hardware
                      if (_donateItem != null &&
                          (_donateItem!.graphicsCard.isNotEmpty ||
                              _donateItem!.battery.isNotEmpty ||
                              _donateItem!.ports.isNotEmpty))
                        _buildSectionTitle(
                            "Additional Hardware", Icons.hardware),

                      if (_donateItem?.graphicsCard.isNotEmpty ?? false)
                        _buildInfoSection(
                            "Graphics Card", _donateItem!.graphicsCard),

                      if (_donateItem?.battery.isNotEmpty ?? false)
                        _buildInfoSection("Battery", _donateItem!.battery),

                      if (_donateItem?.ports.isNotEmpty ?? false)
                        _buildInfoSection("Ports", _donateItem!.ports),

                      // Software & System
                      if (_donateItem != null &&
                          (_donateItem!.operatingSystem.isNotEmpty ||
                              _donateItem!.serialNumber.isNotEmpty))
                        _buildSectionTitle("System", Icons.computer),

                      if (_donateItem?.operatingSystem.isNotEmpty ?? false)
                        _buildInfoSection(
                            "Operating System", _donateItem!.operatingSystem),

                      if (_donateItem?.serialNumber.isNotEmpty ?? false)
                        _buildInfoSection(
                            "Serial Number", _donateItem!.serialNumber),

                      // Description
                      if (_donateItem?.description.isNotEmpty ?? false) ...[
                        _buildSectionTitle("Description", Icons.description),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6FA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _donateItem!.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],

                      // Borrowing Statistics
                      _buildSectionTitle("Statistics", Icons.analytics),
                      _buildInfoSection(
                        "Times Borrowed",
                        (_donateItem?.totalBorrowedCount ?? 0).toString(),
                        icon: Icons.history,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: laptop['status'] == "Available"
                    ? ElevatedButton(
                        onPressed: () => _confirmBorrow(
                            context, laptop['itemId'], _apiService),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          shadowColor: const Color(0xFF1976D2).withOpacity(0.3),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.transparent,
                        ).copyWith(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) => Colors.transparent,
                          ),
                          overlayColor:
                              MaterialStateProperty.all(Colors.white10),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                          child: const Text(
                            "Borrow Laptop",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : const Text(
                        "Currently Unavailable",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFE53935),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Average Rating",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 10),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1976D2),
                      ),
                    )
                  : _feedbacks.isEmpty
                      ? const Text(
                          "No feedback available.",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6B7280),
                          ),
                        )
                      : Column(
                          children: [
                            Text(
                              "${averageRating.toStringAsFixed(1)} ⭐",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFB300),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...(_showAllFeedbacks
                                    ? _feedbacks
                                    : _feedbacks.take(3))
                                .map((fb) {
                              return Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  leading: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: fb.isAnonymous
                                        ? const Color(0xFF6B7280)
                                        : const Color(0xFF1976D2),
                                    child: Icon(
                                      fb.isAnonymous
                                          ? Icons.person_off
                                          : Icons.person,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    "⭐ ${fb.rating}/5",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    fb.comments,
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 13,
                                    ),
                                  ),
                                  trailing: Text(
                                    DateFormat('dd/MM/yy')
                                        .format(fb.feedbackDate),
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            if (_feedbacks.length > 3)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showAllFeedbacks = !_showAllFeedbacks;
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _showAllFeedbacks
                                          ? "Hide feedback"
                                          : "Show all feedback",
                                      style: const TextStyle(
                                        color: Color(0xFF1976D2),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(
                                      _showAllFeedbacks
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: const Color(0xFF1976D2),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomFooter(),
    );
  }

  Widget _buildInfoSection(String label, String? value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Expanded(
            child: Text(
              value ?? "N/A",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1976D2),
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
              shadows: [
                Shadow(
                  color: Colors.black12,
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBorrow(BuildContext context, int itemId, ApiService apiService) {
    bool isLoading = false;
    bool isAgreementChecked = false;
    Future<int?> _getUserId() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getInt('userId');
    }

    DateTime addMonths(DateTime date, int monthsToAdd) {
      int year = date.year;
      int month = date.month + monthsToAdd;
      while (month > 12) {
        month -= 12;
        year += 1;
      }
      int day = date.day;
      int lastDayOfNewMonth = DateTime(year, month + 1, 0).day;
      if (day > lastDayOfNewMonth) day = lastDayOfNewMonth;
      return DateTime(year, month, day);
    }

    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No laptop data available"),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    final laptop = args;
    DateTime? startDate = DateTime.now(); // ✅ Gán sẵn ngày hiện tại
    DateTime? endDate = addMonths(startDate, 4);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding: const EdgeInsets.all(16),
              title: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: const Text(
                  "Confirm Borrowing",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _mainImage ?? "https://via.placeholder.com/100",
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoSection("Name",
                                _donateItem?.itemName ?? laptop['itemName']),
                            _buildInfoSection(
                                "CPU", _donateItem?.cpu ?? laptop['cpu']),
                            _buildInfoSection(
                                "RAM", _donateItem?.ram ?? laptop['ram']),
                            _buildInfoSection("Storage",
                                _donateItem?.storage ?? laptop['storage']),
                            if (_donateItem?.model.isNotEmpty ?? false)
                              _buildInfoSection("Model", _donateItem!.model),
                            if (_donateItem?.color.isNotEmpty ?? false)
                              _buildInfoSection("Color", _donateItem!.color),
                            if (_donateItem?.operatingSystem.isNotEmpty ??
                                false)
                              _buildInfoSection(
                                  "OS", _donateItem!.operatingSystem),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ✅ Ngày mượn tự động: hôm nay
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        title: Text(
                          "Start: ${DateFormat('dd/MM/yyyy').format(startDate!)}",
                          style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 14,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.lock_clock,
                          color: Color(0xFF6B7280),
                          size: 18,
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Start date is automatically set to today."),
                              backgroundColor: Color(0xFF42A5F5),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ✅ Ngày trả: chỉ chọn trong 4 tháng kể từ hôm nay
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        title: Text(
                          endDate != null
                              ? "End: ${DateFormat('dd/MM/yyyy').format(endDate!)}"
                              : "End Date",
                          style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 14,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF42A5F5),
                          size: 18,
                        ),
                        onTap: () async {
                          DateTime minEndDate = addMonths(startDate!, 4);
                          DateTime maxEndDate =
                              addMonths(startDate!, 12); // Tuỳ ý bạn mở rộng

                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: endDate ?? minEndDate,
                            firstDate: minEndDate,
                            lastDate: maxEndDate,
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF1976D2),
                                    onPrimary: Colors.white,
                                    surface: Color(0xFFF5F6FA),
                                  ),
                                  dialogBackgroundColor:
                                      const Color(0xFFF5F6FA),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Color(0xFF1976D2),
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedDate != null) {
                            setState(() {
                              endDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Chọn ngành
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: apiService.fetchMajors(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF1976D2),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Text(
                                "Unable to load majors.",
                                style: TextStyle(
                                  color: Color(0xFFE53935),
                                  fontSize: 14,
                                ),
                              );
                            }
                            majors = snapshot.data ?? [];
                            return DropdownButton<int>(
                              value: selectedMajorId,
                              hint: const Text(
                                "Select Major",
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                ),
                              ),
                              isExpanded: true,
                              onChanged: (int? newValue) {
                                setState(() {
                                  selectedMajorId = newValue;
                                });
                              },
                              items: majors.map((major) {
                                return DropdownMenuItem<int>(
                                  value: major['id'],
                                  child: Text(
                                    major['name'],
                                    style: const TextStyle(
                                      color: Color(0xFF1A1A1A),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),
                    Card(
                      color: const Color(0xFFFFFBF2),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFFFFE0B2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.shield_outlined,
                                    color: Color(0xFFFFA000), size: 20),
                                SizedBox(width: 6),
                                Text(
                                  "Terms and Conditions",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFBF360C),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                                "• You must return the laptop in the same condition as received."),
                            const Text(
                                "• Any damage or loss will be your responsibility."),
                            const Text(
                                "• The borrowing period is strictly between the selected dates."),
                            const Text(
                                "• Extensions must be requested before the end date."),
                            const Text(
                                "• Failure to return on time may result in penalties."),
                            const SizedBox(height: 10),
                            StatefulBuilder(
                              builder: (context, setState) {
                                return CheckboxListTile(
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  value: isAgreementChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isAgreementChecked = value ?? false;
                                    });
                                  },
                                  title: const Text(
                                    "I agree to care for and return the laptop in good condition.",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),

              //term and condition

              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B7280).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF1976D2),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: (startDate != null &&
                                    endDate != null &&
                                    selectedMajorId != null &&
                                    isAgreementChecked)
                                ? () async {
                                    setState(() => isLoading = true);
                                    try {
                                      final userId = await _getUserId();
                                      if (userId == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text("User data not found!"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      final borrowRequests = await apiService
                                          .fetchUserBorrowRequests();
                                      final hasApprovedRequest =
                                          borrowRequests.any(
                                        (request) =>
                                            request.status == 'Approved',
                                      );

                                      if (hasApprovedRequest) {
                                        final donateItem = await ApiService
                                            .fetchDonateItemById(itemId);

                                        if (donateItem.status ==
                                                "NotAvailable" ||
                                            donateItem.status == "Borrwing") {
                                          setState(() => isLoading = false);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "You already have an approved request, and the item is not available."),
                                              backgroundColor: Colors.orange,
                                              duration: Duration(seconds: 8),
                                            ),
                                          );
                                          return;
                                        }
                                      }

                                      final hasPendingRequest =
                                          borrowRequests.any(
                                        (request) =>
                                            request.status == 'Pending',
                                      );

                                      if (hasPendingRequest) {
                                        setState(() => isLoading = false);
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "You already have a pending request. Please wait before submitting a new one."),
                                            backgroundColor: Colors.orange,
                                            duration: Duration(seconds: 8),
                                          ),
                                        );
                                        return;
                                      }

                                      final borrowRequestId =
                                          await apiService.createBorrowRequest(
                                        itemId,
                                        startDate!,
                                        endDate!,
                                        selectedMajorId!,
                                      );
                                      if (borrowRequestId != null) {
                                        setState(() => isLoading = false);
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Laptop successfully borrowed!"),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setState(() => isLoading = false);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Error: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            child: const Text("Confirm"),
                          ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
