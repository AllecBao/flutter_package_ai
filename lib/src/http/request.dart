import 'package:dio/dio.dart';
import '../utils/userUtil.dart';
import '../common/constant.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

class RequestService{
  final Dio _dio;

  //Md5加密
  String toMd5(String data){
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  RequestService() : _dio= Dio() {
    _dio.options.baseUrl = Constant.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 6);

    //拦截器
    _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options,handler){
            var token = UserUtil.getToken();
            var time = new DateTime.now().millisecondsSinceEpoch.toString();
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

  Future<Response> fetchData( String method, String path,{Map<String,dynamic>? params,Object? data}) async {
    try{
      Response response;
      if(method=='get'){
        response = await _dio.get(path,queryParameters: params,data:data);
      }else if(method=='post'){
        response = await _dio.post(path,queryParameters: params,data:data);
      }else if(method=='put'){
        response = await _dio.put(path,queryParameters: params,data:data);
      }else if(method=='delete'){
        response = await _dio.delete(path,queryParameters: params,data:data);
      }else {
        response = await _dio.get(path, queryParameters: params, data: data);
      }
      return response;
    }catch(e){
      throw Exception(e);
    }
  }
}