import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../config/app_config.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: AppConfig.baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // Auth endpoints
  @POST('/api/auth/login/')
  Future<Map<String, dynamic>> login(@Body() Map<String, dynamic> data);
  
  @POST('/api/auth/register/')
  Future<Map<String, dynamic>> register(@Body() Map<String, dynamic> data);
  
  @POST('/api/auth/logout/')
  Future<Map<String, dynamic>> logout(@Header('Authorization') String token);
  
  @POST('/api/auth/refresh/')
  Future<Map<String, dynamic>> refreshToken(@Body() Map<String, dynamic> data);
  
  @GET('/api/auth/profile/')
  Future<Map<String, dynamic>> getProfile(@Header('Authorization') String token);
  
  @PUT('/api/auth/profile/')
  Future<Map<String, dynamic>> updateProfile(
    @Header('Authorization') String token,
    @Body() Map<String, dynamic> data,
  );
  
  // Orders endpoints
  @GET('/api/orders/')
  Future<Map<String, dynamic>> getOrders(@Header('Authorization') String token);
  
  @POST('/api/orders/')
  Future<Map<String, dynamic>> createOrder(
    @Header('Authorization') String token,
    @Body() Map<String, dynamic> data,
  );
  
  @GET('/api/orders/{id}/')
  Future<Map<String, dynamic>> getOrder(
    @Header('Authorization') String token,
    @Path('id') String id,
  );
  
  @PUT('/api/orders/{id}/')
  Future<Map<String, dynamic>> updateOrder(
    @Header('Authorization') String token,
    @Path('id') String id,
    @Body() Map<String, dynamic> data,
  );
  
  // Notifications endpoints
  @GET('/api/notifications/')
  Future<Map<String, dynamic>> getNotifications(@Header('Authorization') String token);
  
  @POST('/api/notifications/mark-all-read/')
  Future<Map<String, dynamic>> markAllAsRead(@Header('Authorization') String token);
  
  @POST('/api/notifications/devices/')
  Future<Map<String, dynamic>> registerDevice(
    @Header('Authorization') String token,
    @Body() Map<String, dynamic> data,
  );
  
  // KYC endpoints
  @GET('/api/kyc/verification/')
  Future<Map<String, dynamic>> getKycStatus(@Header('Authorization') String token);
  
  @POST('/api/kyc/documents/')
  Future<Map<String, dynamic>> uploadKycDocument(
    @Header('Authorization') String token,
    @Part() List<MultipartFile> files,
  );
  
  // Payment endpoints
  @GET('/api/payments/wallet/')
  Future<Map<String, dynamic>> getWallet(@Header('Authorization') String token);
  
  @POST('/api/payments/')
  Future<Map<String, dynamic>> createPayment(
    @Header('Authorization') String token,
    @Body() Map<String, dynamic> data,
  );
  
  @GET('/api/payments/history/')
  Future<Map<String, dynamic>> getPaymentHistory(@Header('Authorization') String token);
}
