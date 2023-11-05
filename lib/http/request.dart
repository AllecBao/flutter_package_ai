import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../common/constant.dart';
import '../utils/log_util.dart';
import '../utils/user_util.dart';

class RequestService {
  final Dio _dio;

  String toMd5(String data) {
    var bytes = utf8.encode(data);
    final dig = md5.convert(bytes);
    return dig.toString();
  }

  RequestService() : _dio = Dio() {
    _dio.options.baseUrl = Constant.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 8);

    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      var token = UserUtil.getToken();
      var time = DateTime.now().millisecondsSinceEpoch.toString();
      var appkey = Constant.appkey;
      var appsecret = Constant.appsecret;
      var sign = toMd5(appkey + appsecret + time).toUpperCase();
      if (token.isNotEmpty) {
        options.headers['accessToken'] = token;
      }
      options.headers['appkey'] = appkey;
      options.headers['datetime'] = time;
      options.headers['sign'] = sign;
      return handler.next(options);
    }, onResponse: (Response response, ResponseInterceptorHandler handler) {
      return handler.next(response);
    }));
  }

  Future<Response?> fetchData({
    required String method,
    required String path,
    Map<String, dynamic>? params,
    Object? data,
    CancelToken? cancelToken,
  }) async {
    try {
      Response response;
      if (method == 'get') {
        response = await _dio.get(path,
            queryParameters: params, data: data, cancelToken: cancelToken);
      } else if (method == 'post') {
        response = await _dio.post(path,
            queryParameters: params, data: data, cancelToken: cancelToken);
      } else if (method == 'put') {
        response = await _dio.put(path,
            queryParameters: params, data: data, cancelToken: cancelToken);
      } else if (method == 'delete') {
        response = await _dio.delete(path,
            queryParameters: params, data: data, cancelToken: cancelToken);
      } else if (method == 'file') {
        _dio.options.headers['Content-Type'] = 'multipart/form-data';
        response = await _dio.post(path,
            queryParameters: params, data: data, cancelToken: cancelToken);
      } else {
        response = await _dio.get(path,
            queryParameters: params, data: data, cancelToken: cancelToken);
      }
      return response;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {}
      return Response(requestOptions: RequestOptions());
    } on Exception catch (_) {}
    return null;
  }

  Future<List<Response>?> fetchDataList({
    required String method,
    required String path,
    required List<Map<String, dynamic>>? dataList,
    CancelToken? cancelToken,
  }) async {
    try {
      if (method == 'post') {
        if (dataList != null && dataList.isNotEmpty) {
          final responseList = <Future<Response>>[];
          for (var data in dataList) {
            log(data);
            final response = _dio.post(
              path,
              data: data,
              cancelToken: cancelToken,
            );
            responseList.add(response);
          }
          return await Future.wait(responseList);
        }
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {}
    } on Exception catch (_) {}
    return null;
  }
}
