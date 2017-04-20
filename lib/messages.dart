class Message {
  final String name;
  final String text;
  final String roomName;
  String photoURL;
  String imageURL;

  Message(this.name, this.roomName, this.text, this.imageURL, String photoURL) {
    this.photoURL= photoURL ?? "https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg";
  }

  Message.fromMap(Map map) :
      this(map['name'], map['roomName'], map['text'], map['imageURL'], map['photoURL']);

  Map toMap() => {
    "name" : name,
    "roomName": roomName,
    "text" : text,
    "imageURL": imageURL,
    "photoURL": photoURL
  };
}