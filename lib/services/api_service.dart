import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/borrow_contract_model.dart';
import '../models/borrow_history_model.dart';
import '../models/borrow_request_item.dart';
import '../models/category_model.dart';
import '../models/compensation_transaction.dart';
import '../models/deposit_transaction.dart';
import '../models/donate_item_model.dart';
import '../models/feedback_borrow_model.dart';
import '../models/feedback_model.dart';
import '../models/item_model.dart';
import '../models/order_detail.dart';
import '../models/order_detail_model.dart';
import '../models/order_model.dart';
import '../models/payment_response_model.dart';
import '../models/product_model.dart';
import '../models/report_damage_model.dart';
import '../models/shop_model.dart';
import '../providers/cart_provider.dart';
import '../utils/api_constants.dart';

class ApiService {
  // Hàm lấy danh sách items từ API
  Future<List<ItemModel>> fetchItems() async {
    try {
      print("🚀 Calling API: ${ApiConstants.getDonateItems}");
      final response = await http.get(Uri.parse(ApiConstants.getDonateItems));
      print("📥 Response status: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print("✅ isSuccess: ${responseData['isSuccess']}");
        print("📝 Message: ${responseData['message']}");

        if (responseData['isSuccess'] == true) {
          List<dynamic> itemsJson = responseData['data'];
          print("📋 Items count: ${itemsJson.length}");
          final items =
              itemsJson.map((json) => ItemModel.fromJson(json)).toList();
          print("✨ Parsed items count: ${items.length}");
          return items;
        } else {
          throw Exception("API Error: ${responseData['message']}");
        }
      } else {
        throw Exception("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error in fetchItems: $e");
      rethrow;
    }
  }

  Future<List<FeedbackBorrow>> fetchFeedbacks() async {
    try {
      print("🚀 Calling API: ${ApiConstants.getFeedbacks}");
      final response = await http.get(Uri.parse(ApiConstants.getFeedbacks));
      print("📥 Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print("✅ isSuccess: ${responseData['isSuccess']}");

        if (responseData['isSuccess'] == true) {
          List<dynamic> feedbackJson = responseData['data'];
          print("📋 Feedback count: ${feedbackJson.length}");
          return feedbackJson
              .map((json) => FeedbackBorrow.fromJson(json))
              .toList();
        } else {
          throw Exception("API Error: ${responseData['message']}");
        }
      } else {
        throw Exception("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error in fetchFeedbacks: $e");
      rethrow;
    }
  }

  Future<List<String>> fetchItemImages(int itemId) async {
    final String url = ApiConstants.getItemImages(itemId); // ✅ Gọi đúng hàm
    print("🚀 Fetching item images from: $url");

    try {
      final response = await http.get(Uri.parse(url));
      print("📥 Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['isSuccess'] == true) {
          List<String> imageUrls = (responseData['data'] as List)
              .map((json) => json['imageUrl'].toString())
              .toList();
          print("📸 Retrieved ${imageUrls.length} images.");
          return imageUrls;
        } else {
          throw Exception("API Error: ${responseData['message']}");
        }
      } else {
        throw Exception("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching item images: $e");
      return [];
    }
  }

  Future<List<Category>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.getCategories));
      print("📥 Fetching categories: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['isSuccess'] == true) {
          List<dynamic> categoriesJson = responseData['data'];
          List<Category> categories =
              categoriesJson.map((json) => Category.fromJson(json)).toList();
          return categories;
        } else {
          throw Exception("API Error: ${responseData['message']}");
        }
      } else {
        throw Exception("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching categories: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      print("🚀 Logging in with: $email | $password");
      print("🔗 API URL: ${ApiConstants.login}");

      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("✅ isSuccess: ${data['isSuccess']}");
        print("📝 Message: ${data['message']}");

        if (data['isSuccess']) {
          final String token = data['data']['token'];
          final String refreshToken = data['data']['refreshToken'];

          print("🔑 Token: $token");

          // 🟢 Giải mã token để lấy role
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          print("📌 Decoded Token: $decodedToken");
          final int userId = int.parse(decodedToken['userId']);

          print("✅ Đã lưu userId: $userId");

          if (!decodedToken.containsKey("role")) {
            print("❌ Token không chứa role!");
            throw Exception("Token không hợp lệ, thiếu role");
          }

          String role = decodedToken['role'];
          print("👤 Role: $role");

          // 🛑 Chỉ cho phép đăng nhập nếu role là "Student"
          if (role != "Student") {
            print("⛔ Tài khoản không được phép đăng nhập!");
            throw Exception("Bạn không có quyền truy cập");
          }

          // 🔹 Lưu token vào SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token);
          await prefs.setString('refreshToken', refreshToken);
          await prefs.setString('userRole', role);
          await prefs.setInt('userId', userId);
          // 🔄 Load giỏ hàng của user mới
          final context = GlobalKey<NavigatorState>().currentContext;
          if (context != null) {
            await Provider.of<CartProvider>(context, listen: false).loadCart();
          }

          return {
            'token': token,
            'refreshToken': refreshToken,
            'role': role,
            'userId': userId,
          };
        } else {
          print("❌ Login failed: ${data['message']}");
          throw Exception(data['message']);
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        throw Exception("Login failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error in login: $e");
      return null;
    }
  }

  Future<bool> logout(String refreshToken) async {
    try {
      print("🚪 Logging out...");

      final response = await http.post(
        Uri.parse("${ApiConstants.logout}"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("✅ isSuccess: ${data['isSuccess']}");
        print("📝 Message: ${data['message']}");

        if (data['isSuccess']) {
          // 🗑️ Xóa token khỏi SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('authToken');
          await prefs.remove('userRole');

          print("🔓 Đăng xuất thành công!");
          return true;
        } else {
          print("❌ Logout failed: ${data['message']}");
          throw Exception(data['message']);
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        throw Exception("Logout failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error in logout: $e");
      return false;
    }
  }

  Future<int?> createBorrowRequest(
      int itemId, DateTime startDate, DateTime endDate, int majorId) async {
    try {
      // 🔹 Lấy token từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        print('❌ Không tìm thấy token, vui lòng đăng nhập lại.');
        return null;
      }

      final url = Uri.parse(ApiConstants.borrowRequestCreate);
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'itemId': itemId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'majorId': majorId, // Thêm trường majorId vào body
      });

      print("🚀 Sending borrow request to: $url");
      print("📦 Request body: $body");

      final response = await http.post(url, headers: headers, body: body);

      print("📥 Response status: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['isSuccess']) {
          print('✅ Yêu cầu mượn thiết bị đã được tạo thành công.');
          return responseData['data']
              ['requestId']; // Trả về requestId thay vì toàn bộ dữ liệu
        } else {
          print('❌ Lỗi: ${responseData['message']}');
          return null;
        }
      } else {
        print('❌ Lỗi HTTP: ${jsonDecode(response.body)['message']}');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi khi gửi yêu cầu: $e');
      return null;
    }
  }

  Future<int?> getUserIdFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        print("❌ Không tìm thấy token, vui lòng đăng nhập lại.");
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getUserInfo}'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📥 Response status: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['isSuccess']) {
          final int userId = responseData['data']['userId'];
          await prefs.setInt('userId', userId); // ✅ Lưu vào SharedPreferences
          print("✅ User ID từ API: $userId");
          return userId;
        }
      }
    } catch (e) {
      print("❌ Lỗi khi lấy User ID từ API: $e");
    }
    return null;
  }

  Future<List<BorrowRequestItem>> fetchUserBorrowRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      int? userId = prefs.getInt('userId');

      if (token == null) {
        print("❌ Không tìm thấy token, vui lòng đăng nhập lại.");
        throw Exception("Không tìm thấy token, vui lòng đăng nhập lại.");
      }

      // ✅ Nếu userId chưa có, lấy từ API
      if (userId == null) {
        userId = await getUserIdFromApi();
        if (userId == null) {
          throw Exception("Không thể lấy User ID, vui lòng đăng nhập lại.");
        }
      }

      print("🔍 Token lấy từ SharedPreferences: $token");
      print("👤 User ID: $userId");

      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.getAllBorrowRequests}'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📥 Response status: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['isSuccess']) {
          List<dynamic> allRequests = responseData['data'];

          // ✅ Lọc danh sách request theo userId của user đang login
          List<BorrowRequestItem> userRequests = allRequests
              .map((item) => BorrowRequestItem.fromJson(item))
              .where((request) => request.userId == userId)
              .toList();

          print("📋 Tổng số request: ${allRequests.length}");
          print("🎯 Số request của user $userId: ${userRequests.length}");

          return userRequests;
        } else {
          throw Exception(responseData['message'] ?? 'Lỗi không xác định');
        }
      } else {
        throw Exception('Không thể tải danh sách mượn');
      }
    } catch (e) {
      print("❌ Lỗi fetchUserBorrowRequests: $e");
      throw Exception("Lỗi khi tải danh sách mượn: $e");
    }
  }

  Future<Map<String, dynamic>?> getUserInfoFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        print("❌ Không tìm thấy token, vui lòng đăng nhập lại.");
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getUserInfo}'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📥 Response status: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['isSuccess']) {
          final Map<String, dynamic> userInfo = responseData['data'];
          // Lưu vào SharedPreferences nếu cần
          await prefs.setInt('userId', userInfo['userId']);
          print("✅ Dữ liệu người dùng từ API: $userInfo");
          return userInfo;
        }
      }
    } catch (e) {
      print("❌ Lỗi khi lấy thông tin người dùng từ API: $e");
    }
    return null;
  }

  Future<List<BorrowHistory>> getBorrowHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("Token không hợp lệ hoặc chưa đăng nhập.");
      }

      int? userId = prefs.getInt('userId');

      // Nếu không có userId trong SharedPreferences, lấy từ API
      if (userId == null) {
        userId = await getUserIdFromApi();
        if (userId == null) {
          throw Exception("Không thể lấy User ID, vui lòng đăng nhập lại.");
        }
      }

      print("👤 User ID: $userId");

      final response = await http.get(
        Uri.parse(ApiConstants.borrowHistoryEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Kiểm tra xem có trường 'data' trong phản hồi không
        if (data['data'] != null) {
          // Chuyển đổi dữ liệu JSON thành danh sách BorrowHistory
          List<BorrowHistory> borrowHistoryList = (data['data'] as List)
              .map((item) => BorrowHistory.fromJson(item))
              .toList();

          // Lọc lịch sử mượn theo userId
          List<BorrowHistory> userBorrowHistory = borrowHistoryList
              .where((history) => history.userId == userId)
              .toList();

          return userBorrowHistory;
        } else {
          throw Exception("Không có dữ liệu lịch sử mượn");
        }
      } else {
        throw Exception('Không thể tải lịch sử mượn');
      }
    } catch (e) {
      print("❌ Lỗi khi lấy lịch sử mượn: $e");
      throw Exception("Lỗi khi lấy lịch sử mượn: $e");
    }
  }

  Future<Map<String, dynamic>> getRequest(String endpoint) async {
    try {
      print('🔍 Fetching from: $endpoint'); // Debug URL

      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("Token không hợp lệ hoặc chưa đăng nhập.");
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("❌ Error in getRequest: $e");
      throw Exception("Lỗi khi lấy dữ liệu: $e");
    }
  }

  Future<Map<String, dynamic>> postFeedback(
      Map<String, dynamic> feedbackData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("Token không hợp lệ hoặc chưa đăng nhập.");
      }

      final response = await http.post(
        Uri.parse(ApiConstants.createFeedback),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(feedbackData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to send feedback: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("❌ Error sending feedback: $e");
      throw Exception("Lỗi khi gửi đánh giá: $e");
    }
  }

  Future<bool> deleteBorrowRequest(int requestId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("Token không hợp lệ hoặc chưa đăng nhập.");
      }

      final url = ApiConstants.deleteBorrowRequest(requestId);
      print('🚀 Calling delete API: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('📥 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['isSuccess'] == true) {
          print('✅ Xóa yêu cầu mượn thành công');
          return true;
        } else {
          print('❌ Xóa thất bại: ${responseData['message']}');
          throw Exception(responseData['message']);
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        throw Exception('500'); // Trả về 500 cho mọi lỗi HTTP
      }
    } catch (e) {
      print('❌ Error in deleteBorrowRequest: $e');
      throw Exception('500'); // Trả về 500 cho mọi exception
    }
  }

  Future<List<BorrowContract>> fetchBorrowContract() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');
      final int? userId =
          prefs.getInt('userId'); // Lấy userId từ SharedPreferences

      if (token == null) {
        throw Exception("Token không hợp lệ hoặc chưa đăng nhập.");
      }

      if (userId == null) {
        throw Exception("Không tìm thấy thông tin người dùng.");
      }

      final response = await http.get(
        Uri.parse(ApiConstants.getAllBorrowContracts),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['isSuccess'] == true) {
          List<dynamic> contractsData = responseData['data'];
          List<BorrowContract> contracts = [];

          for (var contractData in contractsData) {
            BorrowContract contract = BorrowContract.fromJson(contractData);

            // Chỉ lấy thông tin request cho contract của user hiện tại
            if (contract.userId == userId) {
              try {
                var requestDetail = await getRequest(
                    ApiConstants.getBorrowRequest(contract.requestId));
                if (requestDetail != null) {
                  contract.requestDetail = requestDetail;
                }
              } catch (e) {
                print(
                    '⚠️ Không thể lấy thông tin request cho contract ${contract.contractId}: $e');
                // Tiếp tục với contract tiếp theo nếu có lỗi
              }
            }

            contracts.add(contract);
          }

          // Lọc chỉ trả về các contract của user hiện tại
          return contracts
              .where((contract) => contract.userId == userId)
              .toList();
        } else {
          throw Exception(responseData['message']);
        }
      } else {
        throw Exception('Failed to load borrow contracts');
      }
    } catch (e) {
      print('❌ Error fetching borrow contracts: $e');
      return [];
    }
  }

  Future<List<Product>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('Token không hợp lệ');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.getProducts),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody["isSuccess"] && responseBody["data"] != null) {
        return (responseBody["data"] as List)
            .map((item) => Product.fromJson(item))
            .toList();
      } else {
        throw Exception(responseBody["message"]);
      }
    } else {
      throw Exception('Lỗi khi tải sản phẩm: ${response.statusCode}');
    }
  }

  static Future<List<String>> fetchProductImages(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("⚠️ Không tìm thấy token, vui lòng đăng nhập lại.");
      }

      final response = await http.get(
        Uri.parse("${ApiConstants.productImages}/$productId"),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['isSuccess']) {
          List<dynamic> imagesData = data['data'];
          return imagesData.map((img) => img['imageUrl'].toString()).toList();
        } else {
          throw Exception("🚨 API Error: ${data['message']}");
        }
      } else {
        throw Exception("❌ HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Lỗi khi lấy ảnh sản phẩm: $e");
      return [];
    }
  }

  static Future<List<FeedbackModel>> fetchProductFeedbacks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token =
          prefs.getString('authToken'); // Lấy token từ SharedPreferences

      final response = await http.get(
        Uri.parse(ApiConstants.getProductFeedbacks),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['isSuccess'] && responseData['data'] != null) {
          List<dynamic> data = responseData['data'];
          return data.map((json) => FeedbackModel.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print("❌ Lỗi khi lấy feedbacks: $e");
      return [];
    }
  }

  static Future<OrderResponse?> createOrder(OrderRequest orderRequest) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token =
          prefs.getString('authToken'); // Lấy token từ SharedPreferences

      if (token == null) {
        throw Exception("Token không tồn tại!");
      }

      final response = await http.post(
        Uri.parse(ApiConstants.createOrder),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderRequest.toJson()),
      );
      debugPrint("📥 API Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return OrderResponse.fromJson(responseData['data']);
      }
      return null;
    } catch (e) {
      print("❌ Lỗi đặt hàng: $e");
      return null;
    }
  }

  static Future<bool> createOrderDetails(
      List<OrderDetailRequest> details) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) throw Exception("Token không tồn tại!");

      final bodyJson = jsonEncode(details.map((e) => e.toJson()).toList());
      debugPrint("📤 Sending raw OrderDetails array: $bodyJson");

      final response = await http.post(
        Uri.parse(ApiConstants.createOrderDetail),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
        body: bodyJson,
      );

      debugPrint("📥 API Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("❌ Lỗi khi tạo danh sách chi tiết đơn hàng: $e");
      return false;
    }
  }

  Future<List<OrderResponse>> getOrdersByUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final userId =
          prefs.getInt('userId'); // Lấy userId đã lưu sau khi đăng nhập

      if (token == null || userId == null) {
        throw Exception("Người dùng chưa đăng nhập hoặc thiếu token");
      }

      final response = await http.get(
        Uri.parse(ApiConstants.getOrders),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        if (jsonBody["isSuccess"] == true) {
          List<OrderResponse> orders = (jsonBody["data"] as List)
              .map((item) => OrderResponse.fromJson(item))
              .where((order) => order.userId == userId) // Lọc theo userId
              .toList();
          return orders;
        }
      }
      return [];
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách đơn hàng: $e");
      return [];
    }
  }

  static Future<List<OrderDetail>> fetchOrderDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.orderDetails),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['isSuccess']) {
        List<dynamic> data = responseData['data'];
        return data.map((json) => OrderDetail.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to load order details');
  }

  static Future<Product?> fetchProduct(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) {
      throw Exception("Token not found, please login again.");
    }

    final response = await http.get(
      Uri.parse('${ApiConstants.productEndpoint}/$productId'),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['isSuccess']) {
        return Product.fromJson(jsonResponse['data']);
      }
    }
    return null;
  }

  static Future<bool> deleteOrder(int orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("Token không tồn tại.");
      }

      final response = await http.delete(
        Uri.parse(ApiConstants.deleteOrder(orderId)),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['isSuccess'] == true) {
        print("Order deleted: ${data['data']}");
        return true;
      } else {
        print("Delete failed: ${data['message']}");
        return false;
      }
    } catch (e) {
      print("Error deleting order: $e");
      return false;
    }
  }

  static Future<bool> deleteOrderDetail(int orderDetailId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("Token không tồn tại.");
      }

      final response = await http.delete(
        Uri.parse("${ApiConstants.deleteOrderDetail}/$orderDetailId"),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['isSuccess'] == true) {
        print("Order detail deleted: ${data['data']}");
        return true;
      } else {
        print("Delete failed: ${data['message']}");
        return false;
      }
    } catch (e) {
      print("Error deleting order detail: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>> submitFeedback(
    int orderDetailId,
    int productId,
    int userId,
    int rating,
    String comments,
    bool isAnonymous,
  ) async {
    // Lấy token từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    if (token == null) {
      throw Exception('Token is missing. Please login again.');
    }

    final url = Uri.parse(ApiConstants.feedbackProduct);

    final response = await http.post(
      url,
      headers: {
        'Accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'orderDetailId': orderDetailId,
        'productId': productId,
        'userId': userId,
        'rating': rating,
        'comments': comments,
        'isAnonymous': isAnonymous,
      }),
    );

    if (response.statusCode == 201) {
      // Nếu phản hồi thành công (status code 201)
      return json.decode(response.body);
    } else {
      // Nếu có lỗi, trả về thông tin lỗi
      throw Exception('Failed to submit feedback: ${response.statusCode}');
    }
  }

  Future<bool> createBorrowHistory({
    required int requestId,
    required int itemId,
    required int userId,
    required String borrowDate,
    required String returnDate,
    required String status, // Thêm trường status
  }) async {
    final url = Uri.parse("${ApiConstants.borrowHistories}");

    // Lấy token từ SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs
        .getString('authToken'); // Giả sử bạn lưu token với key 'auth_token'

    // In token để kiểm tra
    print("Token: $token");

    if (token == null) {
      throw Exception("Không tìm thấy token, vui lòng đăng nhập lại.");
    }

    // In dữ liệu request body để kiểm tra
    print("Request Body: ");
    print(jsonEncode({
      "requestId": requestId,
      "itemId": itemId,
      "userId": userId,
      "borrowDate": borrowDate,
      "returnDate": returnDate,
      "status": status, // Thêm trường status vào request body
    }));

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Thêm token vào header
      },
      body: jsonEncode({
        "requestId": requestId,
        "itemId": itemId,
        "userId": userId,
        "borrowDate": borrowDate,
        "returnDate": returnDate,
        "status": status, // Thêm trường status vào body
      }),
    );

    // In phản hồi từ server để kiểm tra
    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Lỗi khi tạo lịch sử mượn: ${response.body}");
    }
  }

  Future<bool> deleteBorrowHistory(int borrowHistoryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        print("❌ Không tìm thấy token, vui lòng đăng nhập lại.");
        return false; // Trả về false nếu không có token
      }

      // Gửi yêu cầu DELETE đến API
      final response = await http.delete(
        Uri.parse('${ApiConstants.borrowHistories}/$borrowHistoryId'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📥 Response status: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['isSuccess']) {
          print("✅ Xóa lịch sử mượn thành công");
          return true; // Trả về true nếu xóa thành công
        } else {
          print("❌ Thông báo từ API: ${responseData['message']}");
        }
      } else {
        print("❌ Lỗi từ API khi xóa lịch sử mượn: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Lỗi khi gọi API để xóa lịch sử mượn: $e");
    }
    return false; // Trả về false nếu không thành công
  }

  Future<Map<String, dynamic>> registerStudent({
    required String email,
    required String fullName,
    required String password,
    required String gender,
    required String dob,
    required String address,
    required String phoneNumber,
    required String studentCode,
    required String identityCard,
    required String enrollmentDate,
    required File studentCardImage,
    required File avatarImage,
  }) async {
    var uri = Uri.parse(ApiConstants.registerStudent);

    var request = http.MultipartRequest('POST', uri);
    request.fields['Email'] = email;
    request.fields['FullName'] = fullName;
    request.fields['Password'] = password;
    request.fields['Gender'] = gender;
    request.fields['Dob'] = dob;
    request.fields['Address'] = address;
    request.fields['PhoneNumber'] = phoneNumber;
    request.fields['StudentCode'] = studentCode;
    request.fields['IdentityCard'] = identityCard;
    request.fields['EnrollmentDate'] = enrollmentDate;

    request.files.add(await http.MultipartFile.fromPath(
      'StudentCardImage',
      studentCardImage.path,
      contentType: MediaType('image', 'jpeg'),
    ));
    request.files.add(await http.MultipartFile.fromPath(
      'AvatarImage',
      avatarImage.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register student');
    }
  }

  static Future<PaymentResponse?> createPayment(int orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) return null;

      final url = Uri.parse(
          '${ApiConstants.createPayment}?orderID=$orderId&paymenMethodId=3');

      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess']) {
          return PaymentResponse.fromJson(jsonBody['data']);
        }
      }
    } catch (e) {
      print("❌ Lỗi khi tạo payment: $e");
    }
    return null;
  }

  static Future<String?> getPaymentUrl(
      int paymentId, String redirectUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) return null;

      final url = Uri.parse(
          '${ApiConstants.getPaymentUrl}/$paymentId/payment-url?redirectUrl=${Uri.encodeComponent(redirectUrl)}');

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess']) {
          return jsonBody['data'];
        }
      }
    } catch (e) {
      print("❌ Lỗi khi lấy URL thanh toán: $e");
    }
    return null;
  }

  static Future<http.Response> updateTransactionStatus(
      String transactionCode, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.updatePayment}/$transactionCode');
    debugPrint('PUT URL: $url');

    final response = await http.put(
      url,
      headers: {
        'accept': '*/*', // thêm dòng này luôn cho đúng swagger
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': status,
      }),
    );

    return response;
  }

  Future<Map<String, dynamic>> updateProfile({
    required String dob,
    required String address,
    required String phoneNumber,
    required String gender,
    File? avatarImage,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("Token không hợp lệ hoặc chưa đăng nhập.");
      }

      final uri = Uri.parse(
        "${ApiConstants.updateProfile}"
        "?Dob=$dob&Address=$address&PhoneNumber=$phoneNumber&Gender=$gender",
      );

      print("📤 Sending PUT to: $uri");

      var request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['accept'] = '*/*';

      if (avatarImage != null) {
        print("🖼 Adding image: ${avatarImage.path}");
        request.files.add(await http.MultipartFile.fromPath(
          'AvatarImage',
          avatarImage.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        print("⚠ Không có ảnh mới, giữ ảnh cũ.");
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("✅ Response status: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      if (response.statusCode == 200) {
        return {
          'isSuccess': true,
          'statusCode': response.statusCode,
          'body': response.body,
        };
      } else {
        return {
          'isSuccess': false,
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }
    } catch (e) {
      print("❌ Update profile error: $e");
      return {
        'isSuccess': false,
        'error': e.toString(),
      };
    }
  }

  Future<List<Map<String, dynamic>>> fetchMajors() async {
    try {
      final response =
          await http.get(Uri.parse(ApiConstants.majorsUrl), headers: {
        'Accept': '*/*',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['isSuccess']) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception('Failed to load majors');
        }
      } else {
        throw Exception('Failed to load majors');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateOrder(
      int orderId,
      double totalPrice,
      String orderAddress,
      String field,
      String status) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.updateOrderUrl.replaceFirst("{orderId}", orderId.toString())}');

    final response = await http.put(
      url,
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'totalPrice': totalPrice,
        'orderAddress': orderAddress,
        'field': field,
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      // Parse response body if success
      return json.decode(response.body);
    } else {
      // Handle error if status code is not 200
      throw Exception('Failed to update order');
    }
  }

  static Future<List<DepositTransaction>> fetchDepositTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(ApiConstants.getDepositTransactions),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] && jsonBody['data'] != null) {
          return List<DepositTransaction>.from(
            jsonBody['data'].map((item) => DepositTransaction.fromJson(item)),
          );
        }
      } else {
        print("❌ API error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Lỗi khi fetch deposit transactions: $e");
    }

    return [];
  }

  static Future<List<CompensationTransaction>>
      fetchCompensationTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse(ApiConstants.compensationTransactions),
      headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<dynamic> data = jsonBody['data'];
      return data.map((e) => CompensationTransaction.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load compensation transactions');
    }
  }

  static Future<DonateItem> fetchDonateItemById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse(ApiConstants.donateItemById(id)),
      headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return DonateItem.fromJson(jsonBody['data']);
    } else {
      throw Exception('Failed to fetch donate item');
    }
  }

  static Future<List<ReportDamage>> fetchReportDamages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse(ApiConstants.reportDamages),
      headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<dynamic> data = jsonBody['data'];
      return data.map((e) => ReportDamage.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch report damages');
    }
  }

  static Future<bool> updateProduct({
    required int productId,
    required String productName,
    required String cpu,
    required String ram,
    required String storage,
    required String graphicsCard,
    required String battery,
    required String screenSize,
    required String operatingSystem,
    required String ports,
    required String color,
    required int quantity,
    required double price,
    required int categoryId,
    required int shopId,
    required String model,
    required int productionYear,
    required String description,
    File? imageFile,
  }) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.updateProduct}/$productId');

    final request = http.MultipartRequest('PUT', url);

    // Thêm form fields
    request.fields.addAll({
      'ProductId': productId.toString(),
      'ProductName': productName,
      'Cpu': cpu,
      'Ram': ram,
      'Storage': storage,
      'GraphicsCard': graphicsCard,
      'Battery': battery,
      'ScreenSize': screenSize,
      'OperatingSystem': operatingSystem,
      'Ports': ports,
      'Color': color,
      'Quantity': quantity.toString(),
      'Price': price.toString(),
      'CategoryId': categoryId.toString(),
      'ShopId': shopId.toString(),
      'Model': model.toString(),
      'ProductionYear': productionYear.toString(),
      'Description': description,
    });

    // Nếu có ảnh thì thêm vào
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'ImageFile',
          imageFile.path,
          contentType: MediaType('image', 'webp'), // tuỳ theo loại file
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Update product failed: ${response.statusCode}');
        print('Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception updating product: $e');
      return false;
    }
  }

  static Future<bool> updateProductWithNewQuantity(
      Product product, int newQuantity) async {
    return await updateProduct(
      productId: product.productId,
      productName: product.productName,
      cpu: product.cpu,
      ram: product.ram,
      storage: product.storage,
      graphicsCard: product.graphicsCard,
      battery: product.battery,
      screenSize: product.screenSize,
      operatingSystem: product.operatingSystem,
      ports: product.ports,
      color: product.color,
      quantity: newQuantity, // 👈 quantity mới
      price: product.price.toDouble(), // 👈 đúng kiểu `double`
      categoryId: product.categoryId,
      shopId: product.shopId,
      model: product.model.toString(), // 👈 bạn đang dùng String cho model
      productionYear: product.productionYear,
      description: product.description,
      imageFile: null, // 👈 không update ảnh
    );
  }

  static Future<Shop?> fetchShopById(int id) async {
    final url =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getShopById}/$id');

    try {
      final response = await http.get(url, headers: {
        'accept': '*/*',
      });

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        print('Raw shop data: ${body['data']}');
        if (body['isSuccess'] == true) {
          return Shop.fromJson(body['data']);
        } else {
          throw Exception(body['message']);
        }
      } else {
        throw Exception('Failed to load shop info: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchShopById: $e');
      return null;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.changePassword);

    // Lấy token từ SharedPreferences (hoặc nơi bạn lưu token)
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    // Kiểm tra xem token có tồn tại hay không
    if (token == null) {
      // Nếu không có token, trả về false
      return false;
    }

    // Thực hiện yêu cầu HTTP POST với token trong header
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Thêm token vào header
      },
      body: json.encode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    // Kiểm tra mã trạng thái của phản hồi
    if (response.statusCode == 200) {
      // Nếu yêu cầu thành công, trả về true
      return true;
    } else {
      // Nếu yêu cầu thất bại, trả về false
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.forgotPassword);

    // Thực hiện yêu cầu HTTP POST
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email, // Gửi email trong body
      }),
    );

    // Kiểm tra mã trạng thái của phản hồi
    if (response.statusCode == 200) {
      // Nếu yêu cầu thành công, trả về true
      return true;
    } else {
      // Nếu yêu cầu thất bại, trả về false
      return false;
    }
  }
}
