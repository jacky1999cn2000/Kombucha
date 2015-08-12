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
			if(!Test.isRunningTest()){
				resp = http.send(req);
			}
		}catch(Exception ex){
			return ex.getMessage();
		}

		if(!Test.isRunningTest()){
			System.debug('***resp '+resp.getBody());

			if(resp.getBody().contains('authentication failure')){
				return 'authentication failure';
			}

			if(resp.getBody().contains('Unauthorized endpoint')){
				return 'Unauthorized endpoint';
			}
		}
		
		String resBody = (Test.isRunningTest()) ? KombuchaConstants.KOMBUCHA_SESSIONREFRESHER_RESPONSE : resp.getBody();
		
		Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(resBody);

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
