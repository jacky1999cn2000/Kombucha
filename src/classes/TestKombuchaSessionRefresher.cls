@isTest
private class TestKombuchaSessionRefresher {
	
	@isTest static void test_requestAccessToken() {
		String tokenEndpoint = 'https://login.salesforce.com/services/oauth2/token';
		String username = 'jacky.zhao@kombucha.com';
		String password = 'Test.12348zwttaiuGue3Y5eIkfHdISWg';
		String clientId = '3MVG9QDx8IX8nP5TDUEcqn9g5NV2Mmoorc8ce29x4DibO9_vCc10quGGvZxEdCeF7EbxRoUU8cydvNd5ngVZd';
		String clientSecret = '2098978559629868962';
		
		System.assertEquals(KombuchaSessionRefresher.requestAccessToken(username, password, clientId, clientSecret, tokenEndpoint), '00D37000000ITcH!ARQAQJEN_0d5TJXNSQMuTFpOEnnTXDkLZdFTDKgCGA8B.MMSe9AGwqbXRVtd7NNhR0VIE_BlvQm_1J.ZzjW1i6a.PNqtu8v4');
	}	
}