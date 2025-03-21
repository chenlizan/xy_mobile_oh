import _ from '@wolfx/lodash'
import qs from '@open/qs'
import { http } from '@kit.NetworkKit'
import { PreferenceStorage } from '../model/LocalStorageModel';
import { RouterConstants } from '../constants/RouterConstants';

interface Options {
  method: http.RequestMethod;
  body?: PARAMS | string;
  headers?: PARAMS
}

interface ApiResponse {
  code: number
  success?: boolean
  data?: PARAMS | Token
}

interface CCApiResponse {
  code?: number
  result?: PARAMS | Token | Array<PARAMS>
  msg?: string
}

interface Token {
  access_token?: string,
  refresh_token?: string,
  refresh_token_state?: string
}

export type PARAMS = Record<string, string | number | boolean | undefined | null | object> | Array<string>

const enhancedFetch = async (url: string, options?: Options) => {
  const httpRequest = http.createHttp();
  const access_token = AppStorage.get<PreferenceStorage>('PreferenceStorage')?.access_token
  const requestOptions: http.HttpRequestOptions = {
    header: _.merge({
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Bearer ' + access_token,
    }, options?.headers),
    method: options?.method,
    extraData: options?.body
  };

  try {
    const response = await httpRequest.request(url, requestOptions);
    const result: ApiResponse = JSON.parse(_.isString(response.result) ? response.result : '{}');
    if (result.code >= 400 && result.code < 500) {
      console.error('请求的资源可能不存在', url);
    } else if (result.code >= 500) {
      console.error('服务器无法正常访问');
    }
    if (result.code === 401) {
      console.error('未授权');
      const preferenceStorage = AppStorage.get<PreferenceStorage>('PreferenceStorage')
      if (preferenceStorage?.access_token && preferenceStorage.refreshToken) {
        preferenceStorage.access_token = undefined
        preferenceStorage.refreshToken = undefined
      }
      AppStorage.set<string>('globalPageIndex', RouterConstants.LOGIN_PAGE_URL)
      return result;
    }
    return result;
  } catch (error) {
    console.error('HTTP请求失败:', error);
    return error;
  }
}

export const xyApiPost =
  async (path: string, body?: PARAMS, headers?: PARAMS): Promise<ApiResponse> => {
    let _body: PARAMS | string | undefined;
    if (
      headers &&
      headers['Content-Type'] &&
        headers['Content-Type'] === 'application/x-www-form-urlencoded'
    ) {
      _body = qs.stringify(body);
    } else if (
      headers &&
      headers['Content-Type'] &&
        headers['Content-Type'] === 'multipart/form-data'
    ) {
      _body = body;
    } else {
      _body = JSON.stringify(body);
    }
    return await enhancedFetch(path, {
      method: http.RequestMethod.POST,
      body: _body,
      headers,
    });
  }

export const xyApiGet = async (path: string, body?: PARAMS, headers?: PARAMS): Promise<ApiResponse> => {
  let fullUrl = path;
  if (body) {
    fullUrl += '?' + qs.stringify(body);
  }
  return await enhancedFetch(fullUrl, {
    method: http.RequestMethod.GET,
    headers
  });
}

export const xyApiPut = async (path: string, body?: PARAMS, headers?: PARAMS): Promise<ApiResponse> => {
  let _body: string;
  if (
    headers &&
    headers['Content-Type'] &&
      headers['Content-Type'] === 'application/x-www-form-urlencoded'
  ) {
    _body = qs.stringify(body);
  } else {
    _body = JSON.stringify(body);
  }
  return await enhancedFetch(path, {
    method: http.RequestMethod.PUT,
    body: _body,
    headers,
  });
}

export const xyApiDelete =
  async (path: string, query?: PARAMS, headers?: PARAMS, body?: PARAMS): Promise<ApiResponse> => {
    let fullUrl = path;
    let _body: string | null = null;
    if (query) {
      fullUrl += '?' + qs.stringify(query);
    }
    if (
      headers &&
      headers['Content-Type'] &&
        headers['Content-Type'] === 'application/x-www-form-urlencoded'
    ) {
      _body = qs.stringify(body);
    } else {
      _body = JSON.stringify(body);
    }
    return await enhancedFetch(fullUrl, {
      method: http.RequestMethod.DELETE,
      headers,
      body: _body,
    });
  }

export const ccApiPost = async (path: string, body?: PARAMS, headers?: PARAMS): Promise<CCApiResponse> => {
  const res = await xyApiPost(path, body, headers)
  return res as CCApiResponse
}

export const ccApiGet =
  async (path: string, body?: PARAMS, headers?: Record<string, string>): Promise<CCApiResponse> => {
    const res = await xyApiGet(path, body, headers)
    return res as CCApiResponse
  }