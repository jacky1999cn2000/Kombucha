public with sharing class KombuchaSessionRefresher {

	public static String requestAccessToken(String username, String password, String clientId, String clientSecret, String tokenEndpoint) {

		HttpRequest req = new HttpRequest();
		req.setEndpoint(tokenEndpoint);
		req.setMethod('POST');
		req.setBody(buildHttpQuery(new Map<String, String>{
			'grant_type' => 'password',
			'username' => username,
			'password' => password,
			'client_id' => clientId,
			'client_secret' => clientSecret
		}));

		System.debug('***req '+req);

		Http http = new Http();
		HttpResponse resp;
		try{
			resp = http.send(req);
		}catch(Exception ex){
			return ex.getMessage();
		}

		System.debug('***resp '+resp.getBody());

		Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());

		return (String)m.get('access_token');
	}

	public static String buildHttpQuery(Map<String, String> queryParams){
		if(queryParams.isEmpty()){
			return '';
		}

		String[] params = new String[]{};
		for(String k : queryParams.keySet()){
			String v = EncodingUtil.urlEncode(queryParams.get(k), 'UTF-8');
			params.add(String.format('{0}={1}', new String[] {k, v}));
		}

		return String.join(params, '&');
	}
}


















