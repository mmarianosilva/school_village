
class IntradoResponse{
  IntradoResponse(this.success, this.message,this.response);

  bool success;
  String message;
  String response;


  factory IntradoResponse.fromJson(Map<String, dynamic> parsedJson){
    return IntradoResponse(parsedJson['success'],
         parsedJson['message'],
         parsedJson ['response']);
  }
}