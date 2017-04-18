class Group {
  String name;
  final String leader;
  List members;

  Group(this.name, [this.leader, this.members]) {}

  Group.fromMap(Map map) :
    this(map['name'], map['leader'], map['members']);

  Map toMap() => {
    "name": name,
    "leader": leader,
    "members": members
  };
}