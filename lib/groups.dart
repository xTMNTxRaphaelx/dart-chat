class Group {
  final String name;
  final String leader;
  final List members;

  Group(this.name, [this.leader, this.members]) {}

  Group.fromMap(Map map) :
    this(map['name'], map['leader'], map['members']);

  Map toMap() => {
    "name": name,
    "leader": leader,
    "members": members
  };
}