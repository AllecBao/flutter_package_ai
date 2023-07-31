import 'package:dio/dio.dart';
import '../utils/user_util.dart';
import '../common/constant.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class RequestService{
  final Dio _dio;

  //Md5加密
  String toMd5(String data){
    var bytes = utf8.encode(data);
    final dig = md5.convert(bytes);
    return dig.toString();
    // var content = new Utf8Encoder().convert(data);
    // var digest = md5.convert(content);
    // return hex.encode(digest.bytes);
  }

  RequestService() : _dio= Dio() {
    _dio.options.baseUrl = Constant.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 8);

    //拦截器
    _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options,handler){
            var token = UserUtil.getToken();
            var time =  DateTime.now().millisecondsSinceEpoch.toString();
            var appkey = Constant.appkey;
            var appsecret = Constant.appsecret;
            var sign = toMd5(appkey+appsecret+time).toUpperCase();
            if(token.isNotEmpty){
              options.headers['accessToken'] = token;
            }
            options.headers['appkey'] = appkey;
            options.headers['datetime'] = time;
            options.headers['sign'] = sign;
            return handler.next(options);
          },
          onResponse: (Response response, ResponseInterceptorHandler handler){
            return handler.next(response);
          }
        )
    );
  }

  Future<Response?> fetchData( String method, String path,Map<String,dynamic>? params,Object? data, {CancelToken? cancelToken,}) async {
    try{
      Response response;
      if(method=='get'){
        response = await _dio.get(path,queryParameters: params,data:data,cancelToken: cancelToken);
      }else if(method=='post'){
        response = await _dio.post(path,queryParameters: params,data:data,cancelToken: cancelToken);
      }else if(method=='put'){
        response = await _dio.put(path,queryParameters: params,data:data,cancelToken: cancelToken);
      }else if(method=='delete'){
        response = await _dio.delete(path,queryParameters: params,data:data,cancelToken: cancelToken);
      }else if(method=='file'){
        _dio.options.headers['Content-Type'] = 'multipart/form-data';
        response = await _dio.post(path,queryParameters: params,data:data,cancelToken: cancelToken);
      }else {
        response = await _dio.get(path, queryParameters: params, data: data,cancelToken: cancelToken);
      }
      return response;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        // print("---->>>>>>>请求取消$e");
      }
      // print('1111111');
      // throw Exception(e);
      return Response(requestOptions: RequestOptions());
    } on Exception catch(_){
      // print('2222222222');
      // throw Exception(e);
    }
    return null;
  }
}