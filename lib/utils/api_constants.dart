class ApiConstants {
  static const String baseUrl = "https://fptsharelaptop.io.vn/api";
  static const String login = "$baseUrl/Authentication/login";
  static const String registerStudent =
      '$baseUrl/Authentication/register/student';
  static const String getDonateItems = "$baseUrl/donate-items";
  static String donateItemById(int id) => '$baseUrl/donate-items/$id';
  static const String getFeedbacks = "$baseUrl/FeedbackBorrow/get-all";
  static String getItemImages(int itemId) => "$baseUrl/item-images/$itemId";
  static const String getCategories = "$baseUrl/categories";
  static const String logout = "$baseUrl/Authentication/logout";
  static const String borrowRequestCreate = '$baseUrl/BorrowRequest/create';
  static const String getAllBorrowRequests = '/BorrowRequest/get-all';
  static const String getUserInfo = '/Authentication/user-infor';
  static const String borrowHistoryEndpoint = '$baseUrl/borrow-histories';
  static String getBorrowRequest(int requestId) {
    return '$baseUrl/BorrowRequest/get/$requestId'; // Thêm /$requestId vào URL
  }

  static const String getAllBorrowContracts = "$baseUrl/BorrowContract/get-all";

  static String deleteBorrowRequest(int requestId) =>
      '$baseUrl/BorrowRequest/delete/$requestId';

  static String createFeedback = "$baseUrl/FeedbackBorrow/create";
  static const String getProducts = '$baseUrl/products';
  static const String productImages = "$baseUrl/product-images";
  static const String getProductFeedbacks = "$baseUrl/feedback-products";
  static const String createOrder = '$baseUrl/orders';
  static const String createOrderDetail =
      "$baseUrl/orderdetails"; // Thêm dòng này
  static const String getOrders = "$baseUrl/orders";
  static const String orderDetails = '$baseUrl/orderdetails';
  static const String productEndpoint = '$baseUrl/products';
  static String deleteOrder(int orderId) => '$baseUrl/orders/$orderId';
  static const String deleteOrderDetail = "$baseUrl/orderdetails";
  static const String feedbackProduct = '$baseUrl/feedback-products';
  static const String borrowHistories = "$baseUrl/borrow-histories";
  static String deleteBorrowHistory(int historyId) =>
      '$baseUrl/borrow-histories/$historyId';

  static const String createPayment = "$baseUrl/Payment/create";
  static const String getPaymentUrl = "$baseUrl/Payment";
  static const String confirmPayment = "$baseUrl/Payment";

  static const String updateProfile = "$baseUrl/Authentication/update-profile";
  static const String majorsUrl = '$baseUrl/majors';

  static const String updateOrderUrl = '/orders/{orderId}';

  static const String getDepositTransactions = '$baseUrl/deposit-transactions';
  static const String compensationTransactions =
      '$baseUrl/compensation-transactions';
  static const String reportDamages = '$baseUrl/report-damages';
}
