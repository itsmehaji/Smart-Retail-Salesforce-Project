public with sharing class RetailAIAgentService {

    public class Request {
        @InvocableVariable(required=true)
        public String prompt;
    }

    public class Response {
        @InvocableVariable
        public String result;
    }

    @InvocableMethod(label='Retail AI Assistant')
    public static List<Response> generate(List<Request> requests) {

        List<Response> responses = new List<Response>();

        for(Request req : requests){

            String resultText = callOpenAI(req.prompt);

            Response r = new Response();
            r.result = resultText;
            responses.add(r);
        }

        return responses;
    }

    private static String callOpenAI(String userPrompt){

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:OpenAI/v1/chat/completions');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');

        Map<String, Object> body = new Map<String, Object>{
            'model' => 'gpt-4o-mini',
            'messages' => new List<Object>{
                new Map<String, String>{
                    'role' => 'system',
                    'content' => 'You are a Retail Business AI Assistant. Provide structured business insights.'
                },
                new Map<String, String>{
                    'role' => 'user',
                    'content' => userPrompt
                }
            }
        };

        request.setBody(JSON.serialize(body));

        Http http = new Http();
        HttpResponse response = http.send(request);

        if(response.getStatusCode() == 200){
            Map<String,Object> parsed =
                (Map<String,Object>)JSON.deserializeUntyped(response.getBody());

            List<Object> choices = (List<Object>)parsed.get('choices');
            Map<String,Object> first = (Map<String,Object>)choices[0];
            Map<String,Object> message =
                (Map<String,Object>)first.get('message');

            return (String)message.get('content');
        }

        return 'Error calling AI';
    }
}