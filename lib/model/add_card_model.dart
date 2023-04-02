
class AddCardModel{

  AddCardModel(var cardImage,String cardId,String cardName){
    this._cardId=cardId;
    this._cardImage=cardImage;
    this._cardName=cardName;
  }

  var _cardImage;
  String _cardId;
  String _cardName;

  get cardImage => _cardImage;

  set cardImage(String value) {
    _cardImage = value;
  }

  String get cardId => _cardId;

  String get cardName => _cardName;

  set cardName(String value) {
    _cardName = value;
  }

  set cardId(String value) {
    _cardId = value;
  }
}