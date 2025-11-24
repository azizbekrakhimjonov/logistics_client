class Endpoint {
  Endpoint._(); 
  
  static String register = 'api/users/auth/register/client/';
  static String verifyPhone = 'api/users/auth/check-otp/';
  static String refreshToken= 'api/users/auth/refresh-token/';
  static String getUser = 'api/users/data/me/';
  static String getCategories = "api/content/categories/";
  static String updateUser = "api/users/data/update/";
  static String checkUser = "api/orders/user/check/";
  
  //orders
  static String preOrder = "api/orders/preorder-create/";
  static String orderHistory = "api/orders/order-history/";
  static String orderList = "api/orders/preorder-list/";
  static String preOrderDetail = "api/orders/preorder-detail/";
  static String orderDetail = "api/orders/order-detail/";
  static String preOrderDelete = "api/orders/preorder-delete/";
  static String orderCreate = "api/orders/order-create/";
  }